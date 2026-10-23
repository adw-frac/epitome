//! Parsing and printing must take time in proportion to the input. A
//! simulator's `hw.module` is one graph region of hundreds of thousands of
//! operations, many of them using values defined after them, so these
//! inputs are one big region whose every operation uses the next one's
//! result: each use is a forward reference.

use std::time::{Duration, Instant};

fn chain(n: usize) -> String {
    let mut s = String::from("\"hw.module\"() ({\n");
    for i in 0..n {
        s += &format!("  %{i} = \"comb.add\"(%{}, %{}) : (i8, i8) -> i8\n", i + 1, (i + 2) % (n + 1));
    }
    s += &format!("  %{n} = \"hw.constant\"() <{{value = 1 : i8}}> : () -> i8\n");
    s += "}) : () -> ()\n";
    s
}

fn time(n: usize) -> Duration {
    let src = chain(n);
    let start = Instant::now();
    let m = epitome_mlir::parse_module(&src).unwrap();
    let printed = m.to_string();
    let t = start.elapsed();
    assert_eq!(printed, src);
    t
}

#[test]
fn parsing_is_linear() {
    let small = 25_000;
    // Take the best of three, so that a busy machine does not fail the test.
    let best = |n| (0..3).map(|_| time(n)).min().unwrap();
    let a = best(small);
    let b = best(small * 4);
    assert!(b < a * 10, "{small} operations took {a:?}, {} took {b:?}", small * 4);
}
