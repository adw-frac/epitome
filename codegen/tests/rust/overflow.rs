// Arithmetic with overflow checks (`llvm.*.with.overflow`), on values at
// and around each type's limits, as `overflowing_*` and `checked_*` make
// them, and as debug builds' checks do.
use std::hint::black_box;

macro_rules! check {
    ($($t:ty),*) => {$({
        let vals: [$t; 9] = [0, 1, 2, 3, <$t>::MAX, <$t>::MAX - 1, <$t>::MIN, <$t>::MIN.wrapping_add(1), <$t>::MAX / 2 + 1];
        let mut h = 0u64;
        for &a in &vals {
            for &b in &vals {
                let (a, b) = (black_box(a), black_box(b));
                for (v, o) in [a.overflowing_add(b), a.overflowing_sub(b), a.overflowing_mul(b)] {
                    h = h.wrapping_mul(31).wrapping_add(v as u64).wrapping_mul(3).wrapping_add(o as u64);
                }
                h = h.wrapping_add(a.checked_mul(b).is_none() as u64);
            }
        }
        println!("{}: {h:#x}", stringify!($t));
    })*};
}

fn main() {
    check!(i8, u8, i16, u16, i32, u32, i64, u64);
    // Sums and differences of 128-bit integers.
    let big: [u128; 4] = [0, 1, u128::MAX, 1 << 64];
    let mut h = 0u128;
    for &a in &big {
        for &b in &big {
            let (a, b) = (black_box(a), black_box(b));
            for (v, o) in [a.overflowing_add(b), a.overflowing_sub(b)] {
                h = h.wrapping_mul(31).wrapping_add(v).wrapping_add(o as u128);
            }
            let (x, y) = (a as i128, b as i128);
            for (v, o) in [x.overflowing_add(y), x.overflowing_sub(y)] {
                h = h.wrapping_mul(7).wrapping_add(v as u128).wrapping_add(o as u128);
            }
        }
    }
    println!("u128: {h:#x}");
}
