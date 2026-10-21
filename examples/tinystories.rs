//! A language model from Hugging Face, compiled by Epitome into a Mach-O
//! executable that writes stories.
//!
//! TinyStories-1M is exported from PyTorch as MLIR by
//! `examples/tinystories/export.py` (`linalg` on tensors, as torch-mlir
//! lowers it). This program takes it the rest of the way, every stage in
//! Epitome:
//!
//! 1. `linalg-generalize-named-ops`, `bufferize`, `linalg-to-loops` and
//!    `to-llvm`: MLIR from `linalg` to the `llvm` dialect;
//! 2. translation to LLVM IR;
//! 3. `epitome-opt`'s pipeline;
//! 4. code generation for AArch64, to a Mach-O object, `model.o`;
//!
//! With `--sme`, matrix products go to the SME kernels of
//! `mlir/targets/aarch64-sme.mlir` (`linalg-to-kernels`, after
//! `bufferize`), and the code generator targets `apple-m4`.
//!
//! then links it with the Rust program in `examples/tinystories/driver.rs`,
//! which tokenizes a prompt and runs the model to choose each next token.
//!
//! ```sh
//! python examples/tinystories/export.py target/tinystories   # torch-mlir's Python
//! cargo run --release --example tinystories                   # add --dump for each stage's MLIR
//! cargo run --release --example tinystories -- --sme          # matrix products on SME (Apple M4)
//! target/tinystories/tinystories "Once upon a time, there was a little dog called"
//! ```
//!
//! On an AArch64 Mac, with `rustc` to build the driver.

use std::path::{Path, PathBuf};
use std::process::{Command, ExitCode};
use std::time::Instant;

use epitome_codegen::target::Target;
use epitome_codegen::{Options, compile};

fn main() -> ExitCode {
    let args: Vec<String> = std::env::args().skip(1).collect();
    let dump = args.iter().any(|a| a == "--dump");
    let sme = args.iter().any(|a| a == "--sme");
    let dir = args
        .iter()
        .find(|a| !a.starts_with("--"))
        .map(PathBuf::from)
        .unwrap_or_else(|| Path::new(env!("CARGO_MANIFEST_DIR")).join("target/tinystories"));
    match build(&dir, dump, sme) {
        Ok(exe) => {
            println!("built {}", exe.display());
            ExitCode::SUCCESS
        }
        Err(e) => {
            eprintln!("tinystories: {e}");
            ExitCode::FAILURE
        }
    }
}

fn build(dir: &Path, dump: bool, sme: bool) -> Result<PathBuf, String> {
    let step = |what: &str, start: Instant| println!("{what:<34} {:>6.2} s", start.elapsed().as_secs_f64());

    let path = dir.join("model.mlir");
    let start = Instant::now();
    let src = std::fs::read_to_string(&path)
        .map_err(|e| format!("{}: {e} (run examples/tinystories/export.py first)", path.display()))?;
    let mut m = epitome_mlir::parse_module(&src).map_err(|e| format!("{}:{e}", path.display()))?;
    drop(src);
    step("read MLIR (linalg on tensors)", start);

    // MLIR, stage by stage, to the llvm dialect.
    let mut passes: Vec<&str> = epitome_mlir::LINALG_TO_LLVM.to_vec();
    if sme {
        let at = passes.iter().position(|&p| p == "bufferize").unwrap() + 1;
        passes.insert(at, "linalg-to-kernels=aarch64-sme");
    }
    for (k, pass) in passes.iter().enumerate() {
        let start = Instant::now();
        m = epitome_mlir::run_pass(pass, &m).map_err(|e| format!("{pass}: {e}"))?;
        step(pass, start);
        if dump {
            let out = dir.join(format!("stage{}-{pass}.mlir", k + 1));
            std::fs::write(&out, m.to_string()).map_err(|e| format!("{}: {e}", out.display()))?;
        }
    }

    // LLVM IR, optimised.
    let start = Instant::now();
    let mut ir = epitome_mlir::translate::translate(&m).map_err(|e| format!("translate: {e}"))?;
    drop(m);
    ir.triple = Some(b"arm64-apple-macosx14.0.0".to_vec());
    step("translate to LLVM IR", start);
    if dump {
        let out = dir.join("model.ll");
        std::fs::write(&out, ir.to_string()).map_err(|e| format!("{}: {e}", out.display()))?;
    }
    let start = Instant::now();
    epitome_opt::pipeline::run(&mut ir, &epitome_opt::pipeline::Options::default());
    step("optimise", start);

    // Machine code.
    let start = Instant::now();
    let t = Target::aarch64();
    let opts = Options { mcpu: sme.then(|| "apple-m4".to_string()), ..Options::default() };
    let compiled = compile(&t, &mut ir, &opts)?;
    let object = dir.join("model.o");
    std::fs::write(&object, compiled.object_file(&t)?).map_err(|e| format!("{}: {e}", object.display()))?;
    step("compile to model.o (Mach-O)", start);

    // The driver, linked with the model.
    let start = Instant::now();
    let driver = Path::new(env!("CARGO_MANIFEST_DIR")).join("examples/tinystories/driver.rs");
    let exe = dir.join("tinystories");
    let rustc = std::env::var("RUSTC").unwrap_or_else(|_| "rustc".to_string());
    let built = Command::new(&rustc)
        .args(["--edition", "2024", "-O", "-C"])
        .arg(format!("link-arg={}", object.display()))
        .arg("-o")
        .arg(&exe)
        .arg(&driver)
        .output()
        .map_err(|e| format!("{rustc}: {e}"))?;
    if !built.status.success() {
        return Err(format!("building the driver failed:\n{}", String::from_utf8_lossy(&built.stderr)));
    }
    step("link with the Rust driver", start);
    Ok(exe)
}
