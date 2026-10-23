//! JAX's StableHLO through Epitome: `tests/jax/block.mlir`, an attention
//! block exported by `examples/jax/export.py` (projections, GELU, a leaky
//! ReLU, four heads, a causal softmax), lowered with `stablehlo-to-linalg`
//! and the passes after it, compiled for AArch64, and, on an AArch64 Mac,
//! run by `examples/jax/driver.rs` against JAX's own output
//! (`tests/jax/expected.txt`).

use std::path::{Path, PathBuf};
use std::process::Command;

use epitome_codegen::target::Target;
use epitome_codegen::{Options, compile};

fn fixture(name: &str) -> PathBuf {
    Path::new(env!("CARGO_MANIFEST_DIR")).join("tests/jax").join(name)
}

fn has_sme() -> bool {
    cfg!(target_arch = "aarch64")
        && cfg!(target_os = "macos")
        && Command::new("sysctl")
            .args(["-n", "hw.optional.arm.FEAT_SME"])
            .output()
            .is_ok_and(|o| String::from_utf8_lossy(&o.stdout).trim() == "1")
}

#[test]
fn stablehlo_becomes_linalg() {
    let src = std::fs::read_to_string(fixture("block.mlir")).unwrap();
    let m = epitome_mlir::parse_module(&src).unwrap();
    let m = epitome_mlir::run_pass("stablehlo-to-linalg", &m).unwrap();
    let text = m.to_string();
    assert!(!text.contains("\"stablehlo."), "{text}");
    // jnp.where's private function, inlined and gone.
    assert!(!text.contains("func.call") && !text.contains("@_where"), "{text}");
    // The weights, blobs; the matrix products, with linalg.matmul's maps.
    assert!(text.contains("dense_resource<stablehlo_constant_1>"), "{text}");
    assert!(text.contains("affine_map<(d0, d1, d2) -> (d0, d2)>, affine_map<(d0, d1, d2) -> (d2, d1)>"), "{text}");
    // The heads: batch_matmul's maps.
    assert!(
        text.contains("affine_map<(d0, d1, d2, d3) -> (d0, d1, d3)>, affine_map<(d0, d1, d2, d3) -> (d0, d3, d2)>"),
        "{text}"
    );
    // It prints and reads back.
    epitome_mlir::parse_module(&text).unwrap();
}

#[test]
fn jax_block_matches_jax() {
    let sme = has_sme();
    let mut passes = vec!["stablehlo-to-linalg", "linalg-generalize-named-ops", "linalg-fold-constants", "bufferize"];
    if sme {
        passes.push("linalg-to-kernels=aarch64-sme");
    }
    passes.extend([
        "outline-linalg",
        "linalg-vectorize=4",
        "linalg-to-loops",
        "math-polynomial-approximation",
        "to-llvm",
    ]);
    let src = std::fs::read_to_string(fixture("block.mlir")).unwrap();
    let mut m = epitome_mlir::parse_module(&src).unwrap();
    for pass in passes {
        m = epitome_mlir::run_pass(pass, &m).unwrap_or_else(|e| panic!("{pass}: {e}"));
    }
    let mut ir = epitome_mlir::translate::translate(&m).unwrap();
    ir.triple = Some(b"arm64-apple-macosx14.0.0".to_vec());
    epitome_opt::pipeline::run(&mut ir, &epitome_opt::pipeline::Options::default());
    let t = Target::aarch64();
    let opts = Options { mcpu: sme.then(|| "apple-m4".to_string()), ..Options::default() };
    let compiled = compile(&t, &mut ir, &opts).unwrap();
    if sme {
        assert!(compiled.asm.contains("fmopa za3.s"), "the products are not on SME");
    }

    let rustc = Command::new("rustc").arg("--version").output().is_ok_and(|o| o.status.success());
    if !(cfg!(target_arch = "aarch64") && cfg!(target_os = "macos")) || !rustc {
        eprintln!("needs an AArch64 Mac, and rustc, to run; skipping that");
        return;
    }
    let tmp = PathBuf::from(env!("CARGO_TARGET_TMPDIR")).join("jax");
    std::fs::create_dir_all(&tmp).unwrap();
    for f in ["input.txt", "expected.txt"] {
        std::fs::copy(fixture(f), tmp.join(f)).unwrap();
    }
    let obj = tmp.join("block.o");
    std::fs::write(&obj, compiled.object_file(&t).unwrap()).unwrap();
    let exe = tmp.join("jax");
    let driver = Path::new(env!("CARGO_MANIFEST_DIR")).join("../examples/jax/driver.rs");
    let built = Command::new("rustc")
        .args(["--edition", "2024", "-O", "-C"])
        .arg(format!("link-arg={}", obj.display()))
        .arg("-o")
        .arg(&exe)
        .arg(&driver)
        .output()
        .unwrap();
    assert!(built.status.success(), "{}", String::from_utf8_lossy(&built.stderr));
    let run = Command::new(&exe).output().unwrap();
    let text = String::from_utf8_lossy(&run.stdout);
    assert!(run.status.success(), "{text}");
    // The driver fails beyond 1e-2; f32 throughout should be far closer.
    let line = text.lines().find(|l| l.starts_with("largest difference")).unwrap();
    let rel: f64 = line.split(", ").nth(1).unwrap().split(' ').next().unwrap().parse().unwrap();
    assert!(rel < 1e-5, "{text}");
}
