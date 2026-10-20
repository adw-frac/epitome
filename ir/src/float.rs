//! Floating-point constants: parsing literals into bit patterns and printing
//! bit patterns back as IR text.
//!
//! Every value is stored as its raw bits in a `u128`, in the type's own
//! format. `x86_fp80` uses the low 80 bits. `fp128` and `ppc_fp128` use all
//! 128 bits, with the high 64 bits holding the sign and exponent (for
//! `ppc_fp128`, the high double).

use crate::types::Type;

#[derive(Clone, Copy, PartialEq, Eq, Debug)]
pub enum FloatKind {
    Half,
    BFloat,
    Float,
    Double,
    X86Fp80,
    Fp128,
    PpcFp128,
}

impl FloatKind {
    pub fn of(ty: &Type) -> Option<Self> {
        Some(match ty {
            Type::Half => FloatKind::Half,
            Type::BFloat => FloatKind::BFloat,
            Type::Float => FloatKind::Float,
            Type::Double => FloatKind::Double,
            Type::X86Fp80 => FloatKind::X86Fp80,
            Type::Fp128 => FloatKind::Fp128,
            Type::PpcFp128 => FloatKind::PpcFp128,
            _ => return None,
        })
    }

    pub fn bits(self) -> u32 {
        match self {
            FloatKind::Half | FloatKind::BFloat => 16,
            FloatKind::Float => 32,
            FloatKind::Double => 64,
            FloatKind::X86Fp80 => 80,
            FloatKind::Fp128 | FloatKind::PpcFp128 => 128,
        }
    }

    /// Exponent and stored-mantissa widths for the IEEE-style formats.
    fn ieee(self) -> Option<(u32, u32)> {
        match self {
            FloatKind::Half => Some((5, 10)),
            FloatKind::BFloat => Some((8, 7)),
            FloatKind::Float => Some((8, 23)),
            FloatKind::Double => Some((11, 52)),
            FloatKind::Fp128 => Some((15, 112)),
            FloatKind::X86Fp80 | FloatKind::PpcFp128 => None,
        }
    }
}

/// Parses a floating-point literal for the given type. Returns `None` when
/// the text is not a valid literal for that type.
pub fn parse(kind: FloatKind, text: &str) -> Option<u128> {
    // Legacy hex bit patterns.
    if let Some(rest) = text.strip_prefix("0x") {
        let (prefix, digits) = match rest.as_bytes().first()? {
            b'K' | b'L' | b'M' | b'H' | b'R' => (rest.as_bytes()[0], &rest[1..]),
            _ => (b'0', rest),
        };
        if digits.contains('.') || digits.contains('p') {
            return from_f64(kind, parse_c99_hex(digits, false)?);
        }
        let raw = parse_hex_u128(digits)?;
        return match (prefix, kind) {
            // A double's bits, as LLVM prints them: without leading zeros
            // (`0xADFB11E2ADB03C2` is 0x0ADFB11E2ADB03C2).
            (b'0', FloatKind::Double) if (1..=16).contains(&digits.len()) => Some(raw),
            (b'0', _) if (1..=16).contains(&digits.len()) => from_f64(kind, f64::from_bits(raw as u64)),
            (b'H', FloatKind::Half) | (b'R', FloatKind::BFloat) if digits.len() == 4 => Some(raw),
            (b'K', FloatKind::X86Fp80) if digits.len() == 20 => Some(raw),
            (b'L', FloatKind::Fp128) | (b'M', FloatKind::PpcFp128) if digits.len() == 32 => {
                // Printed low 64 bits first.
                Some(raw.rotate_right(64))
            }
            _ => None,
        };
    }
    if let Some(digits) = text.strip_prefix("-0x").or_else(|| text.strip_prefix("+0x")) {
        let neg = text.starts_with('-');
        return from_f64(kind, parse_c99_hex(digits, neg)?);
    }
    // Exact bit pattern.
    if let Some(digits) = text.strip_prefix("f0x") {
        if digits.len() as u32 * 4 != kind.bits() {
            return None;
        }
        return parse_hex_u128(digits);
    }
    if let Some(sign) = text.strip_suffix("inf") {
        return special(kind, sign, Special::Inf);
    }
    if let Some(sign) = text.strip_suffix("qnan") {
        return special(kind, sign, Special::QNan(0));
    }
    for (prefix, quiet) in [("nan(0x", true), ("snan(0x", false)] {
        for sign in ["+", "-"] {
            if let Some(rest) = text.strip_prefix(sign).and_then(|t| t.strip_prefix(prefix)) {
                let payload = parse_hex_u128(rest.strip_suffix(')')?)?;
                let s = if quiet { Special::QNan(payload) } else { Special::SNan(payload) };
                return special(kind, sign, s);
            }
        }
    }
    // Decimal.
    let valid = text.bytes().all(|b| b.is_ascii_digit() || b"+-.eE".contains(&b));
    if !valid || !text.bytes().any(|b| b.is_ascii_digit()) {
        return None;
    }
    from_f64(kind, text.parse::<f64>().ok()?)
}

enum Special {
    Inf,
    QNan(u128),
    SNan(u128),
}

fn special(kind: FloatKind, sign: &str, s: Special) -> Option<u128> {
    let neg = match sign {
        "+" => false,
        "-" => true,
        _ => return None,
    };
    let v = match s {
        Special::Inf => f64::INFINITY,
        Special::QNan(0) => f64::NAN,
        // Payloads beyond what a double carries are rare; keep the common case simple.
        Special::QNan(p) => f64::from_bits(0x7ff8_0000_0000_0000 | (p as u64 & 0x0007_ffff_ffff_ffff)),
        Special::SNan(p) => f64::from_bits(0x7ff0_0000_0000_0000 | (p as u64 & 0x0007_ffff_ffff_ffff)),
    };
    from_f64(kind, if neg { -v } else { v })
}

fn parse_hex_u128(digits: &str) -> Option<u128> {
    if digits.is_empty() || digits.len() > 32 {
        return None;
    }
    u128::from_str_radix(digits, 16).ok()
}

/// Parses the part of a C99 hex float after `0x`, such as `1.fp13`.
fn parse_c99_hex(digits: &str, neg: bool) -> Option<f64> {
    let (mant, exp) = digits.split_once(['p', 'P'])?;
    let exp: i32 = exp.parse().ok()?;
    let (int, frac) = mant.split_once('.').unwrap_or((mant, ""));
    let mut m = 0u128;
    let mut shift = 0i32;
    for c in int.chars().chain(frac.chars()) {
        if m >> 120 != 0 {
            // Further digits are below the precision we keep.
            if c != '0' {
                m |= 1;
            }
            shift += 4;
            continue;
        }
        m = m << 4 | c.to_digit(16)? as u128;
    }
    shift -= 4 * frac.len() as i32;
    let v = m as f64 * 2f64.powi(exp + shift);
    Some(if neg { -v } else { v })
}

/// Converts a double to the bits of `kind`, rounding to nearest even.
pub fn from_f64(kind: FloatKind, v: f64) -> Option<u128> {
    let bits = v.to_bits();
    let neg = bits >> 63 != 0;
    let exp = ((bits >> 52) & 0x7ff) as i32;
    let man = bits & 0x000f_ffff_ffff_ffff;
    match kind {
        FloatKind::Double => Some(bits as u128),
        FloatKind::PpcFp128 => Some((bits as u128) << 64),
        FloatKind::X86Fp80 => {
            let sign = (neg as u128) << 79;
            if exp == 0x7ff {
                // Infinity or NaN: explicit integer bit set.
                return Some(sign | 0x7fff << 64 | 1 << 63 | (man as u128) << 11);
            }
            if exp == 0 && man == 0 {
                return Some(sign);
            }
            let (e, m) = normalize(exp, man);
            let e80 = (e + 16383) as u128;
            Some(sign | e80 << 64 | 1 << 63 | (m as u128) << 11)
        }
        _ => {
            let (eb, mb) = kind.ieee().unwrap();
            Some(ieee_from_f64(neg, exp, man, eb, mb))
        }
    }
}

/// Returns the unbiased exponent and the 52-bit fraction of a nonzero
/// finite double, normalizing subnormals.
fn normalize(exp: i32, man: u64) -> (i32, u64) {
    if exp != 0 {
        return (exp - 1023, man);
    }
    let shift = man.leading_zeros() - 11;
    ((-1022) - shift as i32, (man << shift) & 0x000f_ffff_ffff_ffff)
}

fn ieee_from_f64(neg: bool, exp: i32, man: u64, eb: u32, mb: u32) -> u128 {
    let sign = (neg as u128) << (eb + mb);
    let max_exp = (1u128 << eb) - 1;
    if exp == 0x7ff {
        let payload = if mb >= 52 { (man as u128) << (mb - 52) } else { (man >> (52 - mb)) as u128 };
        let payload = if man != 0 && payload == 0 { 1u128 << (mb - 1) } else { payload };
        return sign | max_exp << mb | payload;
    }
    if exp == 0 && man == 0 {
        return sign;
    }
    let (e, m) = normalize(exp, man);
    let bias = (1i32 << (eb - 1)) - 1;
    // Significand with the implicit bit, as a 53-bit integer.
    let sig = (1u128 << 52) | m as u128;
    let mut biased = e + bias;
    // Number of low bits of `sig` to drop.
    let mut drop = 52 - mb as i32;
    if biased <= 0 {
        // Subnormal in the target format.
        drop += 1 - biased;
        biased = 0;
    }
    let rounded = if drop <= 0 {
        sig << (-drop)
    } else if drop >= 128 {
        0
    } else {
        let kept = sig >> drop;
        let rest = sig & ((1u128 << drop) - 1);
        let half = 1u128 << (drop - 1);
        if rest > half || (rest == half && kept & 1 == 1) { kept + 1 } else { kept }
    };
    // `rounded` includes the implicit bit for normals. Adding it as a whole
    // number lets a carry out of the mantissa bump the exponent.
    let out = if biased == 0 { rounded } else { ((biased as u128) << mb) + (rounded - (1u128 << mb)) };
    if out >> mb >= max_exp {
        return sign | max_exp << mb;
    }
    sign | out
}

/// Converts bits of `kind` to a double, when the kind is one that the
/// printer shows in decimal.
pub fn to_f64(kind: FloatKind, bits: u128) -> Option<f64> {
    match kind {
        FloatKind::Double => Some(f64::from_bits(bits as u64)),
        FloatKind::Float => Some(f32::from_bits(bits as u32) as f64),
        _ => None,
    }
}

/// Prints a constant the way IR text writes it: `float` and `double` in
/// `%e` style when that reads back exactly, otherwise as a hex double; the
/// other types as their prefixed bit patterns.
pub fn print(kind: FloatKind, bits: u128) -> String {
    match kind {
        FloatKind::Float | FloatKind::Double => {
            let v = to_f64(kind, bits).unwrap();
            if v.is_finite() {
                let s = format_e6(v);
                if let Ok(back) = s.parse::<f64>()
                    && back.to_bits() == v.to_bits()
                {
                    return s;
                }
            }
            format!("0x{:016X}", v.to_bits())
        }
        FloatKind::Half => format!("0xH{:04X}", bits as u16),
        FloatKind::BFloat => format!("0xR{:04X}", bits as u16),
        FloatKind::X86Fp80 => format!("0xK{:020X}", bits & ((1u128 << 80) - 1)),
        FloatKind::Fp128 => format!("0xL{:016X}{:016X}", bits as u64, (bits >> 64) as u64),
        FloatKind::PpcFp128 => format!("0xM{:016X}{:016X}", bits as u64, (bits >> 64) as u64),
    }
}

/// C's `%e` with six digits after the point, such as `1.500000e+00`.
fn format_e6(v: f64) -> String {
    let s = format!("{v:.6e}");
    let (mant, exp) = s.split_once('e').unwrap();
    let exp: i32 = exp.parse().unwrap();
    let sign = if exp < 0 { '-' } else { '+' };
    format!("{mant}e{sign}{:02}", exp.abs())
}

/// True when the bits are positive zero.
pub fn is_pos_zero(bits: u128) -> bool {
    bits == 0
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn prints_like_llvm() {
        let d = |s| print(FloatKind::Double, parse(FloatKind::Double, s).unwrap());
        assert_eq!(d("1.0"), "1.000000e+00");
        assert_eq!(d("1e300"), "1.000000e+300");
        assert_eq!(d("3.14159"), "3.141590e+00");
        assert_eq!(d("0.1"), "1.000000e-01");
        assert_eq!(d("0.123456789"), "0x3FBF9ADD3739635F");
        let f = |s| print(FloatKind::Float, parse(FloatKind::Float, s).unwrap());
        assert_eq!(f("0.1"), "0x3FB99999A0000000");
        assert_eq!(f("1.5"), "1.500000e+00");
        assert_eq!(f("0x3FB99999A0000000"), "0x3FB99999A0000000");
    }

    #[test]
    fn small_formats() {
        let h = parse(FloatKind::Half, "0.3").unwrap();
        assert_eq!(print(FloatKind::Half, h), "0xH34CD");
        assert_eq!(parse(FloatKind::Half, "1.0"), Some(0x3c00));
        assert_eq!(parse(FloatKind::BFloat, "1.0"), Some(0x3f80));
        assert_eq!(parse(FloatKind::Half, "65520.0"), Some(0x7c00));
        assert_eq!(parse(FloatKind::Half, "5.960464477539063e-8"), Some(1));
    }

    #[test]
    fn wide_formats() {
        let q = parse(FloatKind::Fp128, "2.5").unwrap();
        assert_eq!(print(FloatKind::Fp128, q), "0xL00000000000000004000400000000000");
        let k = parse(FloatKind::X86Fp80, "1.0").unwrap();
        assert_eq!(print(FloatKind::X86Fp80, k), "0xK3FFF8000000000000000");
        let text = "0xK3FFBCCCCCCCCCCCCCCCD";
        assert_eq!(print(FloatKind::X86Fp80, parse(FloatKind::X86Fp80, text).unwrap()), text);
    }

    #[test]
    fn specials() {
        assert_eq!(parse(FloatKind::Float, "+inf"), Some(0x7f80_0000));
        assert_eq!(parse(FloatKind::Float, "-inf"), Some(0xff80_0000));
        assert_eq!(parse(FloatKind::Float, "inf"), None);
        assert_eq!(parse(FloatKind::Half, "f0x3c00"), Some(0x3c00));
        assert_eq!(parse(FloatKind::Double, "-0x1.8p1"), Some((-3.0f64).to_bits() as u128));
    }
}
