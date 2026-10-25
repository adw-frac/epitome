//! Operations split among threads by `linalg-split`: rows scaled by their
//! sums (an `exp`, a sum and a division, split into different numbers of
//! chunks), a matrix product split by its rows, and a transpose split by
//! the dimension it moves. Compiled for AArch64; on an AArch64 Mac, a Rust
//! driver linked with it, whose `__epitome_parallel_for` runs each chunk
//! on a thread of its own, last first, must get what plain loops do.

use std::path::PathBuf;
use std::process::Command;

use epitome_codegen::target::Target;
use epitome_codegen::{Options, compile};

const FUNCS: &str = r#""builtin.module"() ({
  "func.func"() <{function_type = (tensor<64x64xf32>) -> tensor<64x64xf32>, sym_name = "rows"}> ({
  ^bb0(%x: tensor<64x64xf32>):
    %zero = arith.constant 0.000000e+00 : f32
    %e = "tensor.empty"() : () -> tensor<64x64xf32>
    %ex = "linalg.generic"(%x, %e) <{indexing_maps = [affine_map<(d0, d1) -> (d0, d1)>, affine_map<(d0, d1) -> (d0, d1)>], iterator_types = [#linalg.iterator_type<parallel>, #linalg.iterator_type<parallel>], operandSegmentSizes = array<i32: 1, 1>}> ({
    ^bb0(%a: f32, %b: f32):
      %s = "math.exp"(%a) <{fastmath = #arith.fastmath<none>}> : (f32) -> f32
      linalg.yield %s : f32
    }) : (tensor<64x64xf32>, tensor<64x64xf32>) -> tensor<64x64xf32>
    %e1 = "tensor.empty"() : () -> tensor<64x1xf32>
    %f = "linalg.fill"(%zero, %e1) <{operandSegmentSizes = array<i32: 1, 1>}> ({
    ^bb0(%a: f32, %b: f32):
      linalg.yield %a : f32
    }) : (f32, tensor<64x1xf32>) -> tensor<64x1xf32>
    %sum = "linalg.generic"(%ex, %f) <{indexing_maps = [affine_map<(d0, d1) -> (d0, d1)>, affine_map<(d0, d1) -> (d0, 0)>], iterator_types = [#linalg.iterator_type<parallel>, #linalg.iterator_type<reduction>], operandSegmentSizes = array<i32: 1, 1>}> ({
    ^bb0(%a: f32, %acc: f32):
      %s = arith.addf %a, %acc : f32
      linalg.yield %s : f32
    }) : (tensor<64x64xf32>, tensor<64x1xf32>) -> tensor<64x1xf32>
    %e2 = "tensor.empty"() : () -> tensor<64x64xf32>
    %r = "linalg.generic"(%ex, %sum, %e2) <{indexing_maps = [affine_map<(d0, d1) -> (d0, d1)>, affine_map<(d0, d1) -> (d0, 0)>, affine_map<(d0, d1) -> (d0, d1)>], iterator_types = [#linalg.iterator_type<parallel>, #linalg.iterator_type<parallel>], operandSegmentSizes = array<i32: 2, 1>}> ({
    ^bb0(%a: f32, %b: f32, %c: f32):
      %s = arith.divf %a, %b : f32
      linalg.yield %s : f32
    }) : (tensor<64x64xf32>, tensor<64x1xf32>, tensor<64x64xf32>) -> tensor<64x64xf32>
    return %r : tensor<64x64xf32>
  }) : () -> ()
  "func.func"() <{function_type = (tensor<64x32xf32>, tensor<32x48xf32>) -> tensor<64x48xf32>, sym_name = "product"}> ({
  ^bb0(%a: tensor<64x32xf32>, %b: tensor<32x48xf32>):
    %zero = arith.constant 0.000000e+00 : f32
    %e = "tensor.empty"() : () -> tensor<64x48xf32>
    %f = "linalg.fill"(%zero, %e) <{operandSegmentSizes = array<i32: 1, 1>}> ({
    ^bb0(%x: f32, %y: f32):
      linalg.yield %x : f32
    }) : (f32, tensor<64x48xf32>) -> tensor<64x48xf32>
    %r = "linalg.generic"(%a, %b, %f) <{indexing_maps = [affine_map<(d0, d1, d2) -> (d0, d2)>, affine_map<(d0, d1, d2) -> (d2, d1)>, affine_map<(d0, d1, d2) -> (d0, d1)>], iterator_types = [#linalg.iterator_type<parallel>, #linalg.iterator_type<parallel>, #linalg.iterator_type<reduction>], operandSegmentSizes = array<i32: 2, 1>}> ({
    ^bb0(%x: f32, %y: f32, %acc: f32):
      %m = arith.mulf %x, %y : f32
      %s = arith.addf %acc, %m : f32
      linalg.yield %s : f32
    }) : (tensor<64x32xf32>, tensor<32x48xf32>, tensor<64x48xf32>) -> tensor<64x48xf32>
    return %r : tensor<64x48xf32>
  }) : () -> ()
  "func.func"() <{function_type = (tensor<64x16x4xf32>) -> tensor<16x64x4xf32>, sym_name = "heads"}> ({
  ^bb0(%x: tensor<64x16x4xf32>):
    %e = "tensor.empty"() : () -> tensor<16x64x4xf32>
    %r = "linalg.generic"(%x, %e) <{indexing_maps = [affine_map<(d0, d1, d2) -> (d1, d0, d2)>, affine_map<(d0, d1, d2) -> (d0, d1, d2)>], iterator_types = [#linalg.iterator_type<parallel>, #linalg.iterator_type<parallel>, #linalg.iterator_type<parallel>], operandSegmentSizes = array<i32: 1, 1>}> ({
    ^bb0(%a: f32, %b: f32):
      linalg.yield %a : f32
    }) : (tensor<64x16x4xf32>, tensor<16x64x4xf32>) -> tensor<16x64x4xf32>
    return %r : tensor<16x64x4xf32>
  }) : () -> ()
}) : () -> ()
"#;

const DRIVER: &str = r#"
unsafe extern "C" {
    fn rows(x: *const f32, r: *mut f32);
    fn product(a: *const f32, b: *const f32, r: *mut f32);
    fn heads(x: *const f32, r: *mut f32);
}
static mut CALLS: usize = 0;
/// Each chunk on a thread of its own, the last started first.
#[unsafe(no_mangle)]
pub extern "C" fn __epitome_parallel_for(task: extern "C" fn(*mut u8, i64), context: *mut u8, chunks: i64) {
    unsafe { CALLS += 1 };
    let context = context as usize;
    std::thread::scope(|s| {
        for i in (0..chunks).rev() {
            s.spawn(move || task(context as *mut u8, i));
        }
    });
}
fn check(what: &str, got: &[f32], want: &[f32], tolerance: f32) {
    assert_eq!(got.len(), want.len());
    for (i, (g, w)) in got.iter().zip(want).enumerate() {
        if !((g - w).abs() <= tolerance * w.abs().max(1e-30)) {
            println!("{what}[{i}] is {g}, should be {w}");
            std::process::exit(1);
        }
    }
}
fn main() {
    let x: Vec<f32> = (0..4096).map(|i| ((i * 37 % 101) as f32 - 50.0) / 25.0).collect();
    let mut r = vec![f32::NAN; 4096];
    unsafe { rows(x.as_ptr(), r.as_mut_ptr()) };
    let mut want = Vec::new();
    for row in x.chunks(64) {
        let sum: f32 = row.iter().map(|v| v.exp()).sum();
        want.extend(row.iter().map(|v| v.exp() / sum));
    }
    check("rows", &r, &want, 1e-5);

    let a: Vec<f32> = (0..64 * 32).map(|i| ((i * 13 % 29) as f32 - 14.0) / 8.0).collect();
    let b: Vec<f32> = (0..32 * 48).map(|i| ((i * 7 % 23) as f32 - 11.0) / 8.0).collect();
    let mut r = vec![f32::NAN; 64 * 48];
    unsafe { product(a.as_ptr(), b.as_ptr(), r.as_mut_ptr()) };
    let mut want = vec![0.0f32; 64 * 48];
    for i in 0..64 {
        for j in 0..48 {
            want[i * 48 + j] = (0..32).map(|k| a[i * 32 + k] * b[k * 48 + j]).sum();
        }
    }
    check("product", &r, &want, 1e-5);

    let mut r = vec![f32::NAN; 4096];
    unsafe { heads(x.as_ptr(), r.as_mut_ptr()) };
    let want: Vec<f32> = (0..4096).map(|i| { let (h, p, e) = (i / 256, i / 4 % 64, i % 4); x[p * 64 + h * 4 + e] }).collect();
    check("heads", &r, &want, 0.0);
    if unsafe { CALLS } == 0 {
        println!("nothing split");
        std::process::exit(1);
    }
    println!("ok");
}
"#;

#[test]
fn split_among_threads() {
    let mut m = epitome_mlir::parse_module(FUNCS).unwrap();
    let passes = [
        "linalg-generalize-named-ops",
        "bufferize",
        "linalg-split=16:4",
        "outline-linalg",
        "linalg-vectorize=4",
        "linalg-to-loops",
        "math-polynomial-approximation",
        "to-llvm",
    ];
    for pass in passes {
        m = epitome_mlir::run_pass(pass, &m).unwrap_or_else(|e| panic!("{pass}: {e}"));
        if pass.starts_with("linalg-split") {
            let text = m.to_string();
            // rows: the exp in 16 chunks; the sum's fill and the sum in 4 (16
            // sums are a 64-byte line); the division in 16. The product with
            // its fill, 4 rows a chunk; the transpose, a chunk a head.
            assert_eq!(text.matches("callee = @__epitome_parallel_for").count(), 5, "{text}");
            for name in ["@rows.part0", "@rows.part2", "@product.part3", "@heads.part4"] {
                assert!(text.contains(name), "no {name} in {text}");
            }
            assert!(text.contains("memref<4x48xf32, strided<[48, 1], offset: 0>>"), "{text}");
            assert!(text.contains("memref<1x64x4xf32, strided<[256, 4, 1], offset: 0>>"), "{text}");
        }
    }
    let mut ir = epitome_mlir::translate::translate(&m).unwrap();
    ir.triple = Some(b"arm64-apple-macosx14.0.0".to_vec());
    epitome_opt::pipeline::run(&mut ir, &epitome_opt::pipeline::Options::default());
    let tmp = PathBuf::from(env!("CARGO_TARGET_TMPDIR")).join("split");
    std::fs::create_dir_all(&tmp).unwrap();
    std::fs::write(tmp.join("funcs.ll"), ir.to_string()).unwrap();
    let t = Target::aarch64();
    let compiled = compile(&t, &mut ir, &Options::default()).unwrap();

    let rustc = Command::new("rustc").arg("--version").output().is_ok_and(|o| o.status.success());
    if !(cfg!(target_arch = "aarch64") && cfg!(target_os = "macos")) || !rustc {
        eprintln!("needs an AArch64 Mac, and rustc, to run; skipping that");
        return;
    }
    let obj = tmp.join("funcs.o");
    std::fs::write(&obj, compiled.object_file(&t).unwrap()).unwrap();
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
