//! Affine maps, `(d0, d1)[s0] -> (d0 + s0, d1 * 2)`: read from an
//! `affine_map<...>` attribute's text, with symbols given values, and
//! printed back as MLIR prints them. See `docs/mlir/01-language.md`,
//! section 6.

use std::fmt;

/// An affine expression over dimensions and symbols.
#[derive(Clone, PartialEq, Eq, Debug)]
pub enum Expr {
    Dim(usize),
    Sym(usize),
    Const(i64),
    Add(Box<Expr>, Box<Expr>),
    Mul(Box<Expr>, Box<Expr>),
    FloorDiv(Box<Expr>, Box<Expr>),
    CeilDiv(Box<Expr>, Box<Expr>),
    Mod(Box<Expr>, Box<Expr>),
}

/// `(d0, ..)[s0, ..] -> (results)`.
#[derive(Clone, PartialEq, Eq, Debug)]
pub struct Map {
    pub dims: usize,
    pub syms: usize,
    pub results: Vec<Expr>,
}

impl Map {
    /// Reads a map from the text inside `affine_map<...>`.
    pub fn parse(text: &str) -> Result<Map, String> {
        let mut p = P { s: text.as_bytes(), i: 0, dims: Vec::new(), syms: Vec::new() };
        p.dims = p.names(b'(', b')')?;
        p.ws();
        if p.peek() == Some(b'[') {
            p.syms = p.names(b'[', b']')?;
        }
        p.ws();
        if !p.s[p.i..].starts_with(b"->") {
            return Err(format!("expected '->' in affine map '{text}'"));
        }
        p.i += 2;
        p.ws();
        p.expect(b'(')?;
        let mut results = Vec::new();
        p.ws();
        if p.peek() != Some(b')') {
            loop {
                results.push(p.expr()?);
                p.ws();
                if p.peek() == Some(b',') {
                    p.i += 1;
                } else {
                    break;
                }
            }
        }
        p.expect(b')')?;
        p.ws();
        if p.i != p.s.len() {
            return Err(format!("unexpected text at the end of affine map '{text}'"));
        }
        Ok(Map { dims: p.dims.len(), syms: p.syms.len(), results })
    }

    /// The identity map on `n` dimensions.
    pub fn identity(n: usize) -> Map {
        Map { dims: n, syms: 0, results: (0..n).map(Expr::Dim).collect() }
    }

    /// The map with each symbol replaced by its value, and no symbols.
    pub fn bind(&self, values: &[i64]) -> Map {
        Map { dims: self.dims, syms: 0, results: self.results.iter().map(|e| e.bind(values).simplify()).collect() }
    }

    /// Whether result `k` is just a dimension, and which.
    pub fn dim_of(&self, k: usize) -> Option<usize> {
        match self.results[k] {
            Expr::Dim(d) => Some(d),
            _ => None,
        }
    }
}

impl Expr {
    fn bind(&self, values: &[i64]) -> Expr {
        let b = |e: &Expr| Box::new(e.bind(values));
        match self {
            Expr::Sym(s) => Expr::Const(values[*s]),
            Expr::Dim(_) | Expr::Const(_) => self.clone(),
            Expr::Add(a, c) => Expr::Add(b(a), b(c)),
            Expr::Mul(a, c) => Expr::Mul(b(a), b(c)),
            Expr::FloorDiv(a, c) => Expr::FloorDiv(b(a), b(c)),
            Expr::CeilDiv(a, c) => Expr::CeilDiv(b(a), b(c)),
            Expr::Mod(a, c) => Expr::Mod(b(a), b(c)),
        }
    }

    /// Folds constants, and multiplications by 1 and additions of 0.
    pub fn simplify(&self) -> Expr {
        match self {
            Expr::Add(a, b) => match (a.simplify(), b.simplify()) {
                (Expr::Const(x), Expr::Const(y)) => Expr::Const(x + y),
                (Expr::Const(0), e) | (e, Expr::Const(0)) => e,
                (x, y) => Expr::Add(Box::new(x), Box::new(y)),
            },
            Expr::Mul(a, b) => match (a.simplify(), b.simplify()) {
                (Expr::Const(x), Expr::Const(y)) => Expr::Const(x * y),
                (Expr::Const(1), e) | (e, Expr::Const(1)) => e,
                (Expr::Const(0), _) | (_, Expr::Const(0)) => Expr::Const(0),
                (x, y) => Expr::Mul(Box::new(x), Box::new(y)),
            },
            _ => self.clone(),
        }
    }

    /// The value at these dimension values (symbols must be bound).
    pub fn eval(&self, dims: &[i64]) -> i64 {
        match self {
            Expr::Dim(d) => dims[*d],
            Expr::Sym(_) => panic!("eval: unbound symbol"),
            Expr::Const(c) => *c,
            Expr::Add(a, b) => a.eval(dims) + b.eval(dims),
            Expr::Mul(a, b) => a.eval(dims) * b.eval(dims),
            Expr::FloorDiv(a, b) => a.eval(dims).div_euclid(b.eval(dims)),
            Expr::CeilDiv(a, b) => -((-a.eval(dims)).div_euclid(b.eval(dims))),
            Expr::Mod(a, b) => a.eval(dims).rem_euclid(b.eval(dims)),
        }
    }

    fn write(&self, f: &mut fmt::Formatter<'_>, nested: bool) -> fmt::Result {
        let paren = nested && !matches!(self, Expr::Dim(_) | Expr::Sym(_) | Expr::Const(_));
        if paren {
            f.write_str("(")?;
        }
        match self {
            Expr::Dim(d) => write!(f, "d{d}")?,
            Expr::Sym(s) => write!(f, "s{s}")?,
            Expr::Const(c) => write!(f, "{c}")?,
            Expr::Add(a, b) => {
                a.write(f, false)?;
                match &**b {
                    Expr::Const(c) if *c < 0 => write!(f, " - {}", -c)?,
                    Expr::Mul(x, y) if **y == Expr::Const(-1) => {
                        f.write_str(" - ")?;
                        x.write(f, true)?;
                    }
                    _ => {
                        f.write_str(" + ")?;
                        b.write(f, false)?;
                    }
                }
            }
            Expr::Mul(a, b) => {
                a.write(f, true)?;
                f.write_str(" * ")?;
                b.write(f, true)?;
            }
            Expr::FloorDiv(a, b) | Expr::CeilDiv(a, b) | Expr::Mod(a, b) => {
                let op = match self {
                    Expr::FloorDiv(..) => "floordiv",
                    Expr::CeilDiv(..) => "ceildiv",
                    _ => "mod",
                };
                a.write(f, true)?;
                write!(f, " {op} ")?;
                b.write(f, true)?;
            }
        }
        if paren {
            f.write_str(")")?;
        }
        Ok(())
    }
}

impl fmt::Display for Expr {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        self.write(f, false)
    }
}

impl fmt::Display for Map {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        let dims: Vec<String> = (0..self.dims).map(|d| format!("d{d}")).collect();
        write!(f, "({})", dims.join(", "))?;
        if self.syms > 0 {
            let syms: Vec<String> = (0..self.syms).map(|s| format!("s{s}")).collect();
            write!(f, "[{}]", syms.join(", "))?;
        }
        f.write_str(" -> (")?;
        for (i, e) in self.results.iter().enumerate() {
            if i > 0 {
                f.write_str(", ")?;
            }
            write!(f, "{e}")?;
        }
        f.write_str(")")
    }
}

struct P<'a> {
    s: &'a [u8],
    i: usize,
    dims: Vec<String>,
    syms: Vec<String>,
}

impl P<'_> {
    fn ws(&mut self) {
        while self.i < self.s.len() && self.s[self.i].is_ascii_whitespace() {
            self.i += 1;
        }
    }

    fn peek(&self) -> Option<u8> {
        self.s.get(self.i).copied()
    }

    fn expect(&mut self, c: u8) -> Result<(), String> {
        self.ws();
        if self.peek() == Some(c) {
            self.i += 1;
            Ok(())
        } else {
            Err(format!("expected '{}' in affine map at offset {}", c as char, self.i))
        }
    }

    fn word(&mut self) -> &str {
        self.ws();
        let start = self.i;
        while self.i < self.s.len() && (self.s[self.i].is_ascii_alphanumeric() || self.s[self.i] == b'_') {
            self.i += 1;
        }
        std::str::from_utf8(&self.s[start..self.i]).unwrap_or("")
    }

    fn names(&mut self, open: u8, close: u8) -> Result<Vec<String>, String> {
        self.expect(open)?;
        let mut names = Vec::new();
        self.ws();
        if self.peek() == Some(close) {
            self.i += 1;
            return Ok(names);
        }
        loop {
            let w = self.word().to_string();
            if w.is_empty() {
                return Err("expected a name in an affine map".to_string());
            }
            names.push(w);
            self.ws();
            match self.peek() {
                Some(b',') => self.i += 1,
                Some(c) if c == close => {
                    self.i += 1;
                    return Ok(names);
                }
                _ => return Err("expected ',' or the end of the names in an affine map".to_string()),
            }
        }
    }

    fn expr(&mut self) -> Result<Expr, String> {
        let mut e = self.term()?;
        loop {
            self.ws();
            match self.peek() {
                Some(b'+') => {
                    self.i += 1;
                    e = Expr::Add(Box::new(e), Box::new(self.term()?));
                }
                Some(b'-') if self.s.get(self.i + 1) != Some(&b'>') => {
                    self.i += 1;
                    let t = self.term()?;
                    e = Expr::Add(Box::new(e), Box::new(Expr::Mul(Box::new(t), Box::new(Expr::Const(-1)))));
                }
                _ => return Ok(e),
            }
        }
    }

    fn term(&mut self) -> Result<Expr, String> {
        let mut e = self.factor()?;
        loop {
            self.ws();
            if self.peek() == Some(b'*') {
                self.i += 1;
                e = Expr::Mul(Box::new(e), Box::new(self.factor()?));
                continue;
            }
            let save = self.i;
            let w = self.word().to_string();
            match w.as_str() {
                "floordiv" => e = Expr::FloorDiv(Box::new(e), Box::new(self.factor()?)),
                "ceildiv" => e = Expr::CeilDiv(Box::new(e), Box::new(self.factor()?)),
                "mod" => e = Expr::Mod(Box::new(e), Box::new(self.factor()?)),
                _ => {
                    self.i = save;
                    return Ok(e);
                }
            }
        }
    }

    fn factor(&mut self) -> Result<Expr, String> {
        self.ws();
        match self.peek() {
            Some(b'(') => {
                self.i += 1;
                let e = self.expr()?;
                self.expect(b')')?;
                Ok(e)
            }
            Some(b'-') => {
                self.i += 1;
                let f = self.factor()?;
                Ok(match f {
                    Expr::Const(c) => Expr::Const(-c),
                    f => Expr::Mul(Box::new(f), Box::new(Expr::Const(-1))),
                })
            }
            Some(c) if c.is_ascii_digit() => {
                let start = self.i;
                while self.peek().is_some_and(|c| c.is_ascii_digit()) {
                    self.i += 1;
                }
                let text = std::str::from_utf8(&self.s[start..self.i]).unwrap();
                text.parse().map(Expr::Const).map_err(|_| format!("bad number '{text}' in an affine map"))
            }
            _ => {
                let w = self.word().to_string();
                if let Some(d) = self.dims.iter().position(|n| *n == w) {
                    Ok(Expr::Dim(d))
                } else if let Some(s) = self.syms.iter().position(|n| *n == w) {
                    Ok(Expr::Sym(s))
                } else {
                    Err(format!("unknown name '{w}' in an affine map"))
                }
            }
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn read_and_print() {
        for text in [
            "(d0, d1) -> (d0, d1)",
            "(d0, d1) -> (d1)",
            "(d0, d1, d2, d3, d4, d5, d6) -> (d0, d4, d2 + d5, d3 + d6)",
            "()[s0] -> (s0, 4)",
            "(d0) -> ()",
            "(d0, d1) -> (0, d1)",
            "(d0) -> (d0 floordiv 2, d0 mod 2)",
        ] {
            assert_eq!(Map::parse(text).unwrap().to_string(), text);
        }
    }

    #[test]
    fn bind_and_eval() {
        let m = Map::parse("(d0, d1)[s0, s1] -> (d0 * s0 + d1 * s1 - 1)").unwrap();
        let b = m.bind(&[2, 1]);
        assert_eq!(b.to_string(), "(d0, d1) -> (d0 * 2 + d1 - 1)");
        assert_eq!(b.results[0].eval(&[3, 4]), 9);
        assert_eq!(Map::parse("(d0) -> (d0 floordiv 2)").unwrap().results[0].eval(&[-3]), -2);
    }
}
