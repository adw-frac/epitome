// 128-bit multiplication with overflow checks (llvm.umul.with.overflow.i128)
// on edge values: high halves zero or not, cross products that do and do
// not fit, a middle column that carries.
use std::hint::black_box;

fn main() {
    let vals: [u128; 13] = [
        0,
        1,
        2,
        u64::MAX as u128,
        (u64::MAX as u128) + 1,
        1 << 63,
        1 << 64,
        (1 << 64) | 1,
        // With u64::MAX: cross products that fit, and a middle column
        // that carries.
        (1 << 65) - 1,
        u128::MAX >> 64,
        u128::MAX >> 1,
        u128::MAX - 1,
        u128::MAX,
    ];
    let mut h: u128 = 0;
    let mut overflows = 0;
    for &a in &vals {
        for &b in &vals {
            let (p, o) = black_box(a).overflowing_mul(black_box(b));
            h = h.wrapping_mul(1_000_003).wrapping_add(p);
            overflows += o as u32;
            if let Some(q) = black_box(a).checked_mul(black_box(b)) {
                h ^= q;
            }
        }
    }
    println!("{h:x} {overflows}");
}
