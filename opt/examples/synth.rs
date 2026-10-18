//! Writes a large synthetic module for measuring how the pipeline scales
//! with threads.
//!
//! `cargo run --release --example synth -- <functions> [layers] > big.ll`
//!
//! Function `i` calls a few functions with smaller indices, so the call
//! graph is a DAG, with cycles mixed in: every 7th function calls itself,
//! and every 11th forms a mutually recursive pair with the next one. Bodies
//! are a few dozen instructions with a loop and branches.
//!
//! With `layers` (default 16), the functions are split into that many
//! layers and each calls functions in the layer below, like a real program:
//! wide and shallow. With `layers` = 0, each function calls one of the 50
//! before it, which makes long chains that must run one after another.
//! The same arguments always give the same module.

use std::fmt::Write;

struct Lcg(u64);

impl Lcg {
    fn next(&mut self) -> u64 {
        self.0 = self.0.wrapping_mul(6364136223846793005).wrapping_add(1442695040888963407);
        self.0 >> 33
    }
    fn below(&mut self, n: u64) -> u64 {
        self.next() % n.max(1)
    }
}

fn main() {
    let n: usize = std::env::args().nth(1).and_then(|s| s.parse().ok()).unwrap_or(10000);
    let layers: usize = std::env::args().nth(2).and_then(|s| s.parse().ok()).unwrap_or(16);
    let layer_size = if layers == 0 { 0 } else { n.div_ceil(layers) };
    let mut rng = Lcg(42);
    let mut out = String::new();
    for i in 0..n {
        let linkage = if i % 5 == 0 { "" } else { "internal " };
        writeln!(out, "define {linkage}i32 @f{i}(i32 %x, i32 %y) {{").unwrap();
        writeln!(out, "entry:").unwrap();
        writeln!(out, "  %small = icmp slt i32 %x, 3").unwrap();
        writeln!(out, "  br i1 %small, label %base, label %work\n").unwrap();
        writeln!(out, "base:").unwrap();
        writeln!(out, "  ret i32 %y\n").unwrap();
        writeln!(out, "work:").unwrap();
        // Straight-line arithmetic.
        let len = 4 + rng.below(12) as usize;
        let mut prev = "%x".to_string();
        for k in 0..len {
            let op = ["add", "mul", "xor", "sub", "shl", "or"][rng.below(6) as usize];
            let c = 1 + rng.below(31);
            let other = if k % 3 == 0 { "%y".to_string() } else { c.to_string() };
            writeln!(out, "  %a{k} = {op} i32 {prev}, {other}").unwrap();
            prev = format!("%a{k}");
        }
        // A small loop.
        writeln!(out, "  br label %loop\n").unwrap();
        writeln!(out, "loop:").unwrap();
        writeln!(out, "  %i = phi i32 [ 0, %work ], [ %i.next, %loop ]").unwrap();
        writeln!(out, "  %acc = phi i32 [ {prev}, %work ], [ %acc.next, %loop ]").unwrap();
        writeln!(out, "  %t = mul i32 %acc, 31").unwrap();
        writeln!(out, "  %acc.next = add i32 %t, %i").unwrap();
        writeln!(out, "  %i.next = add i32 %i, 1").unwrap();
        writeln!(out, "  %more = icmp slt i32 %i.next, %y").unwrap();
        writeln!(out, "  br i1 %more, label %loop, label %calls\n").unwrap();
        writeln!(out, "calls:").unwrap();
        let mut acc = "%acc.next".to_string();
        let mut c = 0;
        let mut call = |out: &mut String, callee: usize, arg: &str, acc: &mut String| {
            writeln!(out, "  %c{c} = call i32 @f{callee}(i32 {arg}, i32 {acc})").unwrap();
            *acc = format!("%c{c}");
            c += 1;
        };
        writeln!(out, "  %xm = sub i32 %x, 1").unwrap();
        let below = if layers == 0 {
            (i.saturating_sub(50), i)
        } else {
            let layer = i / layer_size;
            (layer.saturating_sub(1) * layer_size, layer * layer_size)
        };
        if below.1 > below.0 {
            for _ in 0..1 + rng.below(3) {
                let callee = below.0 + rng.below((below.1 - below.0) as u64) as usize;
                call(&mut out, callee, "%xm", &mut acc);
            }
        }
        if i % 7 == 0 {
            call(&mut out, i, "%xm", &mut acc);
        }
        if i % 11 == 0 && i + 1 < n {
            call(&mut out, i + 1, "%xm", &mut acc);
        }
        if i % 11 == 1 && i > 0 {
            call(&mut out, i - 1, "%xm", &mut acc);
        }
        writeln!(out, "  %r = add i32 {acc}, %a0").unwrap();
        writeln!(out, "  ret i32 %r\n}}\n").unwrap();
    }
    print!("{out}");
}
