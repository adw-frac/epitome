//! The pipeline's time grows with a function's size, not faster: a function
//! four times bigger must take less than ten times as long (linear is
//! four, quadratic sixteen). Each shape once caught something quadratic:
//!
//! - a chain of diamonds: dominance asked by walking up the tree (now by
//!   intervals), and diamonds turned into selects one at a time, from the
//!   top again after each (now in one walk);
//! - a chain of blocks: merged one at a time, from the top again after each
//!   (now in one walk);
//! - thousands of calls in one block: the inliner's per-call sweeps over
//!   the function (now one at the end), fresh names tried from 1 each time
//!   (now from where the last search stopped), and split blocks keeping
//!   all their old room;
//! - one big block of loads and stores (SROA's per-access block lookup).

use std::fmt::Write;
use std::time::Duration;

use draconian_opt::pipeline::{self, Options};

fn diamonds(n: usize) -> String {
    let mut s = String::from("define i64 @f(i64 %a, i64 %b) {\nentry:\n  br label %d0\n");
    let mut prev = "%a".to_string();
    for k in 0..n {
        let _ = writeln!(
            s,
            "d{k}:\n  %c{k} = icmp slt i64 {prev}, %b\n  br i1 %c{k}, label %l{k}, label %r{k}\n\
             l{k}:\n  %x{k} = add i64 {prev}, {k}\n  br label %j{k}\n\
             r{k}:\n  %y{k} = mul i64 {prev}, 3\n  br label %j{k}\n\
             j{k}:\n  %v{k} = phi i64 [ %x{k}, %l{k} ], [ %y{k}, %r{k} ]\n  br label %d{}",
            k + 1
        );
        prev = format!("%v{k}");
    }
    let _ = writeln!(s, "d{n}:\n  ret i64 {prev}\n}}");
    s
}

fn chain(n: usize) -> String {
    let mut s = String::from("define i64 @f(i64 %a) {\nentry:\n  br label %b0\n");
    let mut prev = "%a".to_string();
    for k in 0..n {
        let from = if k == 0 { "entry".to_string() } else { format!("b{}", k - 1) };
        let _ = writeln!(
            s,
            "b{k}:\n  %v{k} = phi i64 [ {prev}, %{from} ]\n  %w{k} = xor i64 %v{k}, {k}\n  br label %b{}",
            k + 1
        );
        prev = format!("%w{k}");
    }
    let _ = writeln!(s, "b{n}:\n  ret i64 {prev}\n}}");
    s
}

fn calls(n: usize) -> String {
    let mut s = String::from(
        "define internal i64 @small(i64 %x) {\n  %y = mul i64 %x, 3\n  %z = add i64 %y, 1\n  ret i64 %z\n}\n\
         define i64 @f(i64 %a) {\nentry:\n",
    );
    let mut prev = "%a".to_string();
    for k in 0..n {
        let _ = writeln!(s, "  %c{k} = call i64 @small(i64 {prev})");
        prev = format!("%c{k}");
    }
    let _ = writeln!(s, "  ret i64 {prev}\n}}");
    s
}

fn block(n: usize) -> String {
    let mut s = String::from("define i64 @f(ptr %p, ptr %q) {\nentry:\n  %t = alloca [4 x i64]\n");
    let mut last = "0".to_string();
    for k in 0..n {
        let base = if k % 2 == 0 { "%p" } else { "%q" };
        let _ = writeln!(s, "  %g{k} = getelementptr i64, ptr {base}, i64 {}", k % 32);
        if k % 3 == 0 {
            let _ = writeln!(s, "  store i64 {last}, ptr %g{k}");
        } else {
            let _ = writeln!(s, "  %l{k} = load i64, ptr %g{k}\n  %s{k} = add i64 %l{k}, {last}");
            last = format!("%s{k}");
        }
    }
    let _ = writeln!(s, "  ret i64 {last}\n}}");
    s
}

/// The pipeline's time on one thread, the best of three.
fn time(src: &str) -> Duration {
    (0..3)
        .map(|_| {
            let mut m = draconian_ir::parse_module(src).unwrap();
            let t = std::time::Instant::now();
            pipeline::run(&mut m, &Options { threads: 1, ..Options::default() });
            t.elapsed()
        })
        .min()
        .unwrap()
}

#[test]
fn big_functions_take_time_in_proportion() {
    let shapes: [(&str, fn(usize) -> String, usize); 4] = [
        ("a chain of diamonds", diamonds, 2000),
        ("a chain of blocks", chain, 4000),
        ("calls in one block", calls, 2000),
        ("a big block of loads and stores", block, 4000),
    ];
    for (name, make, small) in shapes {
        let (a, b) = (time(&make(small)), time(&make(4 * small)));
        if b < Duration::from_millis(5) {
            continue;
        }
        let ratio = b.as_secs_f64() / a.as_secs_f64().max(1e-6);
        assert!(ratio < 10.0, "{name}: 4x the size took {ratio:.1}x as long ({a:?} and {b:?})");
    }
}
