//! The program `examples/jax.rs` links the block into: it reads the input
//! and JAX's own output (`input.txt`, `expected.txt`, next to the program,
//! from `export.py`), runs the block compiled by Epitome, and prints how far
//! its output is from JAX's.
//!
//! ```text
//! block(x: *const f32 /* [64, 32] */, out: *mut f32 /* [64, 32] */)
//! ```

use std::time::Instant;

unsafe extern "C" {
    fn block(x: *const f32, out: *mut f32);
}

fn numbers(dir: &std::path::Path, name: &str) -> Vec<f32> {
    let path = dir.join(name);
    let text = std::fs::read_to_string(&path).unwrap_or_else(|e| {
        eprintln!("jax: {}: {e} (run examples/jax/export.py first)", path.display());
        std::process::exit(1)
    });
    text.split_whitespace().map(|t| t.parse().expect("a number")).collect()
}

fn main() {
    let dir = std::env::current_exe().ok().and_then(|p| p.parent().map(|p| p.to_path_buf())).unwrap_or_default();
    let (x, want) = (numbers(&dir, "input.txt"), numbers(&dir, "expected.txt"));
    let mut out = vec![f32::NAN; want.len()];
    // SAFETY: `x` and `out` have the sizes `block` was compiled for.
    unsafe { block(x.as_ptr(), out.as_mut_ptr()) };
    let scale = want.iter().fold(0f32, |m, v| m.max(v.abs()));
    let worst = out.iter().zip(&want).fold(0f32, |m, (a, b)| m.max((a - b).abs()));
    println!("out[0..4]  {:?}", &out[..4]);
    println!("JAX's      {:?}", &want[..4]);
    println!("largest difference {worst:.3e}, {:.3e} of the largest value", worst / scale);
    let start = Instant::now();
    let mut n = 0;
    while start.elapsed().as_secs_f64() < 0.5 {
        // SAFETY: as above.
        unsafe { block(x.as_ptr(), out.as_mut_ptr()) };
        n += 1;
    }
    println!("{:.1} us a call", start.elapsed().as_secs_f64() * 1e6 / n as f64);
    if !(worst / scale < 1e-2) {
        std::process::exit(1);
    }
}
