//! Matrix products on SME: a `linalg.matmul` on tensors, of sizes that are
//! not whole tiles, lowered with `linalg-to-kernels=aarch64-sme` and compiled
//! for `apple-m4`. The code must use the SME kernel (smstart, fmopa), and,
//! on a Mac with SME, a Rust driver linked with it must get the same product
//! as a plain one.

use std::path::PathBuf;
use std::process::Command;

use epitome_codegen::target::Target;
use epitome_codegen::{Options, compile};

const MATMUL: &str = r#""builtin.module"() ({
  "func.func"() <{function_type = (tensor<70x40xf32>, tensor<40x50xf32>) -> tensor<70x50xf32>, sym_name = "mm"}> ({
  ^bb0(%a: tensor<70x40xf32>, %b: tensor<40x50xf32>):
    %zero = arith.constant 0.000000e+00 : f32
    %e = "tensor.empty"() : () -> tensor<70x50xf32>
    %f = "linalg.fill"(%zero, %e) <{operandSegmentSizes = array<i32: 1, 1>}> ({
    ^bb0(%x: f32, %y: f32):
      linalg.yield %x : f32
    }) : (f32, tensor<70x50xf32>) -> tensor<70x50xf32>
    %r = "linalg.matmul"(%a, %b, %f) <{operandSegmentSizes = array<i32: 2, 1>}> ({
    ^bb0(%p: f32, %q: f32, %acc: f32):
      %m = arith.mulf %p, %q : f32
      %s = arith.addf %acc, %m : f32
      linalg.yield %s : f32
    }) : (tensor<70x40xf32>, tensor<40x50xf32>, tensor<70x50xf32>) -> tensor<70x50xf32>
    return %r : tensor<70x50xf32>
  }) : () -> ()
}) : () -> ()
"#;

const DRIVER: &str = r#"
unsafe extern "C" {
    fn mm(a: *const f32, b: *const f32, c: *mut f32);
}
fn main() {
    let (m, k, n) = (70usize, 40usize, 50usize);
    let a: Vec<f32> = (0..m * k).map(|i| ((i * 7 % 11) as f32 - 5.0) / 4.0).collect();
    let b: Vec<f32> = (0..k * n).map(|i| ((i * 5 % 13) as f32 - 6.0) / 8.0).collect();
    let mut c = vec![f32::NAN; m * n];
    let mut want = vec![0f32; m * n];
    for i in 0..m {
        for j in 0..n {
            for kk in 0..k {
                want[i * n + j] += a[i * k + kk] * b[kk * n + j];
            }
        }
    }
    unsafe { mm(a.as_ptr(), b.as_ptr(), c.as_mut_ptr()) };
    for (i, (x, y)) in c.iter().zip(&want).enumerate() {
        if !((x - y).abs() < 1e-3) {
            println!("c[{}][{}] is {x}, should be {y}", i / n, i % n);
            std::process::exit(1);
        }
    }
    println!("ok");
}
"#;

/// Whether this machine runs SME code.
fn has_sme() -> bool {
    cfg!(target_arch = "aarch64")
        && cfg!(target_os = "macos")
        && Command::new("sysctl")
            .args(["-n", "hw.optional.arm.FEAT_SME"])
            .output()
            .is_ok_and(|o| String::from_utf8_lossy(&o.stdout).trim() == "1")
}

#[test]
fn matmul_on_sme_kernels() {
    let mut m = epitome_mlir::parse_module(MATMUL).unwrap();
    let passes =
        ["linalg-generalize-named-ops", "bufferize", "linalg-to-kernels=aarch64-sme", "linalg-to-loops", "to-llvm"];
    for pass in passes {
        m = epitome_mlir::run_pass(pass, &m).unwrap_or_else(|e| panic!("{pass}: {e}"));
        if pass == "linalg-to-kernels=aarch64-sme" {
            let text = m.to_string();
            assert!(text.contains("\"func.call\""), "no call to the kernel:\n{text}");
            assert!(text.contains("sym_name = \"__epitome_sme_matmul_f32\""));
            // The 6 rows past the last whole tile are left to linalg.
            assert!(text.contains("memref<6x50xf32, strided<[50, 1], offset: 3200>>"), "{text}");
        }
    }
    let mut ir = epitome_mlir::translate::translate(&m).unwrap();
    ir.triple = Some(b"arm64-apple-macosx14.0.0".to_vec());
    epitome_opt::pipeline::run(&mut ir, &epitome_opt::pipeline::Options::default());
    let t = Target::aarch64();
    let opts = Options { mcpu: Some("apple-m4".to_string()), ..Options::default() };
    let compiled = compile(&t, &mut ir, &opts).unwrap();
    for word in ["smstart", "fmopa za0.s", "ld1w {za0h.s[w12, 0]}", "st1w {za0h.s[w12, 0]}", "smstop"] {
        assert!(compiled.asm.contains(word), "no {word} in:\n{}", compiled.asm);
    }

    let rustc = Command::new("rustc").arg("--version").output().is_ok_and(|o| o.status.success());
    if !has_sme() || !rustc {
        eprintln!("needs an AArch64 Mac with SME, and rustc, to run; skipping that");
        return;
    }
    let tmp = PathBuf::from(env!("CARGO_TARGET_TMPDIR")).join("sme");
    std::fs::create_dir_all(&tmp).unwrap();
    let obj = tmp.join("mm.o");
    std::fs::write(&obj, compiled.object_file(&t).unwrap()).unwrap();
    std::fs::write(tmp.join("main.rs"), DRIVER).unwrap();
    let exe = tmp.join("mm");
    let built = Command::new("rustc")
        .args(["--edition", "2024", "-O", "-C"])
        .arg(format!("link-arg={}", obj.display()))
        .arg("-o")
        .arg(&exe)
        .arg(tmp.join("main.rs"))
        .output()
        .unwrap();
    assert!(built.status.success(), "{}", String::from_utf8_lossy(&built.stderr));
    let run = Command::new(&exe).output().unwrap();
    assert_eq!(String::from_utf8_lossy(&run.stdout).trim(), "ok", "{}", String::from_utf8_lossy(&run.stdout));
}
