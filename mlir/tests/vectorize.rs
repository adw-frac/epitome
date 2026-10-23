//! Element-wise operations and reductions on vectors: `linalg.generic`s as
//! a language model has them (a row's sum and maximum, `exp`, a row scaled
//! by a column), lowered with `linalg-vectorize=4` and
//! `math-polynomial-approximation` and compiled for AArch64. The code must
//! use NEON's vector instructions, and, on an AArch64 Mac, a Rust driver
//! linked with it must get what a plain loop does.

use std::path::PathBuf;
use std::process::Command;

use epitome_codegen::target::Target;
use epitome_codegen::{Options, compile};

const FUNCS: &str = r#""builtin.module"() ({
  "func.func"() <{function_type = (tensor<8x16xf32>) -> tensor<8x1xf32>, sym_name = "sums"}> ({
  ^bb0(%x: tensor<8x16xf32>):
    %zero = arith.constant 0.000000e+00 : f32
    %e = "tensor.empty"() : () -> tensor<8x1xf32>
    %f = "linalg.fill"(%zero, %e) <{operandSegmentSizes = array<i32: 1, 1>}> ({
    ^bb0(%a: f32, %b: f32):
      linalg.yield %a : f32
    }) : (f32, tensor<8x1xf32>) -> tensor<8x1xf32>
    %r = "linalg.generic"(%x, %f) <{indexing_maps = [affine_map<(d0, d1) -> (d0, d1)>, affine_map<(d0, d1) -> (d0, 0)>], iterator_types = [#linalg.iterator_type<parallel>, #linalg.iterator_type<reduction>], operandSegmentSizes = array<i32: 1, 1>}> ({
    ^bb0(%a: f32, %acc: f32):
      %s = arith.addf %a, %acc : f32
      linalg.yield %s : f32
    }) : (tensor<8x16xf32>, tensor<8x1xf32>) -> tensor<8x1xf32>
    return %r : tensor<8x1xf32>
  }) : () -> ()
  "func.func"() <{function_type = (tensor<8x16xf32>) -> tensor<8x1xf32>, sym_name = "maxes"}> ({
  ^bb0(%x: tensor<8x16xf32>):
    %low = arith.constant -3.40282347E+38 : f32
    %e = "tensor.empty"() : () -> tensor<8x1xf32>
    %f = "linalg.fill"(%low, %e) <{operandSegmentSizes = array<i32: 1, 1>}> ({
    ^bb0(%a: f32, %b: f32):
      linalg.yield %a : f32
    }) : (f32, tensor<8x1xf32>) -> tensor<8x1xf32>
    %r = "linalg.generic"(%x, %f) <{indexing_maps = [affine_map<(d0, d1) -> (d0, d1)>, affine_map<(d0, d1) -> (d0, 0)>], iterator_types = [#linalg.iterator_type<parallel>, #linalg.iterator_type<reduction>], operandSegmentSizes = array<i32: 1, 1>}> ({
    ^bb0(%a: f32, %acc: f32):
      %s = arith.maximumf %a, %acc : f32
      linalg.yield %s : f32
    }) : (tensor<8x16xf32>, tensor<8x1xf32>) -> tensor<8x1xf32>
    return %r : tensor<8x1xf32>
  }) : () -> ()
  "func.func"() <{function_type = (tensor<8x16xf32>) -> tensor<8x16xf32>, sym_name = "exps"}> ({
  ^bb0(%x: tensor<8x16xf32>):
    %e = "tensor.empty"() : () -> tensor<8x16xf32>
    %r = "linalg.generic"(%x, %e) <{indexing_maps = [affine_map<(d0, d1) -> (d0, d1)>, affine_map<(d0, d1) -> (d0, d1)>], iterator_types = [#linalg.iterator_type<parallel>, #linalg.iterator_type<parallel>], operandSegmentSizes = array<i32: 1, 1>}> ({
    ^bb0(%a: f32, %b: f32):
      %s = "math.exp"(%a) <{fastmath = #arith.fastmath<none>}> : (f32) -> f32
      linalg.yield %s : f32
    }) : (tensor<8x16xf32>, tensor<8x16xf32>) -> tensor<8x16xf32>
    return %r : tensor<8x16xf32>
  }) : () -> ()
  "func.func"() <{function_type = (tensor<8x16xf32>) -> tensor<8x16xf32>, sym_name = "tanhs"}> ({
  ^bb0(%x: tensor<8x16xf32>):
    %e = "tensor.empty"() : () -> tensor<8x16xf32>
    %r = "linalg.generic"(%x, %e) <{indexing_maps = [affine_map<(d0, d1) -> (d0, d1)>, affine_map<(d0, d1) -> (d0, d1)>], iterator_types = [#linalg.iterator_type<parallel>, #linalg.iterator_type<parallel>], operandSegmentSizes = array<i32: 1, 1>}> ({
    ^bb0(%a: f32, %b: f32):
      %s = "math.tanh"(%a) <{fastmath = #arith.fastmath<none>}> : (f32) -> f32
      linalg.yield %s : f32
    }) : (tensor<8x16xf32>, tensor<8x16xf32>) -> tensor<8x16xf32>
    return %r : tensor<8x16xf32>
  }) : () -> ()
  "func.func"() <{function_type = (tensor<8x16xf32>, tensor<8x1xf32>) -> tensor<8x16xf32>, sym_name = "scaled"}> ({
  ^bb0(%x: tensor<8x16xf32>, %y: tensor<8x1xf32>):
    %e = "tensor.empty"() : () -> tensor<8x16xf32>
    %r = "linalg.generic"(%x, %y, %e) <{indexing_maps = [affine_map<(d0, d1) -> (d0, d1)>, affine_map<(d0, d1) -> (d0, 0)>, affine_map<(d0, d1) -> (d0, d1)>], iterator_types = [#linalg.iterator_type<parallel>, #linalg.iterator_type<parallel>], operandSegmentSizes = array<i32: 2, 1>}> ({
    ^bb0(%a: f32, %b: f32, %c: f32):
      %s = arith.mulf %a, %b : f32
      linalg.yield %s : f32
    }) : (tensor<8x16xf32>, tensor<8x1xf32>, tensor<8x16xf32>) -> tensor<8x16xf32>
    return %r : tensor<8x16xf32>
  }) : () -> ()
}) : () -> ()
"#;

const DRIVER: &str = r#"
unsafe extern "C" {
    fn sums(x: *const f32, r: *mut f32);
    fn maxes(x: *const f32, r: *mut f32);
    fn exps(x: *const f32, r: *mut f32);
    fn tanhs(x: *const f32, r: *mut f32);
    fn scaled(x: *const f32, y: *const f32, r: *mut f32);
}
fn check(what: &str, got: &[f32], want: &[f32], tolerance: f32) {
    for (i, (g, w)) in got.iter().zip(want).enumerate() {
        if !((g - w).abs() <= tolerance * w.abs().max(1e-30)) {
            println!("{what}[{i}] is {g}, should be {w}");
            std::process::exit(1);
        }
    }
}
fn main() {
    let x: Vec<f32> = (0..128).map(|i| ((i * 37 % 101) as f32 - 50.0) / 7.0).collect();
    let y: Vec<f32> = (0..8).map(|i| i as f32 - 3.5).collect();
    let mut r = vec![f32::NAN; 128];
    unsafe { sums(x.as_ptr(), r.as_mut_ptr()) };
    let want: Vec<f32> = x.chunks(16).map(|c| c.iter().sum()).collect();
    check("sums", &r[..8], &want, 1e-5);
    unsafe { maxes(x.as_ptr(), r.as_mut_ptr()) };
    let want: Vec<f32> = x.chunks(16).map(|c| c.iter().copied().fold(f32::MIN, f32::max)).collect();
    check("maxes", &r[..8], &want, 0.0);
    unsafe { exps(x.as_ptr(), r.as_mut_ptr()) };
    let want: Vec<f32> = x.iter().map(|v| v.exp()).collect();
    check("exps", &r, &want, 3e-7);
    // tanh, and of values 16 times smaller, which its series does.
    for scale in [1.0f32, 1.0 / 16.0] {
        let xs: Vec<f32> = x.iter().map(|v| v * scale).collect();
        unsafe { tanhs(xs.as_ptr(), r.as_mut_ptr()) };
        let want: Vec<f32> = xs.iter().map(|v| v.tanh()).collect();
        check("tanhs", &r, &want, 5e-7);
    }
    unsafe { scaled(x.as_ptr(), y.as_ptr(), r.as_mut_ptr()) };
    let want: Vec<f32> = (0..128).map(|i| x[i] * y[i / 16]).collect();
    check("scaled", &r, &want, 0.0);
    println!("ok");
}
"#;

#[test]
fn vectorized_elementwise_and_reductions() {
    let mut m = epitome_mlir::parse_module(FUNCS).unwrap();
    let passes = [
        "linalg-generalize-named-ops",
        "bufferize",
        "linalg-vectorize=4",
        "linalg-to-loops",
        "math-polynomial-approximation",
        "to-llvm",
    ];
    for pass in passes {
        m = epitome_mlir::run_pass(pass, &m).unwrap_or_else(|e| panic!("{pass}: {e}"));
        let text = m.to_string();
        if pass == "linalg-vectorize=4" {
            // Every operation but the fills vectorized.
            assert_eq!(text.matches("\"linalg.generic\"").count(), 0, "{text}");
            assert!(text.contains("\"vector.reduction\""), "{text}");
            assert!(text.contains("kind = #vector.kind<maximumf>"), "{text}");
        }
        if pass == "math-polynomial-approximation" {
            assert!(!text.contains("math.exp") && !text.contains("math.tanh"), "{text}");
        }
    }
    let mut ir = epitome_mlir::translate::translate(&m).unwrap();
    ir.triple = Some(b"arm64-apple-macosx14.0.0".to_vec());
    epitome_opt::pipeline::run(&mut ir, &epitome_opt::pipeline::Options::default());
    let tmp = PathBuf::from(env!("CARGO_TARGET_TMPDIR")).join("vectorize");
    std::fs::create_dir_all(&tmp).unwrap();
    std::fs::write(tmp.join("funcs.ll"), ir.to_string()).unwrap();
    let t = Target::aarch64();
    let compiled = compile(&t, &mut ir, &Options::default()).unwrap();
    for word in ["fadd v", "fmax v", "fmul v"] {
        assert!(compiled.asm.contains(word), "no {word} in:\n{}", compiled.asm);
    }
    assert!(!compiled.asm.contains("expf") && !compiled.asm.contains("tanhf"), "a call to libm:\n{}", compiled.asm);

    let rustc = Command::new("rustc").arg("--version").output().is_ok_and(|o| o.status.success());
    if !(cfg!(target_arch = "aarch64") && cfg!(target_os = "macos")) || !rustc {
        eprintln!("needs an AArch64 Mac, and rustc, to run; skipping that");
        return;
    }
    let obj = tmp.join("funcs.o");
    std::fs::write(&obj, compiled.object_file(&t).unwrap()).unwrap();
    // (And the assembly, to read when it fails.)
    std::fs::write(tmp.join("funcs.s"), &compiled.asm).unwrap();
    std::fs::write(tmp.join("main.rs"), DRIVER).unwrap();
    let exe = tmp.join("funcs");
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
