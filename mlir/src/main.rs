//! `epitome-mlir-opt`: reads MLIR in the generic form and prints it back.

use std::process::ExitCode;

use epitome_ir::io;

#[global_allocator]
static MEMORY: epitome_ir::memlimit::Limited = epitome_ir::memlimit::Limited;

const USAGE: &str = "usage: epitome-mlir-opt <file.mlir | -> [--pass=a,b,...] [-o <file | ->]";

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
            _ if arg.starts_with("--pass=") => {
                passes.extend(arg["--pass=".len()..].split(',').filter(|p| !p.is_empty()).map(str::to_string));
            }
            "-h" | "--help" => {
                println!("{USAGE}");
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
    let m = match epitome_mlir::parse_module(&src) {
        Ok(m) => m,
        Err(e) => {
            eprintln!("{path}:{e}");
            return ExitCode::FAILURE;
        }
    };
    let mut m = m;
    for pass in &passes {
        m = match epitome_mlir::run_pass(pass, &m) {
            Ok(m) => m,
            Err(e) => {
                eprintln!("{path}: {pass}: {e}");
                return ExitCode::FAILURE;
            }
        };
    }
    if let Err(e) = io::write(&output, m.to_string()) {
        eprintln!("{output}: {e}");
        return ExitCode::FAILURE;
    }
    ExitCode::SUCCESS
}
