//! Random chains of bitcasts between types of one width, compiled by us and
//! run: each function loads a value, casts it through 1 to 4 types
//! (integers, floating point, vectors of every lane type, vectors of one
//! lane, masks), changing its bits on the way by operations that are exact
//! on bits (`xor` with constants, `fneg`, lane reversals), and stores the
//! result.
//!
//! What it must store is worked out here: on bytes in memory's order a
//! bitcast changes nothing, an `xor` is an `xor` of bytes (a mask's lane
//! `k` is bit `k`), `fneg` flips the top bit of each lane, and a reversal
//! reverses the lanes. Functions we cannot compile are reported with their
//! reasons, and those whose results differ with their IR; either fails the
//! test.
//!
//! clang's build of the same functions is run too, for comparison only: its
//! back end cannot compile some of them, and gets some wrong (bitcasts of
//! `<2 x i8>` to `<1 x half>`); those are listed, not failures.
//!
//! On an AArch64 Mac with clang only. `EPITOME_BITCAST_SEED` and
//! `EPITOME_BITCAST_COUNT` choose other functions.

use std::collections::BTreeMap;
use std::process::Command;

use epitome_codegen::target::Target;
use epitome_codegen::{Options, compile};

#[derive(Clone, Copy, PartialEq)]
enum Kind {
    Int,
    Float,
    /// Lanes of integers (`bits` each).
    IntVec(u32, u32),
    /// Lanes of floating point.
    FloatVec(u32, u32),
    Mask(u32),
}

#[derive(Clone)]
struct Ty {
    text: String,
    kind: Kind,
    bits: u32,
}

fn types(bits: u32) -> Vec<Ty> {
    let mut out = Vec::new();
    let mut add = |text: String, kind| out.push(Ty { text, kind, bits });
    if bits <= 128 {
        add(format!("i{bits}"), Kind::Int);
    }
    match bits {
        16 => add("half".into(), Kind::Float),
        32 => add("float".into(), Kind::Float),
        64 => add("double".into(), Kind::Float),
        _ => {}
    }
    for e in [8, 16, 32, 64, 128] {
        if e <= bits && !(e == 128 && bits == 128) {
            add(format!("<{} x i{e}>", bits / e), Kind::IntVec(bits / e, e));
        }
    }
    if bits <= 128 {
        add(format!("<1 x i{bits}>"), Kind::IntVec(1, bits));
    }
    for (e, name) in [(16, "half"), (32, "float"), (64, "double")] {
        if e <= bits {
            add(format!("<{} x {name}>", bits / e), Kind::FloatVec(bits / e, e));
        }
    }
    // Masks of up to 64 lanes: wider ones come of comparisons of more than
    // 64 bytes, which code does not make.
    if bits <= 64 {
        add(format!("<{bits} x i1>"), Kind::Mask(bits));
    }
    out
}

/// xorshift64, here and in the C driver: the same numbers in both.
struct Rng(u64);

impl Rng {
    fn next(&mut self) -> u64 {
        self.0 ^= self.0 << 13;
        self.0 ^= self.0 >> 7;
        self.0 ^= self.0 << 17;
        self.0
    }
    fn below(&mut self, n: usize) -> usize {
        (self.next() % n as u64) as usize
    }
}

/// What an operation does to the value's bytes.
enum Effect {
    /// `xor` with these bytes.
    Xor(Vec<u8>),
    /// The order of lanes of this many bytes reversed.
    Reverse(usize),
    /// The top bit of each lane of this many bytes flipped.
    FlipSign(usize),
}

impl Effect {
    fn apply(&self, b: &mut [u8]) {
        match self {
            Effect::Xor(x) => b.iter_mut().zip(x).for_each(|(a, x)| *a ^= x),
            Effect::Reverse(n) => {
                let lanes: Vec<Vec<u8>> = b.chunks(*n).map(<[u8]>::to_vec).rev().collect();
                b.copy_from_slice(&lanes.concat());
            }
            Effect::FlipSign(n) => b.chunks_mut(*n).for_each(|l| l[n - 1] ^= 0x80),
        }
    }
}

/// An operation exact on bits, on value `v` of type `t`, as the line making
/// `%{name}`, and what it does to the bytes.
fn change(rng: &mut Rng, t: &Ty, v: &str, name: &str) -> (String, Effect) {
    let bytes = (t.bits / 8) as usize;
    match t.kind {
        Kind::Int => {
            let mut x: Vec<u8> = (0..bytes).map(|_| rng.next() as u8).collect();
            x[bytes - 1] &= 0x7f;
            let c = x.iter().rev().fold(0u128, |a, &b| (a << 8) | u128::from(b));
            (format!("%{name} = xor {} {v}, {c}", t.text), Effect::Xor(x))
        }
        Kind::IntVec(n, e) => {
            if rng.below(3) == 0 && n > 1 {
                let m = (0..n).rev().map(|k| format!("i32 {k}")).collect::<Vec<_>>().join(", ");
                (
                    format!("%{name} = shufflevector {} {v}, {} poison, <{n} x i32> <{m}>", t.text, t.text),
                    Effect::Reverse((e / 8) as usize),
                )
            } else {
                let mut x = Vec::new();
                let mut lanes = Vec::new();
                for _ in 0..n {
                    let lane: Vec<u8> = (0..e / 8).map(|_| rng.next() as u8).collect();
                    let c = lane.iter().rev().fold(0u128, |a, &b| (a << 8) | u128::from(b));
                    lanes.push(format!("i{e} {c}"));
                    x.extend(lane);
                }
                (format!("%{name} = xor {} {v}, <{}>", t.text, lanes.join(", ")), Effect::Xor(x))
            }
        }
        Kind::Float => (format!("%{name} = fneg {} {v}", t.text), Effect::FlipSign(bytes)),
        Kind::FloatVec(_, e) => (format!("%{name} = fneg {} {v}", t.text), Effect::FlipSign((e / 8) as usize)),
        Kind::Mask(n) => {
            let bits: Vec<bool> = (0..n).map(|_| rng.next() & 1 == 1).collect();
            let mut x = vec![0u8; bytes];
            for (k, &b) in bits.iter().enumerate() {
                if b {
                    x[k / 8] |= 1 << (k % 8);
                }
            }
            let ls: Vec<String> = bits.iter().map(|&b| format!("i1 {b}")).collect();
            (format!("%{name} = xor {} {v}, <{}>", t.text, ls.join(", ")), Effect::Xor(x))
        }
    }
}

struct Func {
    text: String,
    bytes: usize,
    effects: Vec<Effect>,
}

/// A function `@f{k}(ptr %in, ptr %out)`.
fn function(rng: &mut Rng, k: usize) -> Func {
    let bits = [8, 16, 32, 64, 128, 256][rng.below(6)];
    let all = types(bits);
    let memory: Vec<&Ty> = all.iter().filter(|t| !matches!(t.kind, Kind::Mask(_))).collect();
    let first = memory[rng.below(memory.len())].clone();
    let last = memory[rng.below(memory.len())].clone();
    let steps = 1 + rng.below(4);
    let mut chain = vec![first.clone()];
    for _ in 1..steps {
        chain.push(all[rng.below(all.len())].clone());
    }
    chain.push(last);
    let mut body = format!("  %v0 = load {}, ptr %in, align 1\n", first.text);
    let mut effects = Vec::new();
    let mut cur = "%v0".to_string();
    for (n, w) in chain.windows(2).enumerate() {
        if rng.below(2) == 0 {
            let (line, e) = change(rng, &w[0], &cur, &format!("c{n}"));
            body.push_str(&format!("  {line}\n"));
            effects.push(e);
            cur = format!("%c{n}");
        }
        body.push_str(&format!("  %v{} = bitcast {} {cur} to {}\n", n + 1, w[0].text, w[1].text));
        cur = format!("%v{}", n + 1);
    }
    let end = chain.last().unwrap();
    if rng.below(2) == 0 {
        let (line, e) = change(rng, end, &cur, "cz");
        body.push_str(&format!("  {line}\n"));
        effects.push(e);
        cur = "%cz".into();
    }
    body.push_str(&format!("  store {} {cur}, ptr %out, align 1\n  ret void\n", end.text));
    Func { text: format!("define void @f{k}(ptr %in, ptr %out) {{\n{body}}}\n"), bytes: (bits / 8) as usize, effects }
}

fn run(cmd: &mut Command) -> String {
    let out = cmd.output().unwrap_or_else(|e| panic!("{cmd:?}: {e}"));
    assert!(out.status.success(), "{cmd:?}:\n{}", String::from_utf8_lossy(&out.stderr));
    String::from_utf8_lossy(&out.stdout).into_owned()
}

const RUNS: usize = 4;
const SEED_C: u64 = 88172645463325252;

#[test]
fn random_bitcast_chains() {
    let ok = cfg!(target_arch = "aarch64")
        && cfg!(target_os = "macos")
        && Command::new("clang").arg("--version").output().is_ok_and(|o| o.status.success());
    if !ok {
        eprintln!("needs clang on an AArch64 Mac; skipping");
        return;
    }
    let seed = std::env::var("EPITOME_BITCAST_SEED").ok().and_then(|s| s.parse().ok()).unwrap_or(0x5eed_b17c_a57u64);
    let count = std::env::var("EPITOME_BITCAST_COUNT").ok().and_then(|s| s.parse().ok()).unwrap_or(400);
    let mut rng = Rng(seed | 1);
    let funcs: Vec<Func> = (0..count).map(|k| function(&mut rng, k)).collect();
    let ll = |keep: &dyn Fn(usize) -> bool| -> String {
        let text: String = funcs.iter().enumerate().filter(|(k, _)| keep(*k)).map(|(_, f)| f.text.as_str()).collect();
        format!("target triple = \"arm64-apple-macosx14.0.0\"\n{text}")
    };
    let tmp = std::path::PathBuf::from(env!("CARGO_TARGET_TMPDIR")).join("bitcasts");
    std::fs::create_dir_all(&tmp).unwrap();
    let all_ll = ll(&|_| true);
    std::fs::write(tmp.join("chains.ll"), &all_ll).unwrap();

    // Ours, each function that compiles.
    let t = Target::aarch64();
    let mut m = epitome_ir::parse_module(&all_ll).unwrap();
    let opts = Options { keep_going: true, ..Options::default() };
    let compiled = compile(&t, &mut m, &opts).unwrap();
    let mut failed: BTreeMap<String, Vec<usize>> = BTreeMap::new();
    let mut ours_ok = vec![true; count];
    for e in &compiled.errors {
        let Some(rest) = e.strip_prefix("@f") else { continue };
        let (k, why) = rest.split_once(':').unwrap_or((rest, ""));
        let Ok(k) = k.parse::<usize>() else { continue };
        ours_ok[k] = false;
        let why: String = why.trim().chars().take(90).collect();
        failed.entry(why).or_default().push(k);
    }
    std::fs::write(tmp.join("ours.o"), compiled.object_file(&t).unwrap()).unwrap();

    // clang's, without what its back end cannot compile (it stops at the
    // first and names it).
    let mut llvm_fails: Vec<usize> = Vec::new();
    loop {
        std::fs::write(tmp.join("ref.ll"), ll(&|k| !llvm_fails.contains(&k))).unwrap();
        let out = Command::new("clang")
            .args(["-c", "-O0", "-Wno-override-module"])
            .arg(tmp.join("ref.ll"))
            .arg("-o")
            .arg(tmp.join("ref.o"))
            .output()
            .unwrap();
        if out.status.success() {
            break;
        }
        let err = String::from_utf8_lossy(&out.stderr);
        let k = err
            .lines()
            .find_map(|l| l.trim().strip_prefix("In function: f").and_then(|k| k.parse::<usize>().ok()))
            .unwrap_or_else(|| panic!("clang failed:\n{err}"));
        llvm_fails.push(k);
    }

    // A main calling each it has on the inputs, printing the bytes written;
    // the expected bytes, from the same inputs.
    let driver = |name: &str, has: &dyn Fn(usize) -> bool| -> String {
        let mut main = String::from("#include <stdio.h>\n#include <string.h>\n#include <stdint.h>\n");
        for k in (0..count).filter(|&k| has(k)) {
            main.push_str(&format!("void f{k}(const void *, void *);\n"));
        }
        main.push_str(&format!(
            "static uint64_t s = {SEED_C}ull;\nstatic uint64_t next(void) {{ s ^= s << 13; s ^= s >> 7; s ^= s << 17; return s; }}\n\
             int main(void) {{\n  unsigned char in[32], out[32];\n"
        ));
        for (k, f) in funcs.iter().enumerate() {
            main.push_str(&format!(
                "  for (int r = 0; r < {RUNS}; r++) {{\n    for (int i = 0; i < 32; i++) in[i] = (unsigned char)next();\n"
            ));
            if has(k) {
                main.push_str(&format!(
                    "    memset(out, 0, 32);\n    f{k}(in, out);\n    printf(\"{k}:\");\n    \
                     for (int i = 0; i < {}; i++) printf(\"%02x\", out[i]);\n    printf(\"\\n\");\n",
                    f.bytes
                ));
            }
            main.push_str("  }\n");
        }
        main.push_str("  return 0;\n}\n");
        std::fs::write(tmp.join(format!("{name}.c")), main).unwrap();
        run(Command::new("clang")
            .arg(tmp.join(format!("{name}.o")))
            .arg(tmp.join(format!("{name}.c")))
            .arg("-o")
            .arg(tmp.join(name)));
        run(&mut Command::new(tmp.join(name)))
    };
    let ours = driver("ours", &|k| ours_ok[k]);
    let theirs = driver("ref", &|k| !llvm_fails.contains(&k));
    let mut expected: BTreeMap<usize, Vec<String>> = BTreeMap::new();
    let mut s = Rng(SEED_C);
    for (k, f) in funcs.iter().enumerate() {
        for _ in 0..RUNS {
            let input: Vec<u8> = (0..32).map(|_| s.next() as u8).collect();
            let mut b = input[..f.bytes].to_vec();
            for e in &f.effects {
                e.apply(&mut b);
            }
            expected.entry(k).or_default().push(b.iter().map(|x| format!("{x:02x}")).collect());
        }
    }
    let differing = |printed: &str| -> Vec<usize> {
        let mut seen: BTreeMap<usize, usize> = BTreeMap::new();
        let mut wrong = Vec::new();
        for line in printed.lines() {
            let (k, bytes) = line.split_once(':').unwrap();
            let k: usize = k.parse().unwrap();
            let run = seen.entry(k).or_default();
            if expected[&k][*run] != bytes && !wrong.contains(&k) {
                wrong.push(k);
            }
            *run += 1;
        }
        wrong
    };
    let wrong = differing(&ours);
    let llvm_wrong = differing(&theirs);
    if !llvm_fails.is_empty() || !llvm_wrong.is_empty() {
        eprintln!(
            "clang, for comparison: cannot compile {llvm_fails:?}; wrong for {llvm_wrong:?} (we are not compared with it)"
        );
    }
    let mut report = String::new();
    for (why, ks) in &failed {
        report.push_str(&format!("not compiled ({}): {why}\n  e.g.\n{}", ks.len(), funcs[ks[0]].text));
    }
    for &k in wrong.iter().take(10) {
        report.push_str(&format!("wrong result:\n{}", funcs[k].text));
    }
    assert!(
        failed.is_empty() && wrong.is_empty(),
        "{} of {count} not compiled, {} wrong:\n{report}",
        ours_ok.iter().filter(|&&o| !o).count(),
        wrong.len()
    );
}
