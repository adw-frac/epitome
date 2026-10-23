//! `epitome-as`: assembles AArch64 assembly into an object file (Mach-O
//! or ELF), reading instructions with the machine description. See
//! `assembler.rs`.

use std::process::ExitCode;

use epitome_codegen::abi::Syntax;
use epitome_codegen::assembler::Assembler;
use epitome_codegen::target::Target;

const USAGE: &str = "usage: epitome-as [options] <file.s>

  -o <file>               write the object here, - for stdout (default: the
                          input's name with .o; needed when the input is -,
                          standard input)
  --format=macho|elf      the object file format (default: Mach-O if the
                          assembly names Mach-O sections or has
                          .build_version, else ELF)
  --max-errors=<n>        report this many lines that cannot be assembled
                          (default 20)
  --target=<name|path>    the machine description: a .ll file, a directory
                          of them (read in name order), or a name: aarch64
                          and x86_64 are built in, others are directories of that name
                          in EPITOME_TARGET_PATH (a list separated by
                          colons); aarch64 by default
  --target-add=<path>     read these .ll files too (may be given again)";

fn main() -> ExitCode {
    let (mut input, mut output, mut target_file, mut syntax) = (None, None, None, None);
    let mut max_errors = 20;
    let mut adds: Vec<String> = Vec::new();
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
            s if s.starts_with("--target-add=") => adds.push(s["--target-add=".len()..].to_string()),
            s if s.starts_with("--max-errors=") => match s["--max-errors=".len()..].parse() {
                Ok(n) => max_errors = n,
                Err(_) => {
                    eprintln!("epitome-as: bad {s}");
                    return ExitCode::FAILURE;
                }
            },
            s if s.starts_with('-') && s != "-" => {
                eprintln!("epitome-as: unknown option {s}\n\n{USAGE}");
                return ExitCode::FAILURE;
            }
            s => input = Some(s.to_string()),
        }
    }
    let Some(input) = input else {
        eprintln!("{USAGE}");
        return ExitCode::FAILURE;
    };
    let output = match output {
        Some(o) => o,
        None if input == "-" => {
            eprintln!("epitome-as: reading standard input needs -o");
            return ExitCode::FAILURE;
        }
        None => format!("{}.o", input.strip_suffix(".s").unwrap_or(&input)),
    };
    let target = match Target::resolve(target_file.as_deref(), "", &adds) {
        Ok(t) => t,
        Err(e) => {
            eprintln!("epitome-as: {e}");
            return ExitCode::FAILURE;
        }
    };
    let text = match epitome_ir::io::read_to_string(&input) {
        Ok(t) => t,
        Err(e) => {
            eprintln!("epitome-as: {input}: {e}");
            return ExitCode::FAILURE;
        }
    };
    let mut assembler = Assembler::new(&target);
    assembler.max_errors = max_errors;
    let assembled = match assembler.assemble(&text, syntax) {
        Ok(a) => a,
        Err(e) => {
            eprintln!("epitome-as: {input}: {e}");
            return ExitCode::FAILURE;
        }
    };
    let bytes = match assembled.file(&target) {
        Ok(b) => b,
        Err(e) => {
            eprintln!("epitome-as: {input}: {e}");
            return ExitCode::FAILURE;
        }
    };
    if let Err(e) = epitome_ir::io::write(&output, bytes) {
        eprintln!("epitome-as: {output}: {e}");
        return ExitCode::FAILURE;
    }
    ExitCode::SUCCESS
}
