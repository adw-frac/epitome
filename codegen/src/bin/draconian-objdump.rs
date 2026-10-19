//! `draconian-objdump`: prints an object file's sections, symbols,
//! relocations and contents, and disassembles its code with the machine
//! description. See `objdump.rs`.

use std::process::ExitCode;

use draconian_codegen::objdump::{self, Image};
use draconian_codegen::target::Target;

const USAGE: &str = "usage: draconian-objdump [options] <file>...

  -d, --disassemble       disassemble the code sections (the default)
  -r, --reloc             print the relocations (with -d, after each
                          instruction they fill in)
  -t, --syms              print the symbol table
  -h, --section-headers   print the section headers
  -s, --full-contents     print every section's contents in hex
  -x, --all-headers       -h, -t and -r
  --canonical             print an ELF or Mach-O file as sorted text without
                          file offsets or order, to diff two that should
                          say the same
  --target=<name|path>    the machine description: a .ll file, a directory
                          of them (read in name order), or a name: aarch64
                          is built in, others are directories of that name
                          in DRACONIAN_TARGET_PATH (a list separated by
                          colons); by default, for an ELF file, the one with its
                          machine number, else aarch64
  --target-add=<path>     read these .ll files too (may be given again)

Options may be combined (-dr).";

fn main() -> ExitCode {
    let (mut d, mut r, mut t, mut h, mut s) = (false, false, false, false, false);
    let mut files = Vec::new();
    let mut target_file = None;
    let mut adds: Vec<String> = Vec::new();
    let mut canonical = false;
    for a in std::env::args().skip(1) {
        match a.as_str() {
            "--disassemble" => d = true,
            "--reloc" => r = true,
            "--syms" => t = true,
            "--section-headers" => h = true,
            "--full-contents" => s = true,
            "--all-headers" => (h, t, r) = (true, true, true),
            "--canonical" => canonical = true,
            "--help" => {
                println!("{USAGE}");
                return ExitCode::SUCCESS;
            }
            x if x.starts_with("--target=") => target_file = Some(x["--target=".len()..].to_string()),
            x if x.starts_with("--target-add=") => adds.push(x["--target-add=".len()..].to_string()),
            x if x.starts_with('-') && !x.starts_with("--") && x.len() > 1 => {
                for c in x[1..].chars() {
                    match c {
                        'd' => d = true,
                        'r' => r = true,
                        't' => t = true,
                        'h' => h = true,
                        's' => s = true,
                        'x' => (h, t, r) = (true, true, true),
                        _ => {
                            eprintln!("draconian-objdump: unknown option -{c}\n\n{USAGE}");
                            return ExitCode::FAILURE;
                        }
                    }
                }
            }
            x if x.starts_with('-') => {
                eprintln!("draconian-objdump: unknown option {x}\n\n{USAGE}");
                return ExitCode::FAILURE;
            }
            x => files.push(x.to_string()),
        }
    }
    if files.is_empty() {
        eprintln!("{USAGE}");
        return ExitCode::FAILURE;
    }
    if !(d || r || t || h || s) {
        d = true;
    }
    // The target: the one named; else, for an ELF file, the one with its
    // machine number; else the built-in one.
    let named = match &target_file {
        Some(_) => match Target::resolve(target_file.as_deref(), "", &adds) {
            Ok(t) => Some(t),
            Err(e) => {
                eprintln!("draconian-objdump: {e}");
                return ExitCode::FAILURE;
            }
        },
        None => None,
    };
    let for_file = |bytes: &[u8]| -> Option<Target> {
        let machine = draconian_codegen::elf::read(bytes).ok()?.machine;
        Target::for_elf_machine(machine)
    };
    let mut status = ExitCode::SUCCESS;
    for f in &files {
        let bytes = match std::fs::read(f) {
            Ok(b) => b,
            Err(e) => {
                eprintln!("draconian-objdump: {f}: {e}");
                status = ExitCode::FAILURE;
                continue;
            }
        };
        let fallback;
        let target: &Target = match &named {
            Some(t) => t,
            None => {
                fallback = for_file(&bytes).unwrap_or_else(Target::aarch64);
                &fallback
            }
        };
        if canonical {
            let text = if draconian_codegen::macho::is_macho(&bytes) {
                draconian_codegen::macho::read(&bytes).map(|m| m.canonical(&target.machine))
            } else {
                draconian_codegen::elf::read(&bytes).map(|e| e.canonical(&target.machine))
            };
            match text {
                Ok(t) => print!("{t}"),
                Err(e) => {
                    eprintln!("draconian-objdump: {f}: {e}");
                    status = ExitCode::FAILURE;
                }
            }
            continue;
        }
        let img = match Image::read(&bytes, &target.machine) {
            Ok(i) => i,
            Err(e) => {
                eprintln!("draconian-objdump: {f}: {e}");
                status = ExitCode::FAILURE;
                continue;
            }
        };
        let mut out = format!("\n{f}:\tfile format {}\n\n", img.format);
        if h {
            out.push_str(&objdump::headers(&img));
            out.push('\n');
        }
        if t {
            out.push_str(&objdump::symbols(&img));
            out.push('\n');
        }
        if s {
            out.push_str(&objdump::contents(&img));
        }
        if d {
            out.push_str(&objdump::disassemble(target, &img, r));
        } else if r {
            out.push_str(&objdump::relocations(&img));
        }
        print!("{out}");
    }
    status
}
