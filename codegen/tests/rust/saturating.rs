// Saturating arithmetic (llvm.{u,s}{add,sub}.sat) at every width, on edge
// values, through black_box so that nothing folds.
use std::hint::black_box;

macro_rules! check {
    ($t:ty) => {{
        let vals: [$t; 7] = [<$t>::MIN, <$t>::MIN + 1, 0 as $t, 1 as $t, 3 as $t, <$t>::MAX - 1, <$t>::MAX];
        let mut h: u64 = 0;
        for &a in &vals {
            for &b in &vals {
                let (a, b) = (black_box(a), black_box(b));
                for r in [a.saturating_add(b), a.saturating_sub(b)] {
                    h = h.wrapping_mul(31).wrapping_add(r as u64);
                }
            }
        }
        println!("{}: {h:x}", stringify!($t));
    }};
}

fn main() {
    check!(u8);
    check!(u16);
    check!(u32);
    check!(u64);
    check!(i8);
    check!(i16);
    check!(i32);
    check!(i64);
}
