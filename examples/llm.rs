//! A language model from Hugging Face, compiled by Epitome into an
//! executable that writes text: for AArch64 macOS (Mach-O) or x86-64 Linux
//! (ELF), whichever this runs on.
//!
//! The model (TinyStories-1M, SmolLM2-135M, ...) is exported from PyTorch as
//! MLIR by `examples/llm/export.py` (`linalg` on tensors, as torch-mlir
//! lowers it). This program takes it the rest of the way, every stage in
//! Epitome:
//!
//! 1. `linalg-generalize-named-ops`, `bufferize`, `linalg-to-loops` and
//!    `to-llvm`: MLIR from `linalg` to the `llvm` dialect;
//! 2. translation to LLVM IR;
//! 3. `epitome-opt`'s pipeline;
//! 4. code generation for AArch64 or x86-64, to an object, `model.o`;
//!
//! then links it with the Rust program in `examples/llm/driver.rs`, which
//! tokenizes a prompt and runs the model to choose each next token.
//!
//! With `--sme`, matrix products go to the SME kernels of
//! `mlir/targets/aarch64-sme.mlir` (`linalg-to-kernels`, after `bufferize`),
//! and the code generator targets `apple-m4`; without it, they are loops.
//! Element-wise work and reductions are vectorized for NEON
//! (`linalg-vectorize=4`), and `exp` and `tanh` are arithmetic rather than
//! calls (`math-polynomial-approximation`), either way.
//!
//! On x86-64 the code generator targets AVX2 and FMA, vectors of eight
//! (`linalg-vectorize=8`); `--avx512` is `--sme`'s counterpart, matrix
//! products by the kernels of `mlir/targets/x86-avx512.mlir`, which need
//! AVX-512 and AVX512-BF16 and so `--weights=bf16`; only they use them.
//!
//! Operations are split among threads, their memory first
//! (`linalg-split=16:4`, a product's rows at least the kernels' tile's),
//! the large products of weights as tensor parallelism splits them (by
//! their columns, or by the columns they sum over, each thread its own
//! part of the weights), by `__epitome_parallel_for`, which the driver
//! provides (`EPITOME_THREADS` threads, by default one a core, up to 16).
//! `--chunks=N` splits them into up to N chunks rather than 16, for as many
//! threads.
//!
//! `--weights=bf16` (with `--sme` or `--avx512`) stores constant weights in that format,
//! rounding them, for the kernels of that format; the program is then
//! `llm-bf16`, and so on, so that the formats can be compared.
//! `--dump` writes each stage's MLIR and the LLVM IR next to the model.
//! Weights of more than a gigabyte (or any, with `--weights-file`) go in a
//! file of their own beside the program, `weights.bin` (`weights-bf16.bin`
//! for `llm-bf16`), which the driver loads, rather than in the program.
//!
//! ```sh
//! python examples/llm/export.py --model HuggingFaceTB/SmolLM2-135M target/smollm2   # torch-mlir's Python
//! cargo run --release --example llm -- target/smollm2 --sme
//! target/smollm2/llm "Once upon a time, there was a little dog called"
//! target/smollm2/llm --bench 5   # time forward passes
//! ```
//!
//! On an AArch64 Mac or an x86-64 Linux machine, with `rustc` to build the
//! driver.

use std::path::{Path, PathBuf};
use std::process::{Command, ExitCode};
use std::time::Instant;

use epitome_codegen::target::Target;
use epitome_codegen::{Options, compile};

fn main() -> ExitCode {
    let args: Vec<String> = std::env::args().skip(1).collect();
    let dump = args.iter().any(|a| a == "--dump");
    let file = args.iter().any(|a| a == "--weights-file");
    let sme = args.iter().any(|a| a == "--sme" || a == "--avx512");
    let weights = args.iter().find_map(|a| a.strip_prefix("--weights=")).map(str::to_string);
    let chunks = args.iter().find_map(|a| a.strip_prefix("--chunks=")).and_then(|c| c.parse().ok()).unwrap_or(16);
    let dir = args
        .iter()
        .find(|a| !a.starts_with("--"))
        .map(PathBuf::from)
        .unwrap_or_else(|| Path::new(env!("CARGO_MANIFEST_DIR")).join("target/llm"));
    match build(&dir, dump, sme, weights.as_deref(), file, chunks) {
        Ok(exe) => {
            println!("built {}", exe.display());
            ExitCode::SUCCESS
        }
        Err(e) => {
            eprintln!("llm: {e}");
            ExitCode::FAILURE
        }
    }
}

fn build(dir: &Path, dump: bool, sme: bool, weights: Option<&str>, file: bool, chunks: u32) -> Result<PathBuf, String> {
    let step = |what: &str, start: Instant| println!("{what:<34} {:>6.2} s", start.elapsed().as_secs_f64());

    let path = dir.join("model.mlir");
    let start = Instant::now();
    let src = std::fs::read_to_string(&path)
        .map_err(|e| format!("{}: {e} (run examples/llm/export.py first)", path.display()))?;
    let mut m = epitome_mlir::parse_module(&src).map_err(|e| format!("{}:{e}", path.display()))?;
    drop(src);
    step("read MLIR (linalg on tensors)", start);

    // MLIR, stage by stage, to the llvm dialect.
    let x86 = cfg!(target_arch = "x86_64");
    let set = if x86 { "x86-avx512" } else { "aarch64-sme" };
    let kernels = match weights {
        Some(w) => format!("linalg-to-kernels={set}:{w}"),
        None => format!("linalg-to-kernels={set}"),
    };
    // Large products that linalg-split leaves (of no constant weights) split
    // among the driver's threads.
    let kernels = format!("{kernels}:parallel");
    let suffix = weights.map(|w| format!("-{w}")).unwrap_or_default();
    let mut passes: Vec<&str> = epitome_mlir::LINALG_TO_LLVM.to_vec();
    let mut at = passes.iter().position(|&p| p == "bufferize").unwrap() + 1;
    // Operations split among the driver's threads, in chunks of memory of
    // their own; large products of weights by their columns (whole panels
    // of 64, as the kernels pack them) or by those they sum over.
    // (Another product's rows at least as many as a tile of the kernels':
    // four for AVX-512's, 64 for SME's.)
    let split = format!("linalg-split={chunks}:{}", if x86 { 4 } else { 64 });
    passes.insert(at, split.as_str());
    at += 1;
    if sme {
        passes.insert(at, kernels.as_str());
        at += 1;
    }
    // Each linalg operation a function of its own: registers allocated
    // far better than in one huge function, and a profiler tells them apart.
    passes.insert(at, "outline-linalg");
    // Element-wise work and reductions on NEON's four lanes, and exp as
    // arithmetic, so that it is vectorized too.
    passes.insert(at + 1, if x86 { "linalg-vectorize=8" } else { "linalg-vectorize=4" });
    let at = passes.iter().position(|&p| p == "to-llvm").unwrap();
    passes.insert(at, "math-polynomial-approximation");
    for (k, pass) in passes.iter().enumerate() {
        if *pass == "to-llvm" {
            // A model of more than a gigabyte of weights: they go in a file of
            // their own, which the driver loads (an executable's code reaches
            // its data only within 2 GB of itself on x86-64).
            let start = Instant::now();
            let (out, weights) = epitome_mlir::weights::externalize(&m, 1 << 20)?;
            if file || weights.len() >= 1 << 30 {
                m = out;
                let file = dir.join(format!("weights{suffix}.bin"));
                std::fs::write(&file, &weights).map_err(|e| format!("{}: {e}", file.display()))?;
                step(&format!("weights to {}", file.display()), start);
            }
        }
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
    ir.triple = Some(if x86 { b"x86_64-unknown-linux-gnu".to_vec() } else { b"arm64-apple-macosx14.0.0".to_vec() });
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
    let (t, opts) = if x86 {
        (Target::x86_64(), Options { mattr: vec!["+avx2,+fma".to_string()], ..Options::default() })
    } else {
        (Target::aarch64(), Options { mcpu: sme.then(|| "apple-m4".to_string()), ..Options::default() })
    };
    let compiled = compile(&t, &mut ir, &opts)?;
    let object = dir.join(format!("model{suffix}.o"));
    std::fs::write(&object, compiled.object_file(&t)?).map_err(|e| format!("{}: {e}", object.display()))?;
    step(if x86 { "compile to model.o (ELF)" } else { "compile to model.o (Mach-O)" }, start);

    // The driver, linked with the model.
    let start = Instant::now();
    let driver = Path::new(env!("CARGO_MANIFEST_DIR")).join("examples/llm/driver.rs");
    let exe = dir.join(format!("llm{suffix}"));
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
