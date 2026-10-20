// Signed 128-bit operations on edge values: multiplication with overflow
// checks (llvm.smul.with.overflow.i128), saturating additions and
// subtractions (llvm.sadd.sat, llvm.usub.sat and the rest), and three-way
// comparisons (llvm.scmp and llvm.ucmp of i128).
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
    }
    println!("hash {h:x}, {overflows} overflows");
}
