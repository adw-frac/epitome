//! `draconian-llc`: compiles a `.ll` file to AArch64 assembly, or to an
//! object file (Mach-O or ELF, as the convention uses).

use std::process::ExitCode;

use draconian_codegen::target::Target;
use draconian_codegen::{Options, Stop, compile, mir};

const USAGE: &str = "usage: draconian-llc [options] <file.ll>

  -j <n>                  threads to compile functions on (default: one
                          per core); the output is the same for any number
  --chop=F[:T]            autochop: functions before F (in module order,
                          from 0) get every elective choice, F its first T,
                          the rest none; also DRACONIAN_LLC_CHOP
  --chop-counts           print each function's count of elective choices
  -o <file>               write the output here instead of stdout; a name
                          ending in .o asks for an object file
  --filetype=asm|obj      assembly (the default) or an object file, Mach-O
                          or ELF as the convention uses
  --target=<name|path>    the machine description: a .ll file, a directory
                          of them (read in name order), or a name: aarch64
                          is built in, others are directories of that name
                          in DRACONIAN_TARGET_PATH (a list separated by
                          colons); by default, the one the module's triple names
                          (riscv64-... is riscv64), else aarch64
  --target-add=<path>     read these .ll files too, as more of the
                          description (may be given again)
  --abi=darwin|aapcs64    the calling convention and platform (default:
                          from the module's target triple, else darwin)
  --mcpu=<name>           the CPU, as the description names it (default:
                          the one each function's IR names, or the
                          description's)
  --mattr=+f,-g,...       turn features on or off
  --reserve=x18,...       keep these registers out of allocation
  --syntax=macho|elf      the assembler dialect, if not the convention's
  --stop-after=isel|ra    print machine IR after selection or allocation
  --hex                   print each function's machine code in hex
  --disasm                disassemble each function's machine code
  --patterns              list the selection patterns and exit
  --check-target          check the description (--target, --target-add)
                          and exit: encodings, assembly, recipes, and a
                          smoke program compiled under each convention
  --verbose               with --check-target, every message
  --sample-asm            print assembly with sample lines of every
                          instruction of the description, and exit
  --stats                 print matching counts and timings to stderr
  --keep-going            report every function that cannot be compiled,
                          and compile the rest";

fn main() -> ExitCode {
    let args: Vec<String> = std::env::args().skip(1).collect();
    let (mut input, mut output, mut target_file) = (None, None, None);
    let mut adds: Vec<String> = Vec::new();
    let (mut hex, mut disasm, mut patterns, mut stats) = (false, false, false, false);
    let (mut check, mut verbose, mut sample) = (false, false, false);
    let mut reserve: Vec<String> = Vec::new();
    let mut filetype = None;
    let mut stop = Stop::Done;
    let mut opts = Options::default();
    let (mut chop, mut chop_counts) = (None, false);
    let mut it = args.iter();
    while let Some(a) = it.next() {
        match a.as_str() {
            "-o" => output = it.next().cloned(),
            "-j" => match it.next().and_then(|n| n.parse().ok()) {
                Some(n) => opts.threads = n,
                None => {
                    eprintln!("draconian-llc: -j needs a number\n\n{USAGE}");
                    return ExitCode::FAILURE;
                }
            },
            "--hex" => hex = true,
            "--disasm" => disasm = true,
            "--patterns" => patterns = true,
            "--check-target" => check = true,
            "--sample-asm" => sample = true,
            "--verbose" => verbose = true,
            "--stats" => stats = true,
            "--chop-counts" => chop_counts = true,
            s if s.starts_with("--chop=") => chop = Some(s["--chop=".len()..].to_string()),
            "--keep-going" => opts.keep_going = true,
            "--filetype=asm" => filetype = Some(false),
            "--filetype=obj" => filetype = Some(true),
            "--stop-after=isel" => stop = Stop::AfterSelection,
            "--stop-after=ra" => stop = Stop::AfterAllocation,
            s if s.starts_with("--target=") => target_file = Some(s["--target=".len()..].to_string()),
            s if s.starts_with("--target-add=") => adds.push(s["--target-add=".len()..].to_string()),
            s if s.starts_with("--abi=") => opts.abi = Some(s["--abi=".len()..].to_string()),
            s if s.starts_with("--mcpu=") => opts.mcpu = Some(s["--mcpu=".len()..].to_string()),
            s if s.starts_with("--mattr=") => opts.mattr.push(s["--mattr=".len()..].to_string()),
            "--syntax=macho" => opts.syntax = Some(draconian_codegen::abi::Syntax::MachO),
            "--syntax=elf" => opts.syntax = Some(draconian_codegen::abi::Syntax::Elf),
            s if s.starts_with("--reserve=") => reserve.extend(s["--reserve=".len()..].split(',').map(str::to_string)),
            s if s.starts_with('-') => {
                eprintln!("draconian-llc: unknown option {s}\n\n{USAGE}");
                return ExitCode::FAILURE;
            }
            s => input = Some(s.to_string()),
        }
    }
    let load = |triple: &str| match Target::resolve(target_file.as_deref(), triple, &adds) {
        Ok(t) => Some(t),
        Err(e) => {
            eprintln!("draconian-llc: {e}");
            None
        }
    };
    if sample {
        let Some(target) = load("") else { return ExitCode::FAILURE };
        let syntax = opts.syntax.unwrap_or(draconian_codegen::abi::Syntax::Elf);
        print!("{}", draconian_codegen::check::sample_assembly(&target, syntax, 3));
        return ExitCode::SUCCESS;
    }
    if check {
        let Some(target) = load("") else { return ExitCode::FAILURE };
        let report = draconian_codegen::check::check(&target);
        print!("{}", report.render(verbose));
        return if report.errors() == 0 { ExitCode::SUCCESS } else { ExitCode::FAILURE };
    }
    if patterns {
        let Some(target) = load("") else { return ExitCode::FAILURE };
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
            eprintln!("draconian-llc: {input}: {e}");
            return ExitCode::FAILURE;
        }
    };
    let mut module = match draconian_ir::parse_module(&src) {
        Ok(m) => m,
        Err(e) => {
            eprintln!("draconian-llc: {input}: {e:?}");
            return ExitCode::FAILURE;
        }
    };
    let triple = module.triple.as_ref().map(|s| String::from_utf8_lossy(s).into_owned()).unwrap_or_default();
    let Some(target) = load(&triple) else { return ExitCode::FAILURE };
    match target.machine.regs(&reserve) {
        Ok(r) => opts.reserve.extend(r),
        Err(e) => {
            eprintln!("draconian-llc: --reserve: {e}");
            return ExitCode::FAILURE;
        }
    }
    let started = std::time::Instant::now();
    opts.stop = stop;
    opts.chop = match draconian_ir::chop::limit_from(chop.as_deref(), "DRACONIAN_LLC_CHOP") {
        Ok(l) => l,
        Err(e) => {
            eprintln!("draconian-llc: {e}");
            return ExitCode::FAILURE;
        }
    };
    let compiled = match compile(&target, &mut module, &opts) {
        Ok(c) => c,
        Err(e) => {
            eprintln!("draconian-llc: {e}");
            return ExitCode::FAILURE;
        }
    };
    for e in &compiled.errors {
        eprintln!("draconian-llc: {e}");
    }
    // Autochop's reports, as draconian-opt's.
    if let Some((k, steps, last)) = &compiled.chop_stopped {
        let name = compiled.chop_names.get(*k).map_or("?", String::as_str);
        match last {
            Some(d) => eprintln!("; chop: stopped in @{name} (function {k}) after step {steps}: {d}"),
            None => eprintln!("; chop: stopped in @{name} (function {k}) after {steps} steps"),
        }
    }
    if chop_counts {
        for (k, c) in compiled.chop_counts.iter().enumerate() {
            eprintln!("; chop: function {k} @{}: {} elective choices", compiled.chop_names[k], c.steps);
        }
    }
    {
        let counts: Vec<u64> = compiled.chop_counts.iter().map(|c| c.steps).collect();
        if let Err(e) = draconian_ir::chop::report_counts("llc", &compiled.chop_names, &counts) {
            eprintln!("DRACONIAN_CHOP_COUNTS: {e}");
        }
        if let Ok(dump) = std::env::var("DRACONIAN_CHOP_DUMP")
            && let Err(e) = std::fs::write(&dump, &compiled.asm)
        {
            eprintln!("{dump}: {e}");
        }
    }
    if stats {
        use draconian_codegen::isel::stats::*;
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
        use draconian_codegen::timing;
        let ms = |c| timing::get(c) as f64 / 1e6;
        eprintln!(
            "; stages, summed over functions: prepare {:.1} ms, selection {:.1} ms, allocation {:.1} ms, frames {:.1} ms, layout {:.1} ms",
            ms(&timing::PREPARE),
            ms(&timing::SELECT),
            ms(&timing::ALLOCATE),
            ms(&timing::FRAME),
            ms(&timing::LAYOUT)
        );
    }
    let object = filetype.unwrap_or_else(|| output.as_deref().is_some_and(|o| o.ends_with(".o")));
    if object {
        let bytes = match compiled.object_file(&target) {
            Ok(b) => b,
            Err(e) => {
                eprintln!("draconian-llc: {e}");
                return ExitCode::FAILURE;
            }
        };
        let Some(path) = output else {
            eprintln!("draconian-llc: an object file needs -o");
            return ExitCode::FAILURE;
        };
        if let Err(e) = std::fs::write(&path, bytes) {
            eprintln!("draconian-llc: {path}: {e}");
            return ExitCode::FAILURE;
        }
        return if compiled.errors.is_empty() { ExitCode::SUCCESS } else { ExitCode::FAILURE };
    }
    let mut text = compiled.asm.clone();
    if hex || disasm {
        text.clear();
        for f in &compiled.funcs {
            let (words, fixups) = match mir::encode_function(&target, f) {
                Ok(w) => w,
                Err(e) => {
                    eprintln!("draconian-llc: {e}");
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
                eprintln!("draconian-llc: {path}: {e}");
                return ExitCode::FAILURE;
            }
        }
        None => print!("{text}"),
    }
    ExitCode::SUCCESS
}
