//! Arbitrary-width integers, enough to hold and print IR integer constants.

use std::fmt;

/// An integer of a fixed bit width. Words are little-endian and bits above
/// the width are always zero.
#[derive(Clone, PartialEq, Eq, Hash, Debug)]
pub struct ApInt {
    bits: u32,
    words: Vec<u64>,
}

impl ApInt {
    pub fn zero(bits: u32) -> Self {
        ApInt { bits, words: vec![0; words_for(bits)] }
    }

    pub fn from_u64(bits: u32, value: u64) -> Self {
        let mut a = Self::zero(bits);
        a.words[0] = value;
        a.mask();
        a
    }

    pub fn from_i64(bits: u32, value: i64) -> Self {
        let mut a = Self::zero(bits);
        for w in a.words.iter_mut() {
            *w = if value < 0 { u64::MAX } else { 0 };
        }
        a.words[0] = value as u64;
        a.mask();
        a
    }

    pub fn bits(&self) -> u32 {
        self.bits
    }

    pub fn words(&self) -> &[u64] {
        &self.words
    }

    pub fn is_zero(&self) -> bool {
        self.words.iter().all(|&w| w == 0)
    }

    /// The low 64 bits.
    pub fn low_u64(&self) -> u64 {
        self.words[0]
    }

    /// The value as a signed 64-bit integer, if it fits.
    pub fn to_i64(&self) -> Option<i64> {
        let neg = self.is_negative();
        let fill = if neg { u64::MAX } else { 0 };
        let mut full = self.words.clone();
        sign_fill(&mut full, self.bits, neg);
        if full[1..].iter().any(|&w| w != fill) {
            return None;
        }
        let v = full[0] as i64;
        if (v < 0) != neg {
            return None;
        }
        Some(v)
    }

    pub fn is_negative(&self) -> bool {
        let top = self.bits - 1;
        self.words[(top / 64) as usize] >> (top % 64) & 1 == 1
    }

    /// Parses decimal digits, with an optional leading `-`. Fails if the value
    /// fits neither the signed nor the unsigned range of `bits`.
    pub fn parse_decimal(bits: u32, text: &str) -> Option<Self> {
        let (neg, digits) = match text.strip_prefix('-') {
            Some(d) => (true, d),
            None => (false, text),
        };
        if digits.is_empty() || !digits.bytes().all(|b| b.is_ascii_digit()) {
            return None;
        }
        // One spare word to detect overflow.
        let mut mag = vec![0u64; words_for(bits) + 1];
        for b in digits.bytes() {
            let mut carry = (b - b'0') as u128;
            for w in mag.iter_mut() {
                let t = *w as u128 * 10 + carry;
                *w = t as u64;
                carry = t >> 64;
            }
            if carry != 0 {
                return None;
            }
        }
        // Positive values must be below 2^bits; negative ones at most 2^(bits-1).
        let limit_bit = if neg { bits - 1 } else { bits };
        let used = used_bits(&mag);
        if neg {
            if used > limit_bit + 1 || (used == limit_bit + 1 && !is_power_of_two(&mag)) {
                return None;
            }
        } else if used > limit_bit {
            return None;
        }
        mag.truncate(words_for(bits));
        let mut a = ApInt { bits, words: mag };
        if neg {
            a.negate();
        }
        a.mask();
        Some(a)
    }

    /// Parses hex digits. When `signed`, the value is sign-extended from its
    /// active bits, as the `s0x` form requires.
    pub fn parse_hex(bits: u32, digits: &str, signed: bool) -> Option<Self> {
        if digits.is_empty() {
            return None;
        }
        let mut words = vec![0u64; words_for(bits).max(digits.len().div_ceil(16))];
        for (i, c) in digits.bytes().rev().enumerate() {
            let d = (c as char).to_digit(16)? as u64;
            words[i / 16] |= d << ((i % 16) * 4);
        }
        let active = used_bits(&words);
        if active > bits {
            return None;
        }
        let neg = signed && active > 0 && {
            let top = active - 1;
            words[(top / 64) as usize] >> (top % 64) & 1 == 1
        };
        words.truncate(words_for(bits));
        let mut a = ApInt { bits, words };
        if neg {
            sign_fill(&mut a.words, active, true);
        }
        a.mask();
        Some(a)
    }

    fn negate(&mut self) {
        let mut carry = 1u128;
        for w in self.words.iter_mut() {
            let t = (!*w) as u128 + carry;
            *w = t as u64;
            carry = t >> 64;
        }
        self.mask();
    }

    fn mask(&mut self) {
        let n = words_for(self.bits);
        self.words.truncate(n);
        let rem = self.bits % 64;
        if rem != 0 {
            self.words[n - 1] &= (1u64 << rem) - 1;
        }
    }

    /// Unsigned decimal digits of the value.
    fn unsigned_decimal(words: &[u64]) -> String {
        let mut words = words.to_vec();
        let mut chunks = Vec::new();
        const TEN19: u128 = 10_000_000_000_000_000_000;
        loop {
            let mut rem = 0u128;
            for w in words.iter_mut().rev() {
                let t = (rem << 64) | *w as u128;
                *w = (t / TEN19) as u64;
                rem = t % TEN19;
            }
            chunks.push(rem as u64);
            if words.iter().all(|&w| w == 0) {
                break;
            }
        }
        let mut s = chunks.pop().unwrap().to_string();
        for c in chunks.iter().rev() {
            s.push_str(&format!("{c:019}"));
        }
        s
    }
}

impl fmt::Display for ApInt {
    /// Prints the value as a signed decimal, the way IR text writes integers.
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        if self.is_negative() {
            let mut m = self.clone();
            m.negate();
            if m.is_zero() || m.is_negative() {
                // The most negative value: its magnitude is 2^(bits-1).
                let mut mag = vec![0u64; words_for(self.bits)];
                let top = self.bits - 1;
                mag[(top / 64) as usize] = 1 << (top % 64);
                return write!(f, "-{}", Self::unsigned_decimal(&mag));
            }
            write!(f, "-{}", Self::unsigned_decimal(&m.words))
        } else {
            write!(f, "{}", Self::unsigned_decimal(&self.words))
        }
    }
}

fn words_for(bits: u32) -> usize {
    (bits as usize).div_ceil(64).max(1)
}

fn used_bits(words: &[u64]) -> u32 {
    for (i, &w) in words.iter().enumerate().rev() {
        if w != 0 {
            return i as u32 * 64 + (64 - w.leading_zeros());
        }
    }
    0
}

fn is_power_of_two(words: &[u64]) -> bool {
    words.iter().map(|w| w.count_ones()).sum::<u32>() == 1
}

/// Sets every bit at or above `from` when `neg`.
fn sign_fill(words: &mut [u64], from: u32, neg: bool) {
    if !neg {
        return;
    }
    for (i, w) in words.iter_mut().enumerate() {
        let lo = i as u32 * 64;
        if from <= lo {
            *w = u64::MAX;
        } else if from < lo + 64 {
            *w |= u64::MAX << (from - lo);
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn decimal_round_trip() {
        for (bits, text) in [
            (8, "-1"),
            (8, "127"),
            (8, "-128"),
            (32, "-2147483648"),
            (64, "9223372036854775807"),
            (128, "12345678901234567890"),
            (128, "-170141183460469231731687303715884105728"),
            (1, "0"),
        ] {
            let a = ApInt::parse_decimal(bits, text).unwrap();
            assert_eq!(a.to_string(), text, "i{bits} {text}");
        }
    }

    #[test]
    fn decimal_wraps_unsigned_range() {
        assert_eq!(ApInt::parse_decimal(8, "255").unwrap().to_string(), "-1");
        assert_eq!(ApInt::parse_decimal(1, "1").unwrap().to_string(), "-1");
        assert!(ApInt::parse_decimal(8, "256").is_none());
        assert!(ApInt::parse_decimal(8, "-129").is_none());
    }

    #[test]
    fn hex_forms() {
        assert_eq!(ApInt::parse_hex(16, "8000", false).unwrap().to_string(), "-32768");
        assert_eq!(ApInt::parse_hex(32, "8000", false).unwrap().to_string(), "32768");
        assert_eq!(ApInt::parse_hex(32, "8000", true).unwrap().to_string(), "-32768");
        assert_eq!(ApInt::parse_hex(16, "0001", true).unwrap().to_string(), "-1");
    }
}
