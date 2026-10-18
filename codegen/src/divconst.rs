//! Division and remainder by constants, as multiplications.
//!
//! Dividing by a constant `d` is multiplying by a fixed-point reciprocal,
//! the *magic number*, keeping the high half of the product, and shifting:
//! the method of Granlund and Montgomery, "Division by Invariant Integers
//! using Multiplication" (1994), in the form given by Warren, *Hacker's
//! Delight*, chapter 10. Powers of two are shifts, with a correction so
//! that signed division rounds towards zero. A remainder is `x - q * d`.
//!
//! The high half of an N-bit product is written in IR as the product of
//! the operands extended to 2N bits, shifted right by N: for 32 bits the
//! description's `smull`/`umull` and a shift cover it, for 64 bits
//! `smulh`/`umulh` cover the whole `i128` expression.

/// The magic number and shift for signed division by `d` (|d| >= 2, not a
/// power of two) at `w` bits: `q = hi(m * x)`, corrected, then shifted by
/// `s`. Hacker's Delight, figure 10-1.
pub fn magic_signed(d: i64, w: u32) -> (i64, u32) {
    let mask: u128 = (1u128 << w) - 1;
    let two_w1: u128 = 1u128 << (w - 1);
    let ad = (d.unsigned_abs() as u128) & mask;
    let t = two_w1 + (((d as u128) & mask) >> (w - 1));
    let anc = t - 1 - t % ad;
    let mut p = w - 1;
    let (mut q1, mut r1) = (two_w1 / anc, two_w1 - (two_w1 / anc) * anc);
    let (mut q2, mut r2) = (two_w1 / ad, two_w1 - (two_w1 / ad) * ad);
    loop {
        p += 1;
        q1 = (2 * q1) & mask;
        r1 = (2 * r1) & mask;
        if r1 >= anc {
            q1 = (q1 + 1) & mask;
            r1 = (r1 - anc) & mask;
        }
        q2 = (2 * q2) & mask;
        r2 = (2 * r2) & mask;
        if r2 >= ad {
            q2 = (q2 + 1) & mask;
            r2 = (r2 - ad) & mask;
        }
        let delta = (ad - r2) & mask;
        if !(q1 < delta || (q1 == delta && r1 == 0)) {
            break;
        }
    }
    let mut m = ((q2 + 1) & mask) as u64;
    if d < 0 {
        m = m.wrapping_neg();
    }
    (sext(m, w), p - w)
}

/// The magic number, whether an extra add is needed, and the shift for
/// unsigned division by `d` (not a power of two) at `w` bits. Hacker's
/// Delight, figure 10-2.
pub fn magic_unsigned(d: u64, w: u32) -> (u64, bool, u32) {
    let mask: u128 = (1u128 << w) - 1;
    let d = (d as u128) & mask;
    let two_w1: u128 = 1u128 << (w - 1);
    let mut add = false;
    let nc = (mask - ((mask + 1 - d) & mask) % d) & mask;
    let mut p = w - 1;
    let (mut q1, mut r1) = (two_w1 / nc, two_w1 - (two_w1 / nc) * nc);
    let (mut q2, mut r2) = ((two_w1 - 1) / d, (two_w1 - 1) - ((two_w1 - 1) / d) * d);
    loop {
        p += 1;
        if r1 >= (nc - r1) & mask {
            q1 = (2 * q1 + 1) & mask;
            r1 = (2 * r1).wrapping_sub(nc) & mask;
        } else {
            q1 = (2 * q1) & mask;
            r1 = (2 * r1) & mask;
        }
        if r2 + 1 >= (d - r2) & mask {
            if q2 >= two_w1 - 1 {
                add = true;
            }
            q2 = (2 * q2 + 1) & mask;
            r2 = (2 * r2 + 1).wrapping_sub(d) & mask;
        } else {
            if q2 >= two_w1 {
                add = true;
            }
            q2 = (2 * q2) & mask;
            r2 = (2 * r2 + 1) & mask;
        }
        let delta = (d - 1 - r2) & mask;
        if !(p < 2 * w && (q1 < delta || (q1 == delta && r1 == 0))) {
            break;
        }
    }
    (((q2 + 1) & mask) as u64, add, p - w)
}

fn sext(v: u64, w: u32) -> i64 {
    if w >= 64 { v as i64 } else { ((v << (64 - w)) as i64) >> (64 - w) }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn hi_signed(m: i64, x: i64, w: u32) -> i64 {
        ((m as i128 * x as i128) >> w) as i64
    }

    fn hi_unsigned(m: u64, x: u64, w: u32) -> u64 {
        ((m as u128 * x as u128) >> w) as u64
    }

    /// What the emitted IR computes, for signed division.
    fn sdiv(x: i64, d: i64, w: u32) -> i64 {
        let (m, s) = magic_signed(d, w);
        let mut q = sext(hi_signed(m, x, w) as u64, w);
        if d > 0 && m < 0 {
            q = sext(q.wrapping_add(x) as u64, w);
        }
        if d < 0 && m > 0 {
            q = sext(q.wrapping_sub(x) as u64, w);
        }
        q >>= s;
        let sign = ((q as u64) >> 63) as i64;
        sext(q.wrapping_add(sign) as u64, w)
    }

    fn udiv(x: u64, d: u64, w: u32) -> u64 {
        let (m, add, s) = magic_unsigned(d, w);
        let t = hi_unsigned(m, x, w);
        if add { ((((x - t) >> 1) + t) >> (s - 1)) & ((1u128 << w) - 1) as u64 } else { t >> s }
    }

    fn samples(w: u32) -> Vec<i64> {
        let mut v: Vec<i64> = (-300..300).collect();
        let max = if w == 32 { i32::MAX as i64 } else { i64::MAX };
        let min = if w == 32 { i32::MIN as i64 } else { i64::MIN };
        for k in 0..w.min(63) {
            for delta in [-1i64, 0, 1] {
                v.push((1i64 << k).wrapping_add(delta));
                v.push((-(1i64 << k)).wrapping_add(delta));
            }
        }
        v.extend([max, max - 1, min, min + 1, 0x1234_5678, -0x1234_5678]);
        let mut x: u64 = 0x9e37_79b9_7f4a_7c15;
        for _ in 0..2000 {
            x ^= x << 13;
            x ^= x >> 7;
            x ^= x << 17;
            v.push(sext(x, w));
        }
        v.retain(|&a| a >= min && a <= max);
        v
    }

    #[test]
    fn signed_division_by_constants() {
        for w in [32, 64] {
            let xs = samples(w);
            let ds: Vec<i64> = xs
                .iter()
                .copied()
                .filter(|d| d.unsigned_abs() >= 2 && !d.unsigned_abs().is_power_of_two())
                .take(800)
                .collect();
            for &d in &ds {
                for &x in &xs {
                    let min = if w == 32 { i32::MIN as i64 } else { i64::MIN };
                    if x == min && d == -1 {
                        continue;
                    }
                    let want = if w == 32 { ((x as i32) / (d as i32)) as i64 } else { x / d };
                    assert_eq!(sdiv(x, d, w), want, "{x} / {d} at {w} bits");
                }
            }
        }
    }

    #[test]
    fn unsigned_division_by_constants() {
        for w in [32u32, 64] {
            let mask = if w == 32 { u32::MAX as u64 } else { u64::MAX };
            let xs: Vec<u64> = samples(w).iter().map(|&x| x as u64 & mask).collect();
            let ds: Vec<u64> = xs.iter().copied().filter(|&d| d >= 3 && !d.is_power_of_two()).take(800).collect();
            for &d in &ds {
                for &x in &xs {
                    assert_eq!(udiv(x, d, w), x / d, "{x} / {d} at {w} bits");
                }
            }
        }
    }
}
