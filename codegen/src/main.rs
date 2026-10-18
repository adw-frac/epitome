//! `smaugian-llc`: compiles a `.ll` file to AArch64 assembly.

use std::process::ExitCode;

use smaugian_codegen::target::Target;
use smaugian_codegen::{Stop, compile, mir};

const USAGE: &str = "usage: smaugian-llc [options] <file.ll>

  -o <file>               write the assembly here instead of stdout
  --target=<file.ll>      read the machine description from this file
                          (default: the built-in AArch64 description)
  --stop-after=isel|ra    print machine IR after selection or allocation
  --hex                   print each function's machine code in hex
  --disasm                disassemble each function's machine code
  --patterns              list the selection patterns and exit
  --stats                 print matching counts and timings to stderr";

fn main() -> ExitCode {
    let args: Vec<String> = std::env::args().skip(1).collect();
    let (mut input, mut output, mut target_file) = (None, None, None);
    let (mut hex, mut disasm, mut patterns, mut stats) = (false, false, false, false);
    let mut stop = Stop::Done;
    let mut it = args.iter();
    while let Some(a) = it.next() {
        match a.as_str() {
            "-o" => output = it.next().cloned(),
            "--hex" => hex = true,
            "--disasm" => disasm = true,
            "--patterns" => patterns = true,
            "--stats" => stats = true,
            "--stop-after=isel" => stop = Stop::AfterSelection,
            "--stop-after=ra" => stop = Stop::AfterAllocation,
            s if s.starts_with("--target=") => target_file = Some(s["--target=".len()..].to_string()),
            s if s.starts_with('-') => {
                eprintln!("smaugian-llc: unknown option {s}\n\n{USAGE}");
                return ExitCode::FAILURE;
            }
            s => input = Some(s.to_string()),
        }
    }
    let target = match target_file {
        None => Target::aarch64(),
        Some(path) => match std::fs::read_to_string(&path).map_err(|e| e.to_string()).and_then(|s| Target::load(&s)) {
            Ok(t) => t,
            Err(e) => {
                eprintln!("smaugian-llc: {path}: {e}");
                return ExitCode::FAILURE;
            }
        },
    };
    if patterns {
        for p in &target.patterns {
            let emitted: Vec<&str> = p.emit.iter().map(|e| target.instrs[e.instr].name.as_str()).collect();
            println!("{:<40} {} IR ops -> {}", p.name, p.nodes, emitted.join(", "));
        }
        println!("{} patterns, {} trie nodes", target.patterns.len(), target.trie.nodes.len());
        return ExitCode::SUCCESS;
    }
    let Some(input) = input else {
        eprintln!("{USAGE}");
        return ExitCode::FAILURE;
    };
    let src = match std::fs::read_to_string(&input) {
        Ok(s) => s,
        Err(e) => {
            eprintln!("smaugian-llc: {input}: {e}");
            return ExitCode::FAILURE;
        }
    };
    let mut module = match smaugian_ir::parse_module(&src) {
        Ok(m) => m,
        Err(e) => {
            eprintln!("smaugian-llc: {input}: {e:?}");
            return ExitCode::FAILURE;
        }
    };
    let started = std::time::Instant::now();
    let compiled = match compile(&target, &mut module, stop) {
        Ok(c) => c,
        Err(e) => {
            eprintln!("smaugian-llc: {e}");
            return ExitCode::FAILURE;
        }
    };
    if stats {
        use smaugian_codegen::isel::stats::*;
        let total = started.elapsed();
        let (roots, steps, cands, valid) = (get(&ROOTS), get(&STEPS), get(&CANDIDATES), get(&VALID));
        let insts: usize = compiled.funcs.iter().map(|f| f.blocks.iter().map(|b| b.insts.len()).sum::<usize>()).sum();
        eprintln!(
            "; {} functions, {insts} machine instructions; {roots} roots matched: {:.1} trie steps, {:.1} candidates, {:.1} valid per root",
            compiled.funcs.len(),
            steps as f64 / roots.max(1) as f64,
            cands as f64 / roots.max(1) as f64,
            valid as f64 / roots.max(1) as f64
        );
        let m = get(&NANOS) as f64 / 1e6;
        eprintln!(
            "; matching {m:.1} ms ({:.0} ns per root: {:.0} walking the trie, {:.0} checking candidates) of {:.1} ms compiling",
            get(&NANOS) as f64 / roots.max(1) as f64,
            get(&WALK_NANOS) as f64 / roots.max(1) as f64,
            (get(&NANOS) - get(&WALK_NANOS)) as f64 / roots.max(1) as f64,
            total.as_secs_f64() * 1e3
        );
    }
    let mut text = compiled.asm.clone();
    if hex || disasm {
        text.clear();
        for f in &compiled.funcs {
            let (words, fixups) = match mir::encode_function(&target, f) {
                Ok(w) => w,
                Err(e) => {
                    eprintln!("smaugian-llc: {e}");
                    return ExitCode::FAILURE;
                }
            };
            text.push_str(&format!("{}:\n", f.name));
            for (k, w) in words.iter().enumerate() {
                let pc = (k * 4) as u64;
                let fix = fixups
                    .iter()
                    .find(|x| x.offset == k * 4)
                    .map(|x| format!("  ; fixup {}", x.symbol))
                    .unwrap_or_default();
                if disasm {
                    text.push_str(&format!("{pc:6x}: {w:08x}  {}{fix}\n", mir::disassemble(&target, *w, pc)));
                } else {
                    text.push_str(&format!("{w:08x}\n"));
                }
            }
        }
    }
    match output {
        Some(path) => {
            if let Err(e) = std::fs::write(&path, text) {
                eprintln!("smaugian-llc: {path}: {e}");
                return ExitCode::FAILURE;
            }
        }
        None => print!("{text}"),
    }
    ExitCode::SUCCESS
}
