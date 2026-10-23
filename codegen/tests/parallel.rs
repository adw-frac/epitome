//! Code generation on many threads, and on big blocks.
//!
//! 1. The output (assembly and object file) is the same on 1 thread as on
//!    8, for the C programs of `tests/programs` and for a module of many
//!    generated functions, for AArch64 and for x86-64.
//! 2. No stage takes time growing faster than a block's size: a block four
//!    times bigger must take well under sixteen times as long in each stage
//!    (linear is four; the bound allows for noise).

use std::fmt::Write;
use std::path::PathBuf;
use std::process::Command;
use std::sync::Mutex;
use std::time::Duration;

use epitome_codegen::target::Target;
use epitome_codegen::{Options, compile, timing};

/// The stages' timings are counted for the whole process, so the tests
/// take turns.
static ONE_AT_A_TIME: Mutex<()> = Mutex::new(());

fn compiled(t: &Target, ll: &str, threads: usize) -> (String, Vec<u8>) {
    let mut m = epitome_ir::parse_module(ll).unwrap();
    let c = compile(t, &mut m, &Options { threads, ..Options::default() }).unwrap();
    let obj = c.object_file(t).unwrap();
    (c.asm, obj)
}

/// `n` functions, each with a loop, memory and a call to a declared
/// function.
fn many_functions(n: usize) -> String {
    let mut s = String::from("target triple = \"arm64-apple-macosx14.0.0\"\n");
    for k in 0..n {
        let _ = write!(
            s,
            "declare i64 @g{k}(i64)
define i64 @f{k}(ptr %p, i64 %n) {{
entry:
  br label %loop
loop:
  %i = phi i64 [ 0, %entry ], [ %i1, %loop ]
  %acc = phi i64 [ {k}, %entry ], [ %acc1, %loop ]
  %g = getelementptr i64, ptr %p, i64 %i
  %x = load i64, ptr %g
  %y = mul i64 %x, {m}
  %acc1 = add i64 %acc, %y
  store i64 %acc1, ptr %g
  %i1 = add i64 %i, 1
  %c = icmp ult i64 %i1, %n
  br i1 %c, label %loop, label %done
done:
  %r = call i64 @g{k}(i64 %acc1)
  ret i64 %r
}}
",
            m = k * 7 + 3
        );
    }
    s
}

#[test]
fn same_output_on_any_number_of_threads() {
    let _turn = ONE_AT_A_TIME.lock().unwrap_or_else(|e| e.into_inner());
    for (t, triple) in [(Target::aarch64(), "arm64-apple-macos14"), (Target::x86_64(), "x86_64-linux-gnu")] {
        same_output_for(&t, triple);
    }
}

fn same_output_for(t: &Target, triple: &str) {
    let mut sources = vec![("many".to_string(), many_functions(300))];
    let have_clang = Command::new("clang").arg("--version").output().is_ok_and(|o| o.status.success());
    if have_clang {
        let dir = PathBuf::from(env!("CARGO_MANIFEST_DIR")).join("tests/programs");
        let tmp = PathBuf::from(env!("CARGO_TARGET_TMPDIR")).join("parallel");
        std::fs::create_dir_all(&tmp).unwrap();
        for e in std::fs::read_dir(&dir).unwrap() {
            let p = e.unwrap().path();
            let name = p.file_name().unwrap().to_string_lossy().into_owned();
            if !name.ends_with(".c") || name.ends_with(".main.c") {
                continue;
            }
            let ll = tmp.join(name.replace(".c", &format!(".{triple}.ll")));
            let ok = Command::new("clang")
                .arg(format!("--target={triple}"))
                .args(["-O2", "-fno-vectorize", "-fno-slp-vectorize", "-S", "-emit-llvm"])
                .arg(&p)
                .arg("-o")
                .arg(&ll)
                .status()
                .is_ok_and(|s| s.success());
            if ok {
                sources.push((name, std::fs::read_to_string(&ll).unwrap()));
            }
        }
    } else {
        eprintln!("no clang: only the generated module");
    }
    for (name, ll) in &sources {
        let one = compiled(t, ll, 1);
        let eight = compiled(t, ll, 8);
        assert!(one.0 == eight.0, "{name} ({triple}): the assembly differs between 1 and 8 threads");
        assert!(one.1 == eight.1, "{name} ({triple}): the object file differs between 1 and 8 threads");
    }
}

/// One block of about `n` instructions: loads, arithmetic using values from
/// anywhere earlier, stores, and a call every hundred.
fn big_block(n: usize) -> String {
    let mut s = String::from(
        "target triple = \"arm64-apple-macosx14.0.0\"\ndeclare i64 @ext(i64)\ndefine i64 @big(ptr %p, ptr %q, i64 %a) {\nentry:\n",
    );
    let mut vals = vec!["%a".to_string()];
    let mut seed = 1u64;
    let mut rand = |k: usize| {
        seed = seed.wrapping_mul(6364136223846793005).wrapping_add(1442695040888963407);
        (seed >> 33) as usize % k
    };
    let ops = ["add", "sub", "xor", "mul", "and", "or"];
    for k in 0..n {
        let v = format!("%v{k}");
        let last = vals.last().unwrap().clone();
        match k % 10 {
            0 | 5 => {
                let _ = writeln!(s, "  %g{k} = getelementptr i64, ptr %p, i64 {k}\n  {v} = load i64, ptr %g{k}");
            }
            9 => {
                let _ = writeln!(s, "  %s{k} = getelementptr i64, ptr %q, i64 {k}\n  store i64 {last}, ptr %s{k}");
                continue;
            }
            7 if k % 100 == 7 => {
                let _ = writeln!(s, "  {v} = call i64 @ext(i64 {last})");
            }
            _ => {
                // Mostly recent values, some from far back (long lives).
                let back = if rand(8) == 0 { rand(vals.len()) } else { rand(vals.len().min(4)) };
                let b = vals[vals.len() - 1 - back].clone();
                let _ = writeln!(s, "  {v} = {} i64 {last}, {b}", ops[k % ops.len()]);
            }
        }
        vals.push(v);
    }
    let _ = writeln!(s, "  ret i64 {}\n}}", vals.last().unwrap());
    s
}

/// Each stage's time compiling `ll`, the best of three runs.
fn stage_times(t: &Target, ll: &str) -> [Duration; 5] {
    let counters = [&timing::PREPARE, &timing::SELECT, &timing::ALLOCATE, &timing::FRAME, &timing::LAYOUT];
    let mut best = [Duration::MAX; 5];
    for _ in 0..3 {
        let before: Vec<u64> = counters.iter().map(|c| timing::get(c)).collect();
        let mut m = epitome_ir::parse_module(ll).unwrap();
        compile(t, &mut m, &Options { threads: 1, ..Options::default() }).unwrap();
        for (k, c) in counters.iter().enumerate() {
            best[k] = best[k].min(Duration::from_nanos(timing::get(c) - before[k]));
        }
    }
    best
}

#[test]
fn big_blocks_take_linear_time() {
    let _turn = ONE_AT_A_TIME.lock().unwrap_or_else(|e| e.into_inner());
    for (name, t) in [("aarch64", Target::aarch64()), ("x86_64", Target::x86_64())] {
        linear_for(name, &t);
    }
}

fn linear_for(target: &str, t: &Target) {
    let (small, large) = (3000, 12000);
    let a = stage_times(t, &big_block(small));
    let b = stage_times(t, &big_block(large));
    let names = ["prepare", "selection", "allocation", "frames", "layout"];
    for k in 0..5 {
        // Stages too quick to time well are not judged.
        if b[k] < Duration::from_millis(5) {
            continue;
        }
        let ratio = b[k].as_secs_f64() / a[k].as_secs_f64().max(1e-6);
        assert!(
            ratio < 10.0,
            "{} ({}): {large} instructions took {:.1}x as long as {small} ({:?} and {:?}); linear is 4x",
            names[k],
            target,
            ratio,
            b[k],
            a[k]
        );
    }
}
