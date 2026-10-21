//! Matrix products on SME: a `linalg.matmul` on tensors, of sizes that are
//! not whole tiles (70 rows: 64 on the four-tile kernel, 6 left to loops; 50
//! columns: the last block 2 wide), lowered with
//! `linalg-to-kernels=aarch64-sme` and compiled for `apple-m4`. The code must use the SME kernel (smstart, fmopa), and,
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
            // 64 rows on the four-tile kernel; the 6 past them, too few for
            // the 16-row one, are left to linalg.
            assert!(text.contains("sym_name = \"__epitome_sme_matmul_f32_64\""), "{text}");
            assert!(text.contains("memref<6x50xf32, strided<[50, 1], offset: 3200>>"), "{text}");
        }
    }
    compile_and_run(
        &m,
        DRIVER,
        "sme",
        &["fmopa za0.s", "fmopa za3.s", "ld1w {za3h.s[w12, 0]}", "st1w {za3h.s[w12, 0]}"],
    );
}

/// Compiles `m` (in the `llvm` dialect) for `apple-m4`, checks it uses the
/// SME kernel, and, on a Mac with SME, links it with `driver` and runs it,
/// which must print "ok".
fn compile_and_run(m: &epitome_mlir::Module, driver: &str, name: &str, words: &[&str]) {
    let mut ir = epitome_mlir::translate::translate(m).unwrap();
    ir.triple = Some(b"arm64-apple-macosx14.0.0".to_vec());
    epitome_opt::pipeline::run(&mut ir, &epitome_opt::pipeline::Options::default());
    let t = Target::aarch64();
    let opts = Options { mcpu: Some("apple-m4".to_string()), ..Options::default() };
    let compiled = compile(&t, &mut ir, &opts).unwrap();
    for word in ["smstart", "smstop"].iter().chain(words) {
        assert!(compiled.asm.contains(word), "no {word} in:\n{}", compiled.asm);
    }

    let rustc = Command::new("rustc").arg("--version").output().is_ok_and(|o| o.status.success());
    if !has_sme() || !rustc {
        eprintln!("needs an AArch64 Mac with SME, and rustc, to run; skipping that");
        return;
    }
    let tmp = PathBuf::from(env!("CARGO_TARGET_TMPDIR")).join(name);
    std::fs::create_dir_all(&tmp).unwrap();
    let obj = tmp.join("mm.o");
    std::fs::write(&obj, compiled.object_file(&t).unwrap()).unwrap();
    std::fs::write(tmp.join("main.rs"), driver).unwrap();
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

/// A 64 x k by k x 128 matrix product whose B is a constant, as a model's
/// weights are, lowered with `linalg-to-kernels=<kernels>`; the module in
/// the `llvm` dialect, and the text after `linalg-to-kernels`.
fn constant_weights(k: usize, kernels: &str) -> (epitome_mlir::Module, String) {
    let n = 128usize;
    let b: Vec<f32> = (0..k * n).map(|i| ((i * 5 % 13) as f32 - 6.0) / 8.0).collect();
    let hex: String = b.iter().flat_map(|f| f.to_le_bytes()).map(|x| format!("{x:02X}")).collect();
    let src = format!(
        r#""builtin.module"() ({{
  "func.func"() <{{function_type = (tensor<64x{k}xf32>) -> tensor<64x128xf32>, sym_name = "mm"}}> ({{
  ^bb0(%a: tensor<64x{k}xf32>):
    %b = "arith.constant"() <{{value = dense_resource<w> : tensor<{k}x128xf32>}}> : () -> tensor<{k}x128xf32>
    %zero = arith.constant 0.000000e+00 : f32
    %e = "tensor.empty"() : () -> tensor<64x128xf32>
    %f = "linalg.fill"(%zero, %e) <{{operandSegmentSizes = array<i32: 1, 1>}}> ({{
    ^bb0(%x: f32, %y: f32):
      linalg.yield %x : f32
    }}) : (f32, tensor<64x128xf32>) -> tensor<64x128xf32>
    %r = "linalg.matmul"(%a, %b, %f) <{{operandSegmentSizes = array<i32: 2, 1>}}> ({{
    ^bb0(%p: f32, %q: f32, %acc: f32):
      %m = arith.mulf %p, %q : f32
      %s = arith.addf %acc, %m : f32
      linalg.yield %s : f32
    }}) : (tensor<64x{k}xf32>, tensor<{k}x128xf32>, tensor<64x128xf32>) -> tensor<64x128xf32>
    return %r : tensor<64x128xf32>
  }}) : () -> ()
}}) : () -> ()
{{-#
  dialect_resources: {{
    builtin: {{
      w: "0x04000000{hex}"
    }}
  }}
#-}}
"#
    );
    let mut m = epitome_mlir::parse_module(&src).unwrap();
    let mut text = String::new();
    let kernels = format!("linalg-to-kernels={kernels}");
    for pass in ["linalg-generalize-named-ops", "bufferize", &kernels, "linalg-to-loops", "to-llvm"] {
        m = epitome_mlir::run_pass(pass, &m).unwrap_or_else(|e| panic!("{pass}: {e}"));
        if pass == kernels {
            text = m.to_string();
        }
    }
    (m, text)
}

/// A driver for `constant_weights`: A and B as there, each rounded with
/// `round` first, and the product within `tolerance` of the sum of
/// absolute products.
fn constant_weights_driver(k: usize, round: &str, tolerance: f32) -> String {
    format!(
        r#"
unsafe extern "C" {{
    fn mm(a: *const f32, c: *mut f32);
}}
fn round(x: f32) -> f32 {{
    {round}
}}
fn main() {{
    let (m, k, n) = (64usize, {k}usize, 128usize);
    let a: Vec<f32> = (0..m * k).map(|i| ((i * 7 % 11) as f32 - 5.0) / 4.3).collect();
    let b: Vec<f32> = (0..k * n).map(|i| ((i * 5 % 13) as f32 - 6.0) / 8.0).collect();
    let mut c = vec![f32::NAN; m * n];
    unsafe {{ mm(a.as_ptr(), c.as_mut_ptr()) }};
    for i in 0..m {{
        for j in 0..n {{
            let want: f32 = (0..k).map(|kk| round(a[i * k + kk]) * round(b[kk * n + j])).sum();
            let size: f32 = (0..k).map(|kk| (a[i * k + kk] * b[kk * n + j]).abs()).sum();
            if !((c[i * n + j] - want).abs() <= {tolerance} * size) {{
                println!("c[{{i}}][{{j}}] is {{}}, should be {{want}}", c[i * n + j]);
                std::process::exit(1);
            }}
        }}
    }}
    println!("ok");
}}
"#
    )
}

/// B a constant, as a model's weights are: packed into panels of 64 columns
/// when compiling, which the kernel reads one after another.
#[test]
fn constant_weights_packed_into_panels() {
    let (k, n) = (40usize, 128usize);
    let (m, text) = constant_weights(k, "aarch64-sme");
    assert!(text.contains("_panels64"), "B is not packed:\n{text}");
    // The weights as they were are no longer needed.
    assert_eq!(text.matches("\"memref.global\"").count(), 1, "{text}");
    let b: Vec<f32> = (0..k * n).map(|i| ((i * 5 % 13) as f32 - 6.0) / 8.0).collect();
    let packed = m.resources().get("w.panels64").unwrap().into_owned();
    let at = |p: usize, r: usize, c: usize| {
        let i = ((p * k + r) * 64 + c) * 4;
        f32::from_le_bytes(packed[i..i + 4].try_into().unwrap())
    };
    assert_eq!(at(1, 3, 5), b[3 * n + 64 + 5]);
    compile_and_run(
        &m,
        &constant_weights_driver(k, "x", 1e-5),
        "sme-packed",
        &["fmopa za0.s", "fmopa za3.s", "ld1w {za3h.s[w12, 0]}", "st1w {za3h.s[w12, 0]}"],
    );
}

/// The same in BF16 (`aarch64-sme:bf16`): B stored in BF16 pairs, A rounded
/// to BF16 in the kernel, products summed in f32 by bfmopa.
#[test]
fn constant_weights_in_bf16() {
    let k = 96;
    let (m, text) = constant_weights(k, "aarch64-sme:bf16");
    assert!(text.contains("@__epitome_sme_matmul_bf16_64"), "{text}");
    assert!(text.contains("_panels64_bf16"), "{text}");
    // Without asking, f32 as before.
    let (_, f32_text) = constant_weights(k, "aarch64-sme");
    assert!(!f32_text.contains("bf16"), "{f32_text}");
    let round = "let b = x.to_bits(); f32::from_bits(((b + 0x7fff + ((b >> 16) & 1)) >> 16) << 16)";
    compile_and_run(
        &m,
        &constant_weights_driver(k, round, 1e-5),
        "sme-bf16",
        &["bfmopa za3.s", "bfcvtnt", "st1w {za0v.s[w12, 0]}"],
    );
}

/// The same in int8 (`aarch64-sme:i8`): B quantised by column when
/// compiling, A by row in the kernel, products summed in 32-bit integers by
/// smopa; within the quantisation's error of the f32 product.
#[test]
fn constant_weights_in_int8() {
    let k = 128;
    let (m, text) = constant_weights(k, "aarch64-sme:i8");
    assert!(text.contains("@__epitome_sme_matmul_i8_64"), "{text}");
    assert!(text.contains("_panels64_i8_scales"), "{text}");
    compile_and_run(&m, &constant_weights_driver(k, "x", 1e-2), "sme-i8", &["smopa za3.s", "fcvtzs", "st1b"]);
}
