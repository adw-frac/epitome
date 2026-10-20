// Three-way comparisons (llvm.ucmp, llvm.scmp, from Ord::cmp) at every
// width, on edge values, through black_box so that nothing folds.
use std::cmp::Ordering;
use std::hint::black_box;

macro_rules! check {
    ($t:ty) => {{
        let vals: [$t; 6] = [<$t>::MIN, <$t>::MIN + 1, 0 as $t, 1 as $t, <$t>::MAX - 1, <$t>::MAX];
        let mut h: i64 = 0;
        for &a in &vals {
            for &b in &vals {
                let o = black_box(a).cmp(&black_box(b));
                h = h * 3 + match o { Ordering::Less => 0, Ordering::Equal => 1, Ordering::Greater => 2 };
            }
        }
        println!("{}: {h}", stringify!($t));
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
