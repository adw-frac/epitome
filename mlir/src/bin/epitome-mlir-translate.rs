//! `epitome-mlir-translate`: reads MLIR, runs any passes asked for, and
//! writes the `llvm` dialect as LLVM IR, as `mlir-translate
//! --mlir-to-llvmir` does.
//!
//! ```sh
//! # A PyTorch model, as torch-mlir imports it, to LLVM IR.
//! epitome-mlir-translate model.torch.mlir --pass=torch-to-llvm -o model.ll
//! ```

use std::process::ExitCode;

use epitome_ir::io;

#[global_allocator]
static MEMORY: epitome_ir::memlimit::Limited = epitome_ir::memlimit::Limited;

const USAGE: &str = "usage: epitome-mlir-translate <file.mlir | -> [--pass=a,b,...] [-o <file.ll | ->]";

fn main() -> ExitCode {
    epitome_ir::memlimit::set_from_env(4096);
    let mut input = None;
    let mut output = "-".to_string();
    let mut passes: Vec<String> = Vec::new();
    let mut args = std::env::args().skip(1);
    while let Some(arg) = args.next() {
        match arg.as_str() {
            "-o" => match args.next() {
                Some(o) => output = o,
                None => {
                    eprintln!("{USAGE}");
                    return ExitCode::FAILURE;
                }
            },
            // The flag `mlir-translate` takes; translating is all this does.
            "--mlir-to-llvmir" => {}
            _ if arg.starts_with("--pass=") => {
                passes.extend(arg["--pass=".len()..].split(',').filter(|p| !p.is_empty()).map(str::to_string));
            }
            "-h" | "--help" => {
                println!(
                    "{USAGE}\npasses: {}; torch-to-llvm and linalg-to-llvm run them in turn",
                    epitome_mlir::PASSES.join(", ")
                );
                return ExitCode::SUCCESS;
            }
            _ if input.is_none() => input = Some(arg),
            _ => {
                eprintln!("{USAGE}");
                return ExitCode::FAILURE;
            }
        }
    }
    let Some(path) = input else {
        eprintln!("{USAGE}");
        return ExitCode::FAILURE;
    };
    let src = match io::read_to_string(&path) {
        Ok(s) => s,
        Err(e) => {
            eprintln!("{path}: {e}");
            return ExitCode::FAILURE;
        }
    };
    let mut m = match epitome_mlir::parse_module(&src) {
        Ok(m) => m,
        Err(e) => {
            eprintln!("{path}:{e}");
            return ExitCode::FAILURE;
        }
    };
    for pass in &passes {
        m = match epitome_mlir::run_pass(pass, &m) {
            Ok(m) => m,
            Err(e) => {
                eprintln!("{path}: {pass}: {e}");
                return ExitCode::FAILURE;
            }
        };
    }
    let ir = match epitome_mlir::translate::translate(&m) {
        Ok(ir) => ir,
        Err(e) => {
            eprintln!("{path}: {e}");
            return ExitCode::FAILURE;
        }
    };
    if let Err(e) = io::write(&output, ir.to_string()) {
        eprintln!("{output}: {e}");
        return ExitCode::FAILURE;
    }
    ExitCode::SUCCESS
}
