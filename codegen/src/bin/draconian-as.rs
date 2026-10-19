//! `draconian-as`: assembles AArch64 assembly into an object file (Mach-O
//! or ELF), reading instructions with the machine description. See
//! `assembler.rs`.

use std::process::ExitCode;

use draconian_codegen::abi::Syntax;
use draconian_codegen::assembler::Assembler;
use draconian_codegen::target::Target;

const USAGE: &str = "usage: draconian-as [options] <file.s>

  -o <file>               write the object here (default: the input's name
                          with .o)
  --format=macho|elf      the object file format (default: Mach-O if the
                          assembly names Mach-O sections or has
                          .build_version, else ELF)
  --max-errors=<n>        report this many lines that cannot be assembled
                          (default 20)
  --target=<path>         read the machine description from this .ll file,
                          or the .ll files in this directory in name order
                          (default: the built-in AArch64 description)";

fn main() -> ExitCode {
    let (mut input, mut output, mut target_file, mut syntax) = (None, None, None, None);
    let mut max_errors = 20;
    let args: Vec<String> = std::env::args().skip(1).collect();
    let mut it = args.iter();
    while let Some(a) = it.next() {
        match a.as_str() {
            "-o" => output = it.next().cloned(),
            "--format=macho" => syntax = Some(Syntax::MachO),
            "--format=elf" => syntax = Some(Syntax::Elf),
            "--help" => {
                println!("{USAGE}");
                return ExitCode::SUCCESS;
            }
            s if s.starts_with("--target=") => target_file = Some(s["--target=".len()..].to_string()),
            s if s.starts_with("--max-errors=") => match s["--max-errors=".len()..].parse() {
                Ok(n) => max_errors = n,
                Err(_) => {
                    eprintln!("draconian-as: bad {s}");
                    return ExitCode::FAILURE;
                }
            },
            s if s.starts_with('-') => {
                eprintln!("draconian-as: unknown option {s}\n\n{USAGE}");
                return ExitCode::FAILURE;
            }
            s => input = Some(s.to_string()),
        }
    }
    let Some(input) = input else {
        eprintln!("{USAGE}");
        return ExitCode::FAILURE;
    };
    let output = output.unwrap_or_else(|| format!("{}.o", input.strip_suffix(".s").unwrap_or(&input)));
    let target = match target_file {
        None => Target::aarch64(),
        Some(path) => match Target::load_path(&path) {
            Ok(t) => t,
            Err(e) => {
                eprintln!("draconian-as: {path}: {e}");
                return ExitCode::FAILURE;
            }
        },
    };
    let text = match std::fs::read_to_string(&input) {
        Ok(t) => t,
        Err(e) => {
            eprintln!("draconian-as: {input}: {e}");
            return ExitCode::FAILURE;
        }
    };
    let mut assembler = Assembler::new(&target);
    assembler.max_errors = max_errors;
    let assembled = match assembler.assemble(&text, syntax) {
        Ok(a) => a,
        Err(e) => {
            eprintln!("draconian-as: {input}: {e}");
            return ExitCode::FAILURE;
        }
    };
    if let Err(e) = std::fs::write(&output, assembled.file()) {
        eprintln!("draconian-as: {output}: {e}");
        return ExitCode::FAILURE;
    }
    ExitCode::SUCCESS
}
