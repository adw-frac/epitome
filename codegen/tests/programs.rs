//! Compiles C programs with smaugian-llc and checks they behave as clang's
//! build does, and that the machine code is right.
//!
//! For each `tests/programs/NAME.c` (functions) and `NAME.main.c` (a main
//! that calls them and prints the results), in three configurations of the
//! IR given to smaugian-llc:
//!
//! - `O0`: clang without optimisation, so every variable is in memory;
//! - `opt`: that, through smaugian-opt's pipeline;
//! - `O2`: clang `-O2`, without vectorising or unrolling;
//!
//! the test:
//!
//! 1. builds our assembly with the main and checks the output is the same
//!    as clang's build of both C files;
//! 2. assembles our assembly with clang, and checks each word of the object
//!    code against our own encoder, except where we leave a fixup;
//! 3. disassembles each word with the description and checks it encodes
//!    back to the same word, and that the mnemonic is objdump's, or an
//!    alias of it.
//!
//! The test is skipped when `clang` is not installed.

use std::path::{Path, PathBuf};
use std::process::Command;

use smaugian_codegen::target::Target;
use smaugian_codegen::{Stop, compile, mir};

fn have_tools() -> bool {
    let ok = |c: &str, a: &str| Command::new(c).arg(a).output().is_ok_and(|o| o.status.success());
    ok("clang", "--version") && ok("objdump", "--version")
}

fn run(cmd: &mut Command) -> Result<String, String> {
    let out = cmd.output().map_err(|e| format!("{cmd:?}: {e}"))?;
    if !out.status.success() {
        return Err(format!(
            "{cmd:?} failed:\n{}{}",
            String::from_utf8_lossy(&out.stdout),
            String::from_utf8_lossy(&out.stderr)
        ));
    }
    Ok(String::from_utf8_lossy(&out.stdout).into_owned())
}

/// Mnemonics objdump may print for an instruction we print another way.
const ALIASES: &[(&str, &str)] = &[("add", "mov"), ("mov", "orr"), ("mov", "movz"), ("mov", "movn")];

fn check_program(t: &Target, dir: &Path, tmp: &Path, name: &str) -> Result<Vec<String>, String> {
    let src = dir.join(format!("{name}.c"));
    let main = dir.join(format!("{name}.main.c"));
    let reference_exe = tmp.join(format!("{name}.ref"));
    run(Command::new("clang").arg("-fwrapv").arg(&src).arg(&main).arg("-o").arg(&reference_exe))?;
    let want = run(&mut Command::new(&reference_exe))?;
    let mut report = Vec::new();
    let configs: &[(&str, &[&str])] = &[
        ("O0", &["-O0", "-Xclang", "-disable-O0-optnone"]),
        ("opt", &["-O0", "-Xclang", "-disable-O0-optnone"]),
        ("O2", &["-O2", "-fno-vectorize", "-fno-slp-vectorize", "-fno-unroll-loops"]),
    ];
    for (config, flags) in configs {
        let stem = format!("{name}.{config}");
        let ll = tmp.join(format!("{stem}.ll"));
        run(Command::new("clang").arg("-fwrapv").args(*flags).args(["-S", "-emit-llvm"]).arg(&src).arg("-o").arg(&ll))?;
        let text = std::fs::read_to_string(&ll).unwrap();
        let mut m = smaugian_ir::parse_module(&text).map_err(|e| format!("{stem}: {e:?}"))?;
        if *config == "opt" {
            smaugian_opt::pipeline::run(&mut m, &smaugian_opt::pipeline::Options { threads: 1, ..Default::default() });
            let text = m.to_string();
            m = smaugian_ir::parse_module(&text).map_err(|e| format!("{stem}: reparse: {e:?}"))?;
        }
        let compiled = compile(t, &mut m, Stop::Done).map_err(|e| format!("{stem}: {e}"))?;
        let s = tmp.join(format!("{stem}.s"));
        std::fs::write(&s, &compiled.asm).unwrap();

        // 1. It behaves the same.
        let exe = tmp.join(&stem);
        run(Command::new("clang").arg(&s).arg(&main).arg("-o").arg(&exe))?;
        let got = run(&mut Command::new(&exe))?;
        if got != want {
            return Err(format!("{stem}: output differs from clang's build; see {}", s.display()));
        }

        // 2. Our encoding is the assembler's.
        let obj = tmp.join(format!("{stem}.o"));
        run(Command::new("clang").arg("-c").arg(&s).arg("-o").arg(&obj))?;
        let dump = run(Command::new("objdump").arg("-d").arg(&obj))?;
        let theirs: Vec<(u32, String)> = dump
            .lines()
            .filter_map(|l| {
                let mut it = l.split_whitespace();
                let addr = it.next()?;
                if !addr.ends_with(':') || !addr.trim_end_matches(':').chars().all(|c| c.is_ascii_hexdigit()) {
                    return None;
                }
                let word = u32::from_str_radix(it.next()?, 16).ok()?;
                Some((word, it.next().unwrap_or("").to_string()))
            })
            .collect();
        let mut ours: Vec<(u32, bool)> = Vec::new();
        for f in &compiled.funcs {
            let (words, fixups) = mir::encode_function(t, f)?;
            for (k, w) in words.into_iter().enumerate() {
                ours.push((w, fixups.iter().any(|x| x.offset == 4 * k)));
            }
        }
        if ours.len() != theirs.len() {
            return Err(format!("{stem}: {} words from us, {} from the assembler", ours.len(), theirs.len()));
        }
        for (k, ((w, fixup), (tw, mnemonic))) in ours.iter().zip(&theirs).enumerate() {
            if w != tw && !fixup {
                return Err(format!("{stem}: word {k} is {w:08x}, the assembler's is {tw:08x} ({mnemonic})"));
            }
            // 3. The disassembler reads it back.
            let Some((i, env)) = mir::decode(t, *w) else {
                return Err(format!("{stem}: cannot disassemble {w:08x} ({mnemonic})"));
            };
            let ins = &t.instrs[i];
            if ins.enc.encode(&env) != Some(*w) {
                return Err(format!("{stem}: {w:08x} disassembles as {} but does not encode back", ins.name));
            }
            let ours_mn = ins.asm.split_whitespace().next().unwrap_or("");
            let ours_mn = ours_mn.split('.').next().unwrap();
            let theirs_mn = mnemonic.split('.').next().unwrap();
            if ours_mn != theirs_mn
                && !ALIASES.contains(&(theirs_mn, ours_mn))
                && !ALIASES.contains(&(ours_mn, theirs_mn))
            {
                return Err(format!("{stem}: {w:08x} is {mnemonic} to objdump, {ours_mn} to us"));
            }
        }
        report.push(format!("{stem}: {} instructions", ours.len()));
    }
    Ok(report)
}

#[test]
fn programs_behave_the_same() {
    if !have_tools() {
        eprintln!("clang or objdump not found; skipping");
        return;
    }
    let dir = PathBuf::from(env!("CARGO_MANIFEST_DIR")).join("tests/programs");
    let tmp = PathBuf::from(env!("CARGO_TARGET_TMPDIR")).join("codegen-programs");
    std::fs::create_dir_all(&tmp).unwrap();
    let t = Target::aarch64();
    let mut names: Vec<String> = std::fs::read_dir(&dir)
        .unwrap()
        .filter_map(|e| {
            let p = e.unwrap().path();
            let n = p.file_name()?.to_str()?.to_string();
            (n.ends_with(".c") && !n.ends_with(".main.c")).then(|| n.trim_end_matches(".c").to_string())
        })
        .collect();
    names.sort();
    let mut failures = Vec::new();
    for n in &names {
        match check_program(&t, &dir, &tmp, n) {
            Ok(r) => r.iter().for_each(|l| println!("ok {l}")),
            Err(e) => failures.push(e),
        }
    }
    assert!(failures.is_empty(), "{}", failures.join("\n"));
}
