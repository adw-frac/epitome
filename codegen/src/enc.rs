//! Encodings: the `"enc"` attribute of an instruction.
//!
//! An encoding is a list of tokens, most significant bit first, adding up
//! to 32 bits. A token is literal bits (`01011`) or a field
//! `name:width[=expr]`, where a width written `s19` is signed. Expressions
//! have integers, operand names, `+ - * / % & | ^ << >>`, and the
//! functions `bitmask32`, `bitmask64` (logical immediates) and `log2`
//! (defined only for powers of two). Without an
//! expression the field holds the operand called `name`.
//!
//! Encoding evaluates each field's expression on the operands. Decoding
//! inverts fields to recover operands (`off = imm12 * 8` from
//! `imm12:12=off/8`) and keeps the result only if encoding it again gives
//! the same word. The same round trip decides which immediates fit: a value
//! fits if it survives being encoded and decoded.

use std::collections::HashMap;
use std::fmt;

#[derive(Clone, Debug, PartialEq)]
pub enum Expr {
    Int(i64),
    Var(String),
    Neg(Box<Expr>),
    Bin(char, Box<Expr>, Box<Expr>),
    /// `bitmask32(x)` or `bitmask64(x)`: a logical immediate's N:immr:imms.
    Bitmask(u32, Box<Expr>),
    /// `log2(x)`: defined only when `x` is a power of two.
    Log2(Box<Expr>),
}

impl fmt::Display for Expr {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Expr::Int(k) => write!(f, "{k}"),
            Expr::Var(v) => f.write_str(v),
            Expr::Neg(e) => write!(f, "-{e}"),
            Expr::Bin(op, a, b) => match op {
                '<' => write!(f, "({a}<<{b})"),
                '>' => write!(f, "({a}>>{b})"),
                op => write!(f, "({a}{op}{b})"),
            },
            Expr::Bitmask(w, e) => write!(f, "bitmask{w}({e})"),
            Expr::Log2(e) => write!(f, "log2({e})"),
        }
    }
}

#[derive(Clone, Debug)]
pub struct Field {
    pub name: String,
    /// The lowest bit's position in the word.
    pub lo: u32,
    pub width: u32,
    pub signed: bool,
    pub expr: Expr,
    /// The operands the expression reads.
    pub names: Vec<String>,
    /// The expression has no `%` or `&`, so inverting it gives the operand
    /// exactly.
    pub plain: bool,
}

#[derive(Clone, Debug)]
pub struct Encoding {
    /// Bits fixed by literals.
    pub mask: u32,
    pub value: u32,
    pub fields: Vec<Field>,
}

pub type Env = HashMap<String, i64>;

// ---------------------------------------------------------------------------
// Parsing

pub fn parse(text: &str) -> Result<Encoding, String> {
    let mut tokens: Vec<(Option<Field>, String)> = Vec::new();
    let mut total = 0u32;
    for tok in text.split_whitespace() {
        if tok.bytes().all(|c| c == b'0' || c == b'1') {
            total += tok.len() as u32;
            tokens.push((None, tok.to_string()));
            continue;
        }
        let (head, expr) = match tok.split_once('=') {
            Some((h, e)) => (h, Some(e)),
            None => (tok, None),
        };
        let (name, width) = head.split_once(':').ok_or_else(|| format!("bad encoding token `{tok}`"))?;
        let (signed, digits) = match width.strip_prefix('s') {
            Some(d) => (true, d),
            None => (false, width),
        };
        let width: u32 = digits.parse().map_err(|_| format!("bad field width in `{tok}`"))?;
        let expr = match expr {
            Some(e) => parse_expr(e)?,
            None => Expr::Var(name.to_string()),
        };
        total += width;
        let mut names = Vec::new();
        names_in(&expr, &mut names);
        let plain = !format!("{expr}").contains(['%', '&']);
        tokens.push((Some(Field { name: name.to_string(), lo: 0, width, signed, expr, names, plain }), String::new()));
    }
    if total != 32 {
        return Err(format!("encoding has {total} bits, not 32: `{text}`"));
    }
    let mut enc = Encoding { mask: 0, value: 0, fields: Vec::new() };
    let mut pos = 32u32;
    for (field, bits) in tokens {
        match field {
            None => {
                for c in bits.bytes() {
                    pos -= 1;
                    enc.mask |= 1 << pos;
                    if c == b'1' {
                        enc.value |= 1 << pos;
                    }
                }
            }
            Some(mut f) => {
                pos -= f.width;
                f.lo = pos;
                enc.fields.push(f);
            }
        }
    }
    Ok(enc)
}

/// Parses an expression: integers, names, `+ - * / % & | ^ << >>`,
/// parentheses, unary minus and `bitmask32(..)`/`bitmask64(..)`.
pub fn parse_expr(text: &str) -> Result<Expr, String> {
    let toks = lex(text)?;
    let mut p = ExprParser { toks, pos: 0 };
    let e = p.expr(0)?;
    if p.pos != p.toks.len() {
        return Err(format!("unexpected `{}` in `{text}`", p.toks[p.pos]));
    }
    Ok(e)
}

fn lex(text: &str) -> Result<Vec<String>, String> {
    let b = text.as_bytes();
    let mut out = Vec::new();
    let mut i = 0;
    while i < b.len() {
        let c = b[i];
        if c.is_ascii_whitespace() {
            i += 1;
        } else if c.is_ascii_alphanumeric() || c == b'_' || c == b'.' {
            let s = i;
            while i < b.len() && (b[i].is_ascii_alphanumeric() || b[i] == b'_' || b[i] == b'.') {
                i += 1;
            }
            out.push(text[s..i].to_string());
        } else if (c == b'<' || c == b'>') && b.get(i + 1) == Some(&c) {
            out.push(text[i..i + 2].to_string());
            i += 2;
        } else if b"+-*/%&|^()".contains(&c) {
            out.push((c as char).to_string());
            i += 1;
        } else {
            return Err(format!("unexpected `{}` in `{text}`", c as char));
        }
    }
    Ok(out)
}

struct ExprParser {
    toks: Vec<String>,
    pos: usize,
}

fn precedence(op: &str) -> Option<(u8, char)> {
    Some(match op {
        "|" => (1, '|'),
        "^" => (2, '^'),
        "&" => (3, '&'),
        "<<" => (4, '<'),
        ">>" => (4, '>'),
        "+" => (5, '+'),
        "-" => (5, '-'),
        "*" => (6, '*'),
        "/" => (6, '/'),
        "%" => (6, '%'),
        _ => return None,
    })
}

impl ExprParser {
    fn peek(&self) -> Option<&str> {
        self.toks.get(self.pos).map(|s| s.as_str())
    }

    fn expr(&mut self, min: u8) -> Result<Expr, String> {
        let mut lhs = self.atom()?;
        while let Some((prec, op)) = self.peek().and_then(precedence) {
            if prec <= min {
                break;
            }
            self.pos += 1;
            let rhs = self.expr(prec)?;
            lhs = Expr::Bin(op, Box::new(lhs), Box::new(rhs));
        }
        Ok(lhs)
    }

    fn atom(&mut self) -> Result<Expr, String> {
        let t = self.toks.get(self.pos).cloned().ok_or("expression ends early")?;
        self.pos += 1;
        if t == "(" {
            let e = self.expr(0)?;
            if self.peek() != Some(")") {
                return Err("missing `)`".into());
            }
            self.pos += 1;
            return Ok(e);
        }
        if t == "-" {
            return Ok(Expr::Neg(Box::new(self.atom()?)));
        }
        if let Some(rest) = t.strip_prefix("0x") {
            return i64::from_str_radix(rest, 16).map(Expr::Int).map_err(|_| format!("bad number `{t}`"));
        }
        if t.bytes().next().is_some_and(|c| c.is_ascii_digit()) {
            return t.parse().map(Expr::Int).map_err(|_| format!("bad number `{t}`"));
        }
        if t == "log2" && self.peek() == Some("(") {
            self.pos += 1;
            let e = self.expr(0)?;
            if self.peek() != Some(")") {
                return Err("missing `)`".into());
            }
            self.pos += 1;
            return Ok(Expr::Log2(Box::new(e)));
        }
        if (t == "bitmask32" || t == "bitmask64") && self.peek() == Some("(") {
            self.pos += 1;
            let e = self.expr(0)?;
            if self.peek() != Some(")") {
                return Err("missing `)`".into());
            }
            self.pos += 1;
            return Ok(Expr::Bitmask(if t == "bitmask32" { 32 } else { 64 }, Box::new(e)));
        }
        Ok(Expr::Var(t))
    }
}

// ---------------------------------------------------------------------------
// Evaluating

pub fn eval(e: &Expr, env: &Env) -> Option<i64> {
    Some(match e {
        Expr::Int(k) => *k,
        Expr::Var(v) => *env.get(v)?,
        Expr::Neg(a) => eval(a, env)?.wrapping_neg(),
        Expr::Bin(op, a, b) => {
            let (a, b) = (eval(a, env)?, eval(b, env)?);
            match op {
                '+' => a.wrapping_add(b),
                '-' => a.wrapping_sub(b),
                '*' => a.wrapping_mul(b),
                '/' => a.checked_div(b)?,
                '%' => a.checked_rem_euclid(b)?,
                '&' => a & b,
                '|' => a | b,
                '^' => a ^ b,
                '<' => a.checked_shl(b as u32)?,
                '>' => a.checked_shr(b as u32)?,
                _ => return None,
            }
        }
        Expr::Bitmask(w, a) => encode_bitmask(eval(a, env)? as u64, *w)? as i64,
        Expr::Log2(a) => {
            let v = eval(a, env)?;
            if v <= 0 || v & (v - 1) != 0 {
                return None;
            }
            v.trailing_zeros() as i64
        }
    })
}

/// Solves `e == target` for the one name in `e`, when `e` is made of
/// steps that can be undone. Returns the name and its value.
fn invert(e: &Expr, target: i64) -> Option<(String, i64)> {
    match e {
        Expr::Var(v) => Some((v.clone(), target)),
        Expr::Neg(a) => invert(a, target.wrapping_neg()),
        Expr::Bitmask(w, a) => invert(a, decode_bitmask(target as u64, *w)? as i64),
        Expr::Log2(a) => invert(a, 1i64.checked_shl(u32::try_from(target).ok()?)?),
        Expr::Bin(op, a, b) => {
            let ka = eval(a, &Env::new());
            let kb = eval(b, &Env::new());
            match (op, ka, kb) {
                ('+', None, Some(k)) => invert(a, target.wrapping_sub(k)),
                ('+', Some(k), None) => invert(b, target.wrapping_sub(k)),
                ('-', None, Some(k)) => invert(a, target.wrapping_add(k)),
                ('-', Some(k), None) => invert(b, k.wrapping_sub(target)),
                ('/', None, Some(k)) => invert(a, target.wrapping_mul(k)),
                ('*', None, Some(k)) if k != 0 && target % k == 0 => invert(a, target / k),
                ('>', None, Some(k)) => invert(a, target.checked_shl(k as u32)?),
                ('<', None, Some(k)) => invert(a, target.checked_shr(k as u32)?),
                ('^', None, Some(k)) => invert(a, target ^ k),
                ('^', Some(k), None) => invert(b, target ^ k),
                // `x % m == f` or `x & m == f`: take `x = f` (the other
                // fields put the rest back); the re-encoding check decides.
                ('%' | '&', None, Some(_)) => invert(a, target),
                _ => None,
            }
        }
        Expr::Int(_) => None,
    }
}

fn names_in(e: &Expr, out: &mut Vec<String>) {
    match e {
        Expr::Var(v) => {
            if !out.contains(v) {
                out.push(v.clone());
            }
        }
        Expr::Int(_) => {}
        Expr::Neg(a) | Expr::Bitmask(_, a) | Expr::Log2(a) => names_in(a, out),
        Expr::Bin(_, a, b) => {
            names_in(a, out);
            names_in(b, out);
        }
    }
}

impl Encoding {
    /// The word for these operand values, or `None` if a field cannot hold
    /// its value.
    pub fn encode(&self, env: &Env) -> Option<u32> {
        let mut word = self.value;
        for f in &self.fields {
            let v = eval(&f.expr, env)?;
            let fits = if f.signed {
                let half = 1i64 << (f.width - 1);
                (-half..half).contains(&v)
            } else {
                v >= 0 && (f.width >= 63 || v < (1i64 << f.width))
            };
            if !fits {
                return None;
            }
            let m = if f.width == 32 { u32::MAX } else { (1u32 << f.width) - 1 };
            word |= ((v as u32) & m) << f.lo;
        }
        Some(word)
    }

    /// The raw value of field `f` in `word`, sign-extended if signed.
    pub fn field_value(&self, f: &Field, word: u32) -> i64 {
        let m = if f.width == 32 { u32::MAX } else { (1u32 << f.width) - 1 };
        let raw = ((word >> f.lo) & m) as i64;
        if f.signed && raw >= 1 << (f.width - 1) { raw - (1 << f.width) } else { raw }
    }

    /// Recovers the values of `operands` from `word`, or `None` if `word`
    /// is not this encoding. Operands in `free` (such as symbols, whose
    /// fields hold zero until linking) may be left out.
    pub fn decode(&self, word: u32, operands: &[String]) -> Option<Env> {
        if word & self.mask != self.value {
            return None;
        }
        let mut env = Env::new();
        for name in operands {
            // Prefer a field that is just the operand, then any other.
            let mut best: Option<i64> = None;
            for pass in 0..2 {
                for f in &self.fields {
                    if f.names.as_slice() != std::slice::from_ref(name) {
                        continue;
                    }
                    if (pass == 0) != f.plain {
                        continue;
                    }
                    if let Some((_, v)) = invert(&f.expr, self.field_value(f, word)) {
                        best = Some(v);
                        break;
                    }
                }
                if best.is_some() {
                    break;
                }
            }
            let mut v = best?;
            // A value split over fields, `name>>k` and `name&m` (adrp's
            // immhi and immlo), or `name/k` and `name%k`: the low bits go
            // back on.
            for f in &self.fields {
                let Expr::Bin(op @ ('%' | '&'), a, k) = &f.expr else { continue };
                if **a != Expr::Var(name.clone()) {
                    continue;
                }
                match (op, &**k) {
                    ('%', Expr::Int(k)) if *k > 0 => v = v - v.rem_euclid(*k) + self.field_value(f, word),
                    ('&', Expr::Int(m)) if (*m + 1).count_ones() == 1 => v = (v & !*m) | self.field_value(f, word),
                    _ => {}
                }
            }
            env.insert(name.clone(), v);
        }
        (self.encode(&env)? == word).then_some(env)
    }

    /// Does this value of operand `name` fit, with the other operands as
    /// in `env`? Fits means it survives an encode and decode unchanged.
    pub fn fits(&self, env: &Env, operands: &[String]) -> bool {
        match self.encode(env) {
            Some(word) => {
                self.decode(word, operands).is_some_and(|back| operands.iter().all(|o| back.get(o) == env.get(o)))
            }
            None => false,
        }
    }
}

// ---------------------------------------------------------------------------
// Logical immediates

fn ones(n: u32) -> u64 {
    if n >= 64 { u64::MAX } else { (1u64 << n) - 1 }
}

fn ror(x: u64, r: u32, e: u32) -> u64 {
    let r = r % e;
    if r == 0 {
        return x;
    }
    ((x >> r) | (x << (e - r))) & ones(e)
}

/// The 13-bit N:immr:imms for `value` as a `width`-bit logical immediate:
/// a rotated run of ones in an element of 2, 4, ..., 64 bits, repeated.
pub fn encode_bitmask(value: u64, width: u32) -> Option<u32> {
    let v = value & ones(width);
    if v == 0 || v == ones(width) {
        return None;
    }
    let mut e = 2;
    while e < width {
        let m = ones(e);
        let elem = v & m;
        let mut rep = elem;
        let mut k = e;
        while k < width {
            rep |= elem << k;
            k += e;
        }
        if rep == v {
            break;
        }
        e *= 2;
    }
    let elem = v & ones(e);
    let s = elem.count_ones();
    if s == 0 || s == e {
        return None;
    }
    let r = (0..e).find(|&r| ror(ones(s), r, e) == elem)?;
    let n = u32::from(e == 64);
    let imms = ((!(2 * e - 1)) & 0x3f) | (s - 1);
    Some((n << 12) | (r << 6) | imms)
}

/// The value of a 13-bit N:immr:imms logical immediate of `width` bits.
pub fn decode_bitmask(bits: u64, width: u32) -> Option<u64> {
    let n = (bits >> 12) & 1;
    let immr = ((bits >> 6) & 0x3f) as u32;
    let imms = (bits & 0x3f) as u32;
    if width == 32 && n == 1 {
        return None;
    }
    let combined = ((n as u32) << 6) | (!imms & 0x3f);
    if combined == 0 {
        return None;
    }
    let len = 31 - combined.leading_zeros();
    if len < 1 {
        return None;
    }
    let levels = (1u32 << len) - 1;
    let s = imms & levels;
    let r = immr & levels;
    if s == levels {
        return None;
    }
    let e = 1u32 << len;
    let elem = ror(ones(s + 1), r, e);
    let mut v = 0u64;
    let mut k = 0;
    while k < width {
        v |= elem << k;
        k += e;
    }
    Some(v & ones(width))
}

#[cfg(test)]
mod tests {
    use super::*;

    fn env(pairs: &[(&str, i64)]) -> Env {
        pairs.iter().map(|(k, v)| (k.to_string(), *v)).collect()
    }

    #[test]
    fn add_immediate() {
        // add w0, w1, #5
        let e = parse("0 0 0 100010 0 imm:12 n:5 d:5").unwrap();
        let w = e.encode(&env(&[("imm", 5), ("n", 1), ("d", 0)])).unwrap();
        assert_eq!(w, 0x11001420);
        let ops: Vec<String> = ["d", "n", "imm"].iter().map(|s| s.to_string()).collect();
        assert_eq!(e.decode(w, &ops).unwrap()["imm"], 5);
        assert!(!e.fits(&env(&[("imm", 4096), ("n", 1), ("d", 0)]), &ops));
    }

    #[test]
    fn scaled_and_signed_fields() {
        let e = parse("11 111 0 01 01 imm12:12=off/8 n:5 d:5").unwrap();
        let ops: Vec<String> = ["d", "n", "off"].iter().map(|s| s.to_string()).collect();
        assert!(e.fits(&env(&[("off", 16), ("n", 4), ("d", 3)]), &ops));
        assert!(!e.fits(&env(&[("off", 12), ("n", 4), ("d", 3)]), &ops));
        // ldr x3, [x4, #16]
        assert_eq!(e.encode(&env(&[("off", 16), ("n", 4), ("d", 3)])), Some(0xf9400883));
        let b = parse("01010100 imm19:s19=dest/4 0 c:4").unwrap();
        let ops: Vec<String> = ["dest", "c"].iter().map(|s| s.to_string()).collect();
        let w = b.encode(&env(&[("dest", -8), ("c", 11)])).unwrap();
        assert_eq!(b.decode(w, &ops).unwrap()["dest"], -8);
    }

    #[test]
    fn bitmasks_round_trip() {
        for w in [32, 64] {
            let mut n = 0;
            for bits in 0..(1u64 << 13) {
                if let Some(v) = decode_bitmask(bits, w) {
                    n += 1;
                    let back = encode_bitmask(v, w).unwrap();
                    assert_eq!(decode_bitmask(back as u64, w), Some(v));
                }
            }
            assert!(n > 1000, "{n}");
        }
        assert_eq!(encode_bitmask(0xff, 32), Some(0b0_000000_000111));
        assert_eq!(encode_bitmask(0, 32), None);
        assert_eq!(encode_bitmask(5, 32), None);
    }
}
