//! `draconian-chop`: finds the one elective change that breaks a test, by
//! binary search over autochop's limits (`draconian_ir::chop`).
//!
//! The test is any command: exit status 0 is a pass, anything else a
//! failure. It may run the tool however it likes (a build script, a
//! makefile); the limit reaches the tool through `DRACONIAN_OPT_CHOP` or
//! `DRACONIAN_LLC_CHOP`, which every run of that tool in the test obeys.

use std::process::{Command, ExitCode, Stdio};

use draconian_ir::chop::{self, Found, Limit};

const USAGE: &str = "usage: draconian-chop [--tool=opt|llc] [--verbose] -- <test command> [args...]

  Runs the test command (exit status 0 = pass) with autochop limits for
  draconian-opt (the default) or draconian-llc, and finds the first change
  that makes it fail: first the function (in module order), then the
  change in it. Prints that change, and what it did to the output.";

struct Test {
    var: &'static str,
    command: Vec<String>,
    verbose: bool,
    runs: usize,
}

impl Test {
    /// Runs the test with `env` set; returns whether it passed, and its
    /// standard error.
    fn run(&mut self, env: &[(&str, String)]) -> (bool, String) {
        self.runs += 1;
        let mut cmd = Command::new(&self.command[0]);
        cmd.args(&self.command[1..]).stdout(Stdio::null()).stderr(Stdio::piped());
        cmd.env_remove("DRACONIAN_OPT_CHOP").env_remove("DRACONIAN_LLC_CHOP");
        for (k, v) in env {
            cmd.env(k, v);
        }
        match cmd.output() {
            Ok(out) => (out.status.success(), String::from_utf8_lossy(&out.stderr).into_owned()),
            Err(e) => {
                eprintln!("draconian-chop: {}: {e}", self.command[0]);
                std::process::exit(2);
            }
        }
    }

    fn passes(&mut self, limit: Limit) -> bool {
        let (ok, _) = self.run(&[(self.var, limit.to_string())]);
        if self.verbose {
            eprintln!("  {limit:>12}  {}", if ok { "passes" } else { "fails" });
        }
        ok
    }
}

fn main() -> ExitCode {
    let args: Vec<String> = std::env::args().skip(1).collect();
    let Some(split) = args.iter().position(|a| a == "--") else {
        eprintln!("{USAGE}");
        return ExitCode::from(2);
    };
    let mut tool = "opt";
    let mut verbose = false;
    for a in &args[..split] {
        match a.as_str() {
            "--tool=opt" => tool = "opt",
            "--tool=llc" => tool = "llc",
            "--verbose" => verbose = true,
            _ => {
                eprintln!("draconian-chop: unknown option {a}\n\n{USAGE}");
                return ExitCode::from(2);
            }
        }
    }
    let command = args[split + 1..].to_vec();
    if command.is_empty() {
        eprintln!("{USAGE}");
        return ExitCode::from(2);
    }
    let var = if tool == "opt" { "DRACONIAN_OPT_CHOP" } else { "DRACONIAN_LLC_CHOP" };
    let mut test = Test { var, command, verbose, runs: 0 };
    let tmp = std::env::temp_dir().join(format!("draconian-chop-{}", std::process::id()));
    std::fs::create_dir_all(&tmp).unwrap();
    let file = |name: &str| tmp.join(name).to_string_lossy().into_owned();

    // Each function's count, from a run with no limit.
    let counts_path = file("counts");
    let (ok, _) = test.run(&[("DRACONIAN_CHOP_COUNTS", counts_path.clone())]);
    let text = std::fs::read_to_string(&counts_path).unwrap_or_default();
    let mut steps: Vec<u64> = Vec::new();
    let mut names: Vec<String> = Vec::new();
    for line in text.lines() {
        let parts: Vec<&str> = line.splitn(4, ' ').collect();
        let [t, k, n, name] = parts[..] else { continue };
        if t != tool {
            continue;
        }
        let (Ok(k), Ok(n)) = (k.parse::<usize>(), n.parse::<u64>()) else { continue };
        if steps.len() <= k {
            steps.resize(k + 1, 0);
            names.resize(k + 1, String::new());
        }
        // Several runs of the tool: the most any run made.
        steps[k] = steps[k].max(n);
        if names[k].is_empty() {
            names[k] = name.to_string();
        }
    }
    if ok {
        eprintln!("draconian-chop: the test passes with every change: nothing to find");
        return ExitCode::from(1);
    }
    if steps.is_empty() {
        eprintln!("draconian-chop: the test never ran draconian-{tool} (no counts were written)");
        return ExitCode::from(2);
    }
    let total: u64 = steps.iter().sum();
    eprintln!("draconian-chop: {} functions, {total} elective changes; searching", steps.len());

    let found = chop::search(&steps, |l| test.passes(l));
    let bad = match found {
        Found::Step(l) => l,
        Found::FailsWithNone => {
            eprintln!("draconian-chop: the test fails with no elective changes at all: not a change of ours");
            return ExitCode::from(1);
        }
        Found::PassesWithAll => {
            eprintln!("draconian-chop: the test passed with every change this time: it is not repeatable");
            return ExitCode::from(1);
        }
    };

    // The change, and what it did: the output just before it and with it.
    let before = Limit { func: bad.func, steps: bad.steps - 1 };
    let (ok_before, _) = test.run(&[(var, before.to_string()), ("DRACONIAN_CHOP_DUMP", file("before"))]);
    let (ok_after, err) = test.run(&[(var, bad.to_string()), ("DRACONIAN_CHOP_DUMP", file("after"))]);
    let what = err
        .lines()
        .find_map(|l| l.split_once("; chop: stopped in ").map(|x| x.1.to_string()))
        .unwrap_or_else(|| "(the tool did not say)".into());
    let name = names.get(bad.func).map_or("?", String::as_str);
    println!(
        "The first failing change: function {} (@{name}), change {} ({} in all with no limit)",
        bad.func, bad.steps, steps[bad.func]
    );
    println!("  {what}");
    println!("  limit: {var}={bad} fails, {before} passes ({} runs of the test)", test.runs);
    if !ok_before || ok_after {
        println!(
            "  but on checking again, {before} {} and {bad} {}: the test is not repeatable",
            if ok_before { "passes" } else { "fails" },
            if ok_after { "passes" } else { "fails" }
        );
    }
    let (a, b) = (std::fs::read_to_string(file("before")), std::fs::read_to_string(file("after")));
    if let (Ok(a), Ok(b)) = (a, b) {
        println!("\nWhat it changed in the output:");
        for line in diff(&a, &b) {
            println!("{line}");
        }
    }
    let _ = std::fs::remove_dir_all(&tmp);
    ExitCode::SUCCESS
}

/// The lines that differ, with a line of context: a small diff by longest
/// common prefix and suffix, which is enough for one change.
fn diff(a: &str, b: &str) -> Vec<String> {
    let (a, b): (Vec<&str>, Vec<&str>) = (a.lines().collect(), b.lines().collect());
    let pre = a.iter().zip(&b).take_while(|(x, y)| x == y).count();
    let suf = a[pre..].iter().rev().zip(b[pre..].iter().rev()).take_while(|(x, y)| x == y).count();
    let mut out = Vec::new();
    if pre > 0 {
        out.push(format!("  {}", a[pre - 1]));
    }
    out.extend(a[pre..a.len() - suf].iter().map(|l| format!("- {l}")));
    out.extend(b[pre..b.len() - suf].iter().map(|l| format!("+ {l}")));
    if suf > 0 {
        out.push(format!("  {}", a[a.len() - suf]));
    }
    out
}
