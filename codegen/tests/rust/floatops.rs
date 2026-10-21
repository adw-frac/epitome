// Floating point as Rust writes it: `as` casts to integers, which saturate
// and take NaN to 0 (llvm.fptosi.sat, llvm.fptoui.sat), at every width;
// rounding (floor, ceil, trunc, round, round_ties_even); copysign and abs;
// and what the C library computes (ln, log2, exp2, sin, powf, powi, the
// remainder %, mul_add).
use std::hint::black_box;

fn main() {
    let vals: [f64; 18] = [
        0.0, -0.0, 0.4, 0.5, 1.5, 2.5, -0.5, -1.5, -2.5, 127.9, 128.0, -128.5, 255.6, 65535.9,
        4294967296.5, -9.3e18, 1.0e30, f64::NAN,
    ];
    for &v in &vals {
        let x = black_box(v);
        let f = x as f32;
        println!(
            "{x:e}: {} {} {} {} {} {} {} {} | {} {} {} {}",
            x as i8, x as u8, x as i16, x as u16, x as i32, x as u32, x as i64, x as u64,
            f as i8, f as u8, f as i32, f as u64,
        );
        println!(
            "  {} {} {} {} {} | {} {} {} {} {} | {} {} {}",
            x.floor(), x.ceil(), x.trunc(), x.round(), x.round_ties_even(),
            f.floor(), f.ceil(), f.trunc(), f.round(), f.round_ties_even(),
            x.copysign(-1.0), f.copysign(-0.0), (-x).abs(),
        );
        let y = black_box(x.abs() + 0.75);
        let g = y as f32;
        println!(
            "  {:.12e} {:.12e} {:.12e} {:.12e} {:.12e} {:.12e} {:.12e} {:.12e} | {:.6e} {:.6e} {:.6e} {:.6e}",
            y.ln(), y.log2(), (y / 64.0).exp2(), y.sin(), y.powf(0.3), y.powi(3), x % 0.7, y.mul_add(1.5, -2.0),
            g.ln(), g.exp2().min(1e30), g.powi(-2), g % 1.25,
        );
    }
}
