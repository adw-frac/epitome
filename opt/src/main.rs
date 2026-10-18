//! `smaugian-opt`: reads a `.ll` file, runs the interprocedural pipeline
//! (inlining and recursion removal) and prints the result.

use std::process::ExitCode;
use std::time::Instant;

use smaugian_opt::inline::OptLevel;
use smaugian_opt::pipeline::{self, Options};
use smaugian_opt::recursion::RecursionMode;

const USAGE: &str = "usage: smaugian-opt [options] <file.ll>

  -O1 -O2 -O3 -Os -Oz     optimisation level (default -O2)
  -j <n>                  threads (default: one per core)
  -o <file>               write the result here instead of stdout
  --passes=<list>         which passes to run, from mem2reg, inline,
                          recursion, combine and cse, separated by commas
                          (default: all)
  --no-inline             do not inline
  --no-combine            do not run the combiner
  --no-cse                do not run common-subexpression elimination
  --no-mem2reg            do not promote allocas to SSA values
  --recursion=<mode>      off; tail (default): tail and accumulator calls
                          become loops, other recursion stays; or stack:
                          all recursion, with an explicit stack
  --remarks               print each decision to stderr
  --print-cycles          print the call graph's cycles to stderr
  --stats                 print counts and timings to stderr
  --verify                check the output is well-formed SSA";

fn main() -> ExitCode {
    let args: Vec<String> = std::env::args().skip(1).collect();
    let mut opts = Options::default();
    let mut input = None;
    let mut output = None;
    let (mut remarks, mut cycles, mut stats, mut verify) = (false, false, false, false);
    let mut it = args.iter();
    while let Some(a) = it.next() {
        match a.as_str() {
            "-j" => match it.next().and_then(|n| n.parse().ok()) {
                Some(n) => opts.threads = n,
                None => return usage("-j needs a number"),
            },
            "-o" => output = it.next().cloned(),
            "--no-inline" => opts.inline = false,
            "--no-combine" => opts.combine = false,
            "--no-cse" => opts.cse = false,
            "--no-mem2reg" => opts.mem2reg = false,
            s if s.starts_with("--passes=") => {
                let list: Vec<&str> = s["--passes=".len()..].split(',').collect();
                if let Some(bad) =
                    list.iter().find(|p| !["mem2reg", "inline", "recursion", "combine", "cse"].contains(p))
                {
                    return usage(&format!("unknown pass {bad}"));
                }
                opts.inline = list.contains(&"inline");
                opts.combine = list.contains(&"combine");
                opts.cse = list.contains(&"cse");
                opts.mem2reg = list.contains(&"mem2reg");
                if !list.contains(&"recursion") {
                    opts.recursion = RecursionMode::Off;
                }
            }
            "--remarks" => remarks = true,
            "--print-cycles" => cycles = true,
            "--stats" => stats = true,
            "--verify" => verify = true,
            "-h" | "--help" => {
                println!("{USAGE}");
                return ExitCode::SUCCESS;
            }
            s if s.starts_with("-O") => match OptLevel::parse(&s[2..]) {
                Some(l) => opts.level = l,
                None => return usage(&format!("unknown level {s}")),
            },
            s if s.starts_with("--recursion=") => {
                opts.recursion = match &s["--recursion=".len()..] {
                    "off" => RecursionMode::Off,
                    "tail" => RecursionMode::Tail,
                    "stack" => RecursionMode::Stack,
                    other => return usage(&format!("unknown recursion mode {other}")),
                }
            }
            s if s.starts_with('-') => return usage(&format!("unknown option {s}")),
            s => input = Some(s.to_string()),
        }
    }
    let Some(path) = input else { return usage("no input file") };

    let src = match std::fs::read_to_string(&path) {
        Ok(s) => s,
        Err(e) => {
            eprintln!("{path}: {e}");
            return ExitCode::FAILURE;
        }
    };
    let t0 = Instant::now();
    let mut m = match smaugian_ir::parse_module(&src) {
        Ok(m) => m,
        Err(e) => {
            eprintln!("{path}:{e}");
            return ExitCode::FAILURE;
        }
    };
    let t1 = Instant::now();
    let report = pipeline::run(&mut m, &opts);
    let t2 = Instant::now();
    let text = m.to_string();
    let t3 = Instant::now();

    if cycles {
        if report.cycles.is_empty() {
            eprintln!("; no call-graph cycles");
        }
        for c in &report.cycles {
            eprintln!("; cycle: {c}");
        }
    }
    if remarks {
        for (f, list) in &report.remarks {
            for r in list {
                eprintln!("; @{f}: {r}");
            }
        }
        for f in &report.deleted {
            eprintln!("; @{f}: deleted, no longer used");
        }
    }
    if stats {
        eprintln!(
            "; {} functions in {} SCCs ({} cycles) on {} threads: {} calls inlined, {} tail, {} accumulator and {} other recursive calls removed, {} functions deleted",
            report.functions,
            report.sccs,
            report.cycles.len(),
            report.threads,
            report.inlined,
            report.tail_calls,
            report.accumulator_calls,
            report.frame_calls,
            report.deleted.len()
        );
        if report.mem2reg.promoted > 0 {
            eprintln!(
                "; mem2reg: {} allocas promoted, {} loads and {} stores removed",
                report.mem2reg.promoted, report.mem2reg.loads, report.mem2reg.stores
            );
        }
        if report.cse.total() > 0 {
            eprintln!(
                "; cse: {} instructions merged, {} loads reused, {} stores forwarded",
                report.cse.merged, report.cse.loads, report.cse.forwarded
            );
        }
        if report.combines.total() > 0 {
            let mut top: Vec<(&String, &usize)> = report.combines.fired.iter().collect();
            top.sort_by(|a, b| b.1.cmp(a.1).then(a.0.cmp(b.0)));
            let list: Vec<String> = top.iter().take(12).map(|(k, v)| format!("{k} {v}")).collect();
            eprintln!("; combines: {} in all; most used: {}", report.combines.total(), list.join(", "));
        }
        eprintln!(
            "; critical path {} of {} instructions: at most {:.1}x faster with threads",
            report.critical_path,
            report.total_work,
            report.total_work as f64 / report.critical_path.max(1) as f64
        );
        eprintln!(
            "; measured: tasks took {:.1} ms in all, {:.1} ms along the longest chain: at most {:.1}x faster",
            ms(report.task_time),
            ms(report.task_critical_path),
            report.task_time.as_secs_f64() / report.task_critical_path.as_secs_f64().max(1e-9)
        );
        let steps: Vec<String> = report.timings.iter().map(|(n, d)| format!("{n} {:.1} ms", ms(*d))).collect();
        eprintln!("; passes: {}", steps.join(", "));
        eprintln!("; parse {:.1} ms, passes {:.1} ms, print {:.1} ms", ms(t1 - t0), ms(t2 - t1), ms(t3 - t2));
    }
    if verify {
        let mut bad = false;
        for (g, f) in m.functions() {
            let name = m.global(g).name.clone().unwrap_or_default();
            for e in smaugian_opt::cfg::verify(f, &name) {
                eprintln!("verify: {e}");
                bad = true;
            }
        }
        if bad {
            return ExitCode::FAILURE;
        }
    }
    match output {
        Some(o) => {
            if let Err(e) = std::fs::write(&o, text) {
                eprintln!("{o}: {e}");
                return ExitCode::FAILURE;
            }
        }
        None => print!("{text}"),
    }
    ExitCode::SUCCESS
}

fn ms(d: std::time::Duration) -> f64 {
    d.as_secs_f64() * 1000.0
}

fn usage(msg: &str) -> ExitCode {
    eprintln!("smaugian-opt: {msg}\n\n{USAGE}");
    ExitCode::FAILURE
}
