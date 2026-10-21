// Signed 128-bit operations on edge values: multiplication with overflow
// checks (llvm.smul.with.overflow.i128), saturating additions and
// subtractions (llvm.sadd.sat, llvm.usub.sat and the rest), and three-way
// comparisons (llvm.scmp and llvm.ucmp of i128); conversions to and
// from floating point.
use std::cmp::Ordering;
use std::hint::black_box;

fn main() {
    let vals: [i128; 14] = [
        0,
        1,
        -1,
        2,
        -2,
        i64::MAX as i128,
        i64::MIN as i128,
        1 << 63,
        1 << 64,
        -(1 << 64),
        (1 << 126) - 1,
        i128::MAX,
        i128::MIN,
        i128::MIN + 1,
    ];
    let mut h: u128 = 0;
    let mut overflows = 0;
    let mut mix = |v: u128| h = h.wrapping_mul(1_000_003).wrapping_add(v);
    for &a in &vals {
        for &b in &vals {
            let (a, b) = (black_box(a), black_box(b));
            match a.checked_mul(b) {
                Some(p) => mix(p as u128),
                None => overflows += 1,
            }
            mix(a.saturating_add(b) as u128);
            mix(a.saturating_sub(b) as u128);
            let (ua, ub) = (a as u128, b as u128);
            mix(ua.saturating_add(ub));
            mix(ua.saturating_sub(ub));
            let c = |o: Ordering| o as i8 as u128;
            mix(c(a.cmp(&b)));
            mix(c(ua.cmp(&ub)) << 8);
        }
        // To and from floating point (the runtime's __floattidf and
        // __fixdfti, and saturating as Rust's `as` does).
        let a = black_box(a);
        let (d, f) = (a as f64, (a as u128) as f32);
        mix(d.to_bits() as u128);
        mix(f.to_bits() as u128);
        mix((d * 0.75) as i128 as u128);
        mix((f64::from(f) * 1.5) as u128);
        mix((d * 1e10) as i128 as u128);
    }
    println!("hash {h:x}, {overflows} overflows");
}
