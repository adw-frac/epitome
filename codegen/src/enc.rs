//! Encodings: the `"enc"` attribute of an instruction.
//!
//! An encoding is a list of *pieces* separated by `|`. A piece is written
//! most significant bit first, as a list of tokens, and is a whole number
//! of bytes (up to 8); a piece of several bytes is stored little-endian.
//! AArch64's and RISC-V's encodings are one 32-bit piece. A token is
//! literal bits (`01011`) or a field `name:width[=expr]`, where a width
//! written `s19` is signed and a width of 0 holds nothing (its expression
//! must be 0: a constraint, and on decoding, a value). Expressions have
//! integers, operand names (which may contain dots: `m.base`), `+ - * / %
//! & | ^ << >>`, the comparisons `== != < <= > >=` (1 or 0), and the
//! functions `bitmask32`, `bitmask64` (logical immediates), `log2`
//! (defined only for powers of two), and `fp8s`, `fp8d` (a `float`'s or
//! `double`'s bits as an 8-bit floating-point immediate, defined only for
//! the values one can hold). Without an expression the field holds the
//! operand called `name`. `end` is the encoding's length in bytes, so a
//! field `rel:s8=dest-end` holds a target measured from the instruction's
//! end (operands are measured from its start).
//!
//! `{ a ; b ; c }` gives alternatives, and `{ a ; }` makes `a` optional. An
//! alternative may start with guards, `if(expr)`, which must be non-zero
//! for it to be used, encoding or decoding. The first alternative, in the
//! order written, whose guards hold and whose fields hold the operands is
//! the one used; when there are several, its encoding must also decode
//! back to the same operands, so the shortest form that can hold them
//! wins.
//!
//! A *fragment* is a named encoding defined in the description, in
//! `!target.encodings` as `!{!"name", !"params", !"encoding"}`, and used
//! as `name(arg, ...)`: its parameters are replaced by the arguments.
//!
//! Encoding evaluates each field's expression on the operands. Decoding
//! inverts fields to recover operands (`off = imm12 * 8` from
//! `imm12:12=off/8`) and keeps the result only if encoding it again gives
//! the same bytes. The same round trip decides which immediates fit: a
//! value fits if it survives being encoded and decoded.

use std::collections::HashMap;
use std::fmt;

#[derive(Clone, Debug, PartialEq)]
pub enum Expr {
    Int(i64),
    Var(String),
    Neg(Box<Expr>),
    /// An operator: `+ - * / % & | ^`, `<` for `<<`, `>` for `>>`, and the
    /// comparisons `=` (`==`), `!` (`!=`), `l` (`<`), `L` (`<=`), `g`
    /// (`>`), `G` (`>=`).
    Bin(char, Box<Expr>, Box<Expr>),
    /// `bitmask32(x)` or `bitmask64(x)`: a logical immediate's N:immr:imms.
    Bitmask(u32, Box<Expr>),
    /// `log2(x)`: defined only when `x` is a power of two.
    Log2(Box<Expr>),
    /// `fp8s(x)` or `fp8d(x)`: a float's or double's bits as the 8-bit
    /// immediate of `fmov` (sign, 3 bits of exponent, 4 of fraction).
    Fp8(u32, Box<Expr>),
}

impl fmt::Display for Expr {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Expr::Int(k) => write!(f, "{k}"),
            Expr::Var(v) => f.write_str(v),
            Expr::Neg(e) => write!(f, "-{e}"),
            Expr::Bin(op, a, b) => {
                let text = match op {
                    '<' => "<<",
                    '>' => ">>",
                    '=' => "==",
                    '!' => "!=",
                    'l' => "<",
                    'L' => "<=",
                    'g' => ">",
                    'G' => ">=",
                    '+' => "+",
                    '-' => "-",
                    '*' => "*",
                    '/' => "/",
                    '%' => "%",
                    '&' => "&",
                    '|' => "|",
                    _ => "^",
                };
                write!(f, "({a}{text}{b})")
            }
            Expr::Bitmask(w, e) => write!(f, "bitmask{w}({e})"),
            Expr::Log2(e) => write!(f, "log2({e})"),
            Expr::Fp8(w, e) => write!(f, "fp8{}({e})", if *w == 32 { "s" } else { "d" }),
        }
    }
}

#[derive(Clone, Debug)]
pub struct Field {
    pub name: String,
    /// The piece it is in, and its lowest bit's position there.
    pub piece: usize,
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

/// A piece: a whole number of bytes, little-endian.
#[derive(Clone, Debug)]
pub struct Piece {
    /// Its first byte's offset in the encoding.
    pub offset: u32,
    pub bytes: u32,
    /// Bits fixed by literals.
    pub mask: u64,
    pub value: u64,
}

/// One alternative: its guards, pieces and fields.
#[derive(Clone, Debug)]
pub struct Alt {
    pub guards: Vec<Expr>,
    pub pieces: Vec<Piece>,
    pub fields: Vec<Field>,
    /// Its length in bytes.
    pub len: u32,
    /// The operand names its fields and guards read.
    pub names: Vec<String>,
}

#[derive(Clone, Debug, Default)]
pub struct Encoding {
    pub alts: Vec<Alt>,
}

pub type Env = HashMap<String, i64>;

/// Fragments by name: their parameters and their encoding's text.
pub type Fragments = HashMap<String, (Vec<String>, String)>;

/// A little-endian word of up to 8 bytes.
pub fn word(bytes: &[u8]) -> u64 {
    bytes.iter().rev().fold(0u64, |acc, &b| (acc << 8) | b as u64)
}

// ---------------------------------------------------------------------------
// Parsing

pub fn parse(text: &str) -> Result<Encoding, String> {
    parse_with(text, &Fragments::new())
}

/// Parses an encoding, with `fragments` to expand.
pub fn parse_with(text: &str, fragments: &Fragments) -> Result<Encoding, String> {
    let expanded = expand(text, fragments, 0)?;
    let toks = tokens(&expanded)?;
    let mut pos = 0;
    let seq = parse_seq(&toks, &mut pos)?;
    if pos != toks.len() {
        return Err(format!("unexpected `{}` in encoding `{text}`", toks[pos]));
    }
    let mut alts = Vec::new();
    for (guards, flat) in flatten(&seq) {
        alts.push(build_alt(guards, &flat).map_err(|e| format!("{e}: `{text}`"))?);
    }
    Ok(Encoding { alts })
}

/// An encoding's text with its fragments' uses replaced by their
/// definitions.
fn expand(text: &str, fragments: &Fragments, depth: u32) -> Result<String, String> {
    if fragments.is_empty() {
        return Ok(text.to_string());
    }
    if depth > 16 {
        return Err(format!("fragments nested too deeply in `{text}`"));
    }
    let b = text.as_bytes();
    let mut out = String::new();
    let mut i = 0;
    while i < b.len() {
        let c = b[i];
        if c.is_ascii_alphabetic() || c == b'_' {
            let s = i;
            while i < b.len() && (b[i].is_ascii_alphanumeric() || b[i] == b'_' || b[i] == b'.') {
                i += 1;
            }
            let name = &text[s..i];
            // Not a field's name, `name:width`.
            let use_of = b.get(i) == Some(&b'(') && (s == 0 || b[s - 1] != b':');
            match fragments.get(name) {
                Some((params, body)) if use_of => {
                    let (args, after) = call_args(text, i)?;
                    if args.len() != params.len() {
                        return Err(format!("{name} takes {} arguments, not {}", params.len(), args.len()));
                    }
                    let body = substitute_text(body, params, &args);
                    out.push(' ');
                    out.push_str(&expand(&body, fragments, depth + 1)?);
                    out.push(' ');
                    i = after;
                }
                _ => out.push_str(name),
            }
        } else {
            out.push(c as char);
            i += 1;
        }
    }
    Ok(out)
}

/// The arguments of a use at `open` (a `(`), and where it ends.
fn call_args(text: &str, open: usize) -> Result<(Vec<String>, usize), String> {
    let b = text.as_bytes();
    let (mut depth, mut i, mut s) = (0, open, open + 1);
    let mut args = Vec::new();
    while i < b.len() {
        match b[i] {
            b'(' => depth += 1,
            b')' => {
                depth -= 1;
                if depth == 0 {
                    let a = text[s..i].trim();
                    if !a.is_empty() || !args.is_empty() {
                        args.push(a.to_string());
                    }
                    return Ok((args, i + 1));
                }
            }
            b',' if depth == 1 => {
                args.push(text[s..i].trim().to_string());
                s = i + 1;
            }
            _ => {}
        }
        i += 1;
    }
    Err(format!("unclosed `(` in `{text}`"))
}

/// `body` with each name in `params` replaced by its argument (in
/// parentheses unless it is a name or a number), and `param.x` by
/// `arg.x`. Fields' names (before a `:`) are left alone.
fn substitute_text(body: &str, params: &[String], args: &[String]) -> String {
    let b = body.as_bytes();
    let mut out = String::new();
    let mut i = 0;
    while i < b.len() {
        let c = b[i];
        if c.is_ascii_alphabetic() || c == b'_' {
            let s = i;
            while i < b.len() && (b[i].is_ascii_alphanumeric() || b[i] == b'_' || b[i] == b'.') {
                i += 1;
            }
            let word = &body[s..i];
            let (head, tail) = match word.split_once('.') {
                Some((h, t)) => (h, Some(t)),
                None => (word, None),
            };
            let field_name = b.get(i) == Some(&b':');
            match params.iter().position(|p| p == head) {
                Some(k) if !field_name => {
                    let a = &args[k];
                    let simple = a.bytes().all(|c| c.is_ascii_alphanumeric() || c == b'_' || c == b'.');
                    match tail {
                        Some(t) => {
                            out.push_str(a);
                            out.push('.');
                            out.push_str(t);
                        }
                        None if simple => out.push_str(a),
                        None => {
                            out.push('(');
                            out.push_str(a);
                            out.push(')');
                        }
                    }
                }
                _ => out.push_str(word),
            }
        } else {
            out.push(c as char);
            i += 1;
        }
    }
    out
}

/// Tokens: `|`, `{`, `;`, `}`, guards `if(...)`, and the bits and fields
/// between them (which may hold parentheses, but no spaces outside them).
fn tokens(text: &str) -> Result<Vec<String>, String> {
    let b = text.as_bytes();
    let mut out = Vec::new();
    let mut i = 0;
    while i < b.len() {
        let c = b[i];
        if c.is_ascii_whitespace() {
            i += 1;
            continue;
        }
        if b"|{};".contains(&c) {
            out.push((c as char).to_string());
            i += 1;
            continue;
        }
        let s = i;
        let mut depth = 0;
        while i < b.len() {
            match b[i] {
                b'(' => depth += 1,
                b')' => depth -= 1,
                c if depth == 0 && (c.is_ascii_whitespace() || b"|{};".contains(&c)) => break,
                _ => {}
            }
            i += 1;
        }
        if depth != 0 {
            return Err(format!("unbalanced parentheses in `{text}`"));
        }
        out.push(text[s..i].to_string());
    }
    Ok(out)
}

#[derive(Clone, Debug)]
enum Item {
    Tok(String),
    Sep,
    Choice(Vec<(Vec<Expr>, Vec<Item>)>),
}

fn parse_seq(toks: &[String], pos: &mut usize) -> Result<Vec<Item>, String> {
    let mut seq = Vec::new();
    while *pos < toks.len() {
        let t = &toks[*pos];
        match t.as_str() {
            "}" | ";" => break,
            "|" => {
                seq.push(Item::Sep);
                *pos += 1;
            }
            "{" => {
                *pos += 1;
                let mut alts = Vec::new();
                loop {
                    let mut guards = Vec::new();
                    while let Some(g) =
                        toks.get(*pos).and_then(|t| t.strip_prefix("if(")).and_then(|g| g.strip_suffix(')'))
                    {
                        guards.push(parse_expr(g)?);
                        *pos += 1;
                    }
                    let body = parse_seq(toks, pos)?;
                    alts.push((guards, body));
                    match toks.get(*pos).map(String::as_str) {
                        Some(";") => *pos += 1,
                        Some("}") => {
                            *pos += 1;
                            break;
                        }
                        _ => return Err("an alternative not closed with `}`".into()),
                    }
                }
                seq.push(Item::Choice(alts));
            }
            _ => {
                seq.push(Item::Tok(t.clone()));
                *pos += 1;
            }
        }
    }
    Ok(seq)
}

/// Every way through `seq`'s choices, in order (earlier choices varying
/// slowest): each a list of guards and of tokens and separators.
fn flatten(seq: &[Item]) -> Vec<(Vec<Expr>, Vec<Item>)> {
    let mut ways: Vec<(Vec<Expr>, Vec<Item>)> = vec![(Vec::new(), Vec::new())];
    for item in seq {
        match item {
            Item::Choice(alts) => {
                let mut next = Vec::new();
                for (g0, w0) in &ways {
                    for (g, body) in alts {
                        for (g1, w1) in flatten(body) {
                            let mut g2 = g0.clone();
                            g2.extend(g.iter().cloned());
                            g2.extend(g1);
                            let mut w2 = w0.clone();
                            w2.extend(w1);
                            next.push((g2, w2));
                        }
                    }
                }
                ways = next;
            }
            other => {
                for (_, w) in &mut ways {
                    w.push(other.clone());
                }
            }
        }
    }
    ways
}

type Tokens = Vec<(Option<Field>, String)>;

/// An alternative from its guards and its tokens, split into pieces at
/// `|`. `end` (its length) is put into every expression.
fn build_alt(guards: Vec<Expr>, items: &[Item]) -> Result<Alt, String> {
    // Pieces: runs of tokens between separators; empty runs (around an
    // optional part left out) disappear.
    let mut runs: Vec<Vec<String>> = vec![Vec::new()];
    for it in items {
        match it {
            Item::Sep => runs.push(Vec::new()),
            Item::Tok(t) => runs.last_mut().unwrap().push(t.clone()),
            Item::Choice(_) => unreachable!("flattened"),
        }
    }
    runs.retain(|r| !r.is_empty());
    // A run of zero-width fields only (a constraint before an optional
    // prefix left out) holds no bits: it joins the next piece, or the last.
    let zero = |t: &String| t.split('=').next().is_some_and(|h| h.ends_with(":0"));
    let mut k = 0;
    while k < runs.len() {
        if runs.len() > 1 && runs[k].iter().all(zero) {
            let r = runs.remove(k);
            let at = if k < runs.len() { k } else { k - 1 };
            if at == k {
                runs[at].splice(0..0, r);
            } else {
                runs[at].extend(r);
            }
        } else {
            k += 1;
        }
    }
    // Each piece: its bits, and its tokens (fields, or literal bits).
    let mut parsed: Vec<(u32, Tokens)> = Vec::new();
    for run in &runs {
        let mut total = 0u32;
        let mut toks = Vec::new();
        for tok in run {
            if tok.bytes().all(|c| c == b'0' || c == b'1') {
                total += tok.len() as u32;
                toks.push((None, tok.clone()));
                continue;
            }
            let (head, expr) = match tok.split_once('=') {
                Some((h, e)) => (h, Some(e)),
                None => (tok.as_str(), None),
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
            let f =
                Field { name: name.to_string(), piece: 0, lo: 0, width, signed, expr, names: Vec::new(), plain: true };
            toks.push((Some(f), String::new()));
        }
        if !total.is_multiple_of(8) || total > 64 || total == 0 {
            return Err(format!("a piece of {total} bits, not a whole number of bytes up to 8"));
        }
        parsed.push((total, toks));
    }
    let len: u32 = parsed.iter().map(|(t, _)| t / 8).sum();
    let mut known = Env::new();
    known.insert("end".into(), len as i64);
    let mut alt = Alt {
        guards: guards.iter().map(|g| substitute(g, &known)).collect(),
        pieces: Vec::new(),
        fields: Vec::new(),
        len,
        names: Vec::new(),
    };
    let mut offset = 0;
    for (k, (total, toks)) in parsed.into_iter().enumerate() {
        let mut piece = Piece { offset, bytes: total / 8, mask: 0, value: 0 };
        let mut pos = total;
        for (field, bits) in toks {
            match field {
                None => {
                    for c in bits.bytes() {
                        pos -= 1;
                        piece.mask |= 1 << pos;
                        if c == b'1' {
                            piece.value |= 1 << pos;
                        }
                    }
                }
                Some(mut f) => {
                    pos -= f.width;
                    f.lo = pos;
                    f.piece = k;
                    f.expr = substitute(&f.expr, &known);
                    names_in(&f.expr, &mut f.names);
                    f.plain = !format!("{}", f.expr).contains(['%', '&']);
                    alt.fields.push(f);
                }
            }
        }
        offset += piece.bytes;
        alt.pieces.push(piece);
    }
    for f in &alt.fields {
        for n in &f.names {
            if !alt.names.contains(n) {
                alt.names.push(n.clone());
            }
        }
    }
    for g in &alt.guards {
        names_in(g, &mut alt.names);
    }
    Ok(alt)
}

/// Parses an expression: integers, names, `+ - * / % & | ^ << >>`, the
/// comparisons `== != < <= > >=`, parentheses, unary minus and the
/// functions.
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
        } else if ((c == b'<' || c == b'>') && b.get(i + 1) == Some(&c))
            || (b"=!<>".contains(&c) && b.get(i + 1) == Some(&b'='))
        {
            out.push(text[i..i + 2].to_string());
            i += 2;
        } else if b"+-*/%&|^()<>".contains(&c) {
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
        "==" => (4, '='),
        "!=" => (4, '!'),
        "<" => (5, 'l'),
        "<=" => (5, 'L'),
        ">" => (5, 'g'),
        ">=" => (5, 'G'),
        "<<" => (6, '<'),
        ">>" => (6, '>'),
        "+" => (7, '+'),
        "-" => (7, '-'),
        "*" => (8, '*'),
        "/" => (8, '/'),
        "%" => (8, '%'),
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
        if (t == "fp8s" || t == "fp8d") && self.peek() == Some("(") {
            self.pos += 1;
            let e = self.expr(0)?;
            if self.peek() != Some(")") {
                return Err("missing `)`".into());
            }
            self.pos += 1;
            return Ok(Expr::Fp8(if t == "fp8s" { 32 } else { 64 }, Box::new(e)));
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
                '=' => (a == b) as i64,
                '!' => (a != b) as i64,
                'l' => (a < b) as i64,
                'L' => (a <= b) as i64,
                'g' => (a > b) as i64,
                'G' => (a >= b) as i64,
                _ => return None,
            }
        }
        Expr::Bitmask(w, a) => encode_bitmask(eval(a, env)? as u64, *w)? as i64,
        Expr::Fp8(w, a) => encode_fp8(eval(a, env)? as u64, *w)? as i64,
        Expr::Log2(a) => {
            let v = eval(a, env)?;
            if v <= 0 || v & (v - 1) != 0 {
                return None;
            }
            v.trailing_zeros() as i64
        }
    })
}

/// If `e` is a slice of `name`'s bits (`name`, `name>>k`, `(name>>k)&m`
/// or `name&m`), where its lowest bit is: `k`.
fn slice_of(e: &Expr, name: &str) -> Option<(i64, i64)> {
    let shifted = |e: &Expr| match e {
        Expr::Var(v) if v == name => Some(0),
        Expr::Bin('>', a, k) if matches!(&**a, Expr::Var(v) if v == name) => match **k {
            Expr::Int(k) => Some(k),
            _ => None,
        },
        _ => None,
    };
    let masked = |e: &Expr| match e {
        Expr::Bin('&', a, m) if matches!(**m, Expr::Int(m) if (m + 1).count_ones() == 1) => shifted(a),
        _ => shifted(e),
    };
    // A slice with its bits flipped, `(x>>3)^1` (VEX's inverted register
    // bits).
    match e {
        Expr::Bin('^', a, k) => match **k {
            Expr::Int(k) => Some((masked(a)?, k)),
            _ => None,
        },
        _ => Some((masked(e)?, 0)),
    }
}

/// Solves `e == target` for the one name in `e`, when `e` is made of
/// steps that can be undone. Returns the name and its value.
pub fn invert(e: &Expr, target: i64) -> Option<(String, i64)> {
    match e {
        Expr::Var(v) => Some((v.clone(), target)),
        Expr::Neg(a) => invert(a, target.wrapping_neg()),
        Expr::Bitmask(w, a) => invert(a, decode_bitmask(target as u64, *w)? as i64),
        Expr::Fp8(w, a) => invert(a, decode_fp8(u8::try_from(target).ok()?, *w) as i64),
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

/// `e` with the names `env` knows put in as numbers.
fn substitute(e: &Expr, env: &Env) -> Expr {
    match e {
        Expr::Var(v) => env.get(v).map_or_else(|| e.clone(), |&k| Expr::Int(k)),
        Expr::Int(_) => e.clone(),
        Expr::Neg(a) => Expr::Neg(Box::new(substitute(a, env))),
        Expr::Bitmask(w, a) => Expr::Bitmask(*w, Box::new(substitute(a, env))),
        Expr::Log2(a) => Expr::Log2(Box::new(substitute(a, env))),
        Expr::Fp8(w, a) => Expr::Fp8(*w, Box::new(substitute(a, env))),
        Expr::Bin(op, a, b) => Expr::Bin(*op, Box::new(substitute(a, env)), Box::new(substitute(b, env))),
    }
}

pub fn names_in(e: &Expr, out: &mut Vec<String>) {
    match e {
        Expr::Var(v) => {
            if !out.contains(v) {
                out.push(v.clone());
            }
        }
        Expr::Int(_) => {}
        Expr::Neg(a) | Expr::Bitmask(_, a) | Expr::Log2(a) | Expr::Fp8(_, a) => names_in(a, out),
        Expr::Bin(_, a, b) => {
            names_in(a, out);
            names_in(b, out);
        }
    }
}

fn holds(v: i64, f: &Field) -> bool {
    if f.width >= 64 {
        true
    } else if f.signed {
        let half = 1i64 << (f.width.max(1) - 1);
        (-half..half).contains(&v)
    } else {
        v >= 0 && (f.width >= 63 || v < (1i64 << f.width))
    }
}

impl Alt {
    /// The bytes for these operand values, or `None` if a guard fails or a
    /// field cannot hold its value.
    pub fn encode(&self, env: &Env) -> Option<Vec<u8>> {
        for g in &self.guards {
            if eval(g, env)? == 0 {
                return None;
            }
        }
        let mut words: Vec<u64> = self.pieces.iter().map(|p| p.value).collect();
        for f in &self.fields {
            let v = eval(&f.expr, env)?;
            if !holds(v, f) {
                return None;
            }
            if f.width > 0 {
                let m = if f.width >= 64 { u64::MAX } else { (1u64 << f.width) - 1 };
                words[f.piece] |= ((v as u64) & m) << f.lo;
            }
        }
        let mut out = Vec::with_capacity(self.len as usize);
        for (p, w) in self.pieces.iter().zip(words) {
            out.extend_from_slice(&w.to_le_bytes()[..p.bytes as usize]);
        }
        Some(out)
    }

    /// The pieces' words in `bytes`, if they hold this alternative's
    /// literal bits.
    fn words(&self, bytes: &[u8]) -> Option<Vec<u64>> {
        if bytes.len() < self.len as usize {
            return None;
        }
        let mut out = Vec::with_capacity(self.pieces.len());
        for p in &self.pieces {
            let w = word(&bytes[p.offset as usize..(p.offset + p.bytes) as usize]);
            if w & p.mask != p.value {
                return None;
            }
            out.push(w);
        }
        Some(out)
    }

    /// The raw value of field `f`, sign-extended if signed.
    fn field_value(f: &Field, words: &[u64]) -> i64 {
        if f.width == 0 {
            return 0;
        }
        let m = if f.width >= 64 { u64::MAX } else { (1u64 << f.width) - 1 };
        let raw = ((words[f.piece] >> f.lo) & m) as i64;
        if f.signed && f.width < 64 && raw >= 1 << (f.width - 1) { raw - (1 << f.width) } else { raw }
    }

    /// Whether some field holds operand `name`.
    pub fn mentions(&self, name: &str) -> bool {
        self.fields.iter().any(|f| f.names.iter().any(|n| n == name))
    }

    /// Zeroes the fields that hold operand `name` in `bytes` (this
    /// alternative's encoding): a relocation's field, which the
    /// relocation's addend fills in.
    pub fn clear(&self, bytes: &mut [u8], name: &str) {
        for f in self.fields.iter().filter(|f| f.names.iter().any(|n| n == name) && f.width > 0) {
            let p = &self.pieces[f.piece];
            let at = p.offset as usize..(p.offset + p.bytes) as usize;
            let m = if f.width >= 64 { u64::MAX } else { ((1u64 << f.width) - 1) << f.lo };
            let w = word(&bytes[at.clone()]) & !m;
            bytes[at].copy_from_slice(&w.to_le_bytes()[..p.bytes as usize]);
        }
    }

    /// Recovers `operands` from `bytes`, or `None` if they are not this
    /// alternative. Operands in `free` (symbols, whose fields hold zero
    /// until linking) are taken to be zero.
    pub fn decode(&self, bytes: &[u8], operands: &[String], free: &[String]) -> Option<Env> {
        let words = self.words(bytes)?;
        let mut env = Env::new();
        for n in free {
            env.insert(n.clone(), 0);
        }
        // Fields reading a free operand, with it put in as zero.
        let fields: Vec<Field> = if free.iter().any(|n| self.mentions(n)) {
            self.fields
                .iter()
                .map(|f| {
                    let mut f = f.clone();
                    if f.names.iter().any(|n| free.contains(n)) {
                        f.expr = substitute(&f.expr, &env);
                        f.names.retain(|n| !free.contains(n));
                        f.plain = !format!("{}", f.expr).contains(['%', '&']);
                    }
                    f
                })
                .collect()
        } else {
            self.fields.clone()
        };
        let mut unsolved: Vec<&String> = Vec::new();
        for name in operands {
            if free.contains(name) {
                continue;
            }
            // An operand in several fields that are each a slice of its
            // bits (`x>>12`, `(x>>5)&63`, `x&31`): the slices put back. A
            // signed slice (the top one) gives the sign.
            let holding: Vec<&Field> =
                fields.iter().filter(|f| f.names.as_slice() == std::slice::from_ref(name)).collect();
            // (Fields holding the same bits, as `rs1` and `rs2` both `n` do
            // in `fmv.d`, are copies, not slices.)
            let disjoint = |slices: &[(i64, i64)]| {
                let mut ranges: Vec<(i64, i64)> =
                    holding.iter().zip(slices).map(|(f, &(k, _))| (k, k + f.width as i64)).collect();
                ranges.sort();
                ranges.windows(2).all(|w| w[0].1 <= w[1].0)
            };
            if holding.len() > 1
                && let Some(slices) =
                    holding.iter().map(|f| slice_of(&f.expr, name)).collect::<Option<Vec<(i64, i64)>>>()
                && disjoint(&slices)
            {
                let v = holding.iter().zip(&slices).fold(0i64, |acc, (f, &(k, flip))| {
                    acc.wrapping_add((Self::field_value(f, &words) ^ flip).wrapping_shl(k as u32))
                });
                env.insert(name.clone(), v);
                continue;
            }
            // Each field that is just the operand gives a value (those
            // that are the operand itself first); the first that every
            // such field agrees with is it. (A register's number is split
            // over `r>>3` and `r&7`; a memory operand's index of 4, none,
            // is in `x>>3` and a zero-width `x-4`.)
            let low_bits = |mut v: i64| {
                // A value split over fields, `name>>k` and `name&m`
                // (adrp's immhi and immlo), or `name/k` and `name%k`: the
                // low bits go back on.
                for f in &fields {
                    let Expr::Bin(op @ ('%' | '&'), a, k) = &f.expr else { continue };
                    if **a != Expr::Var(name.clone()) {
                        continue;
                    }
                    match (op, &**k) {
                        ('%', Expr::Int(k)) if *k > 0 => v = v - v.rem_euclid(*k) + Self::field_value(f, &words),
                        ('&', Expr::Int(m)) if (*m + 1).count_ones() == 1 => {
                            v = (v & !*m) | Self::field_value(f, &words)
                        }
                        _ => {}
                    }
                }
                v
            };
            let agrees = |v: i64| {
                let one: Env = [(name.clone(), v)].into_iter().collect();
                holding.iter().all(|f| {
                    eval(&f.expr, &one).is_some_and(|x| {
                        let m = if f.width >= 64 { -1 } else { (1i64 << f.width) - 1 };
                        holds(x, f) && x & m == Self::field_value(f, &words) & m
                    })
                })
            };
            let mut first = None;
            let mut best = None;
            for f in holding.iter().filter(|f| f.plain).chain(holding.iter().filter(|f| !f.plain)) {
                let Some((_, v)) = invert(&f.expr, Self::field_value(f, &words)) else { continue };
                let v = low_bits(v);
                first.get_or_insert(v);
                if agrees(v) {
                    best = Some(v);
                    break;
                }
            }
            let Some(v) = best.or(first) else {
                unsolved.push(name);
                continue;
            };
            env.insert(name.clone(), v);
        }
        // Operands only in fields with others (sbfx's width, in `imms =
        // lsb + width - 1`): solved once the others are known.
        while !unsolved.is_empty() {
            let before = unsolved.len();
            unsolved.retain(|name| {
                let solved = fields.iter().find_map(|f| {
                    if !f.names.contains(name) || !f.names.iter().all(|n| n == *name || env.contains_key(n)) {
                        return None;
                    }
                    let (n, v) = invert(&substitute(&f.expr, &env), Self::field_value(f, &words))?;
                    (n == **name).then_some(v)
                });
                match solved {
                    Some(v) => {
                        env.insert((*name).clone(), v);
                        false
                    }
                    None => true,
                }
            });
            if unsolved.len() == before {
                return None;
            }
        }
        (self.encode(&env)?.as_slice() == &bytes[..self.len as usize]).then_some(env)
    }
}

impl Encoding {
    /// Whether it has no encoding at all (a recipe or a description-only
    /// entry).
    pub fn is_empty(&self) -> bool {
        self.alts.iter().all(|a| a.pieces.iter().all(|p| p.mask == 0))
    }

    /// The most literal bits any alternative fixes: how specific it is.
    pub fn fixed_bits(&self) -> u32 {
        self.alts.iter().map(|a| a.pieces.iter().map(|p| p.mask.count_ones()).sum()).max().unwrap_or(0)
    }

    /// The fields of every alternative.
    pub fn fields(&self) -> impl Iterator<Item = &Field> {
        self.alts.iter().flat_map(|a| a.fields.iter())
    }

    /// Whether some field holds operand `name`.
    pub fn mentions(&self, name: &str) -> bool {
        self.alts.iter().any(|a| a.mentions(name))
    }

    /// The bytes for these operand values, and which alternative they are,
    /// or `None` if no alternative holds them. With several alternatives,
    /// the one chosen must also decode back to the same operands (other
    /// than `free` ones).
    pub fn encode_alt(&self, env: &Env, free: &[String]) -> Option<(Vec<u8>, usize)> {
        if let [only] = &self.alts[..] {
            return only.encode(env).map(|b| (b, 0));
        }
        for (k, a) in self.alts.iter().enumerate() {
            let Some(bytes) = a.encode(env) else { continue };
            let names: Vec<String> = a.names.iter().filter(|n| env.contains_key(*n)).cloned().collect();
            let Some(back) = a.decode(&bytes, &names, free) else { continue };
            if names.iter().all(|n| free.contains(n) || back.get(n) == env.get(n)) {
                return Some((bytes, k));
            }
        }
        None
    }

    /// The bytes for these operand values, or `None` if no alternative
    /// holds them.
    pub fn encode(&self, env: &Env) -> Option<Vec<u8>> {
        self.encode_alt(env, &[]).map(|(b, _)| b)
    }

    /// Recovers `operands` from the start of `bytes`, and how many bytes
    /// the instruction takes, or `None` if they are not this encoding.
    pub fn decode(&self, bytes: &[u8], operands: &[String], free: &[String]) -> Option<(Env, usize)> {
        self.alts.iter().find_map(|a| a.decode(bytes, operands, free).map(|e| (e, a.len as usize)))
    }

    /// Does this value of operand `name` fit, with the other operands as
    /// in `env`? Fits means it survives an encode and decode unchanged.
    pub fn fits(&self, env: &Env, operands: &[String]) -> bool {
        match self.encode(env) {
            Some(bytes) => self
                .decode(&bytes, operands, &[])
                .is_some_and(|(back, _)| operands.iter().all(|o| back.get(o) == env.get(o))),
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
/// A float's (`width` 32) or double's (64) bits as `fmov`'s 8-bit
/// immediate `a:b:cd:efgh`, which stands for the value with sign `a`, an
/// exponent of `NOT(b)`, `b` repeated, then `cd`, and a fraction of `efgh`
/// then zeros: (16 + efgh) / 16 times a power of two from 2^-3 to 2^4.
pub fn encode_fp8(bits: u64, width: u32) -> Option<u8> {
    let (e, f) = if width == 32 { (8, 23) } else { (11, 52) };
    if width == 32 && bits >> 32 != 0 {
        return None;
    }
    let sign = (bits >> (e + f)) & 1;
    let exp = (bits >> f) & ((1 << e) - 1);
    let frac = bits & ((1u64 << f) - 1);
    if frac & ((1u64 << (f - 4)) - 1) != 0 {
        return None;
    }
    // The exponent's top bit and the e-3 below it: !b then b repeated.
    let top = exp >> 2;
    let b = match top {
        t if t == 1 << (e - 3) => 0,
        t if t == (1 << (e - 3)) - 1 => 1,
        _ => return None,
    };
    Some(((sign << 7) | (b << 6) | ((exp & 3) << 4) | (frac >> (f - 4))) as u8)
}

/// The bits an 8-bit `fmov` immediate stands for (see `encode_fp8`).
pub fn decode_fp8(imm: u8, width: u32) -> u64 {
    let (e, f) = if width == 32 { (8u64, 23u64) } else { (11, 52) };
    let imm = imm as u64;
    let b = (imm >> 6) & 1;
    let top = if b == 0 { 1 << (e - 3) } else { (1 << (e - 3)) - 1 };
    let exp = (top << 2) | ((imm >> 4) & 3);
    ((imm >> 7) << (e + f)) | (exp << f) | ((imm & 0xf) << (f - 4))
}

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

    fn w32(b: Option<Vec<u8>>) -> Option<u32> {
        b.map(|b| word(&b) as u32)
    }

    fn le(w: u32) -> Vec<u8> {
        w.to_le_bytes().to_vec()
    }

    #[test]
    fn add_immediate() {
        // add w0, w1, #5
        let e = parse("0 0 0 100010 0 imm:12 n:5 d:5").unwrap();
        let w = w32(e.encode(&env(&[("imm", 5), ("n", 1), ("d", 0)]))).unwrap();
        assert_eq!(w, 0x11001420);
        let ops: Vec<String> = ["d", "n", "imm"].iter().map(|s| s.to_string()).collect();
        assert_eq!(e.decode(&le(w), &ops, &[]).unwrap().0["imm"], 5);
        assert!(!e.fits(&env(&[("imm", 4096), ("n", 1), ("d", 0)]), &ops));
    }

    #[test]
    fn scaled_and_signed_fields() {
        let e = parse("11 111 0 01 01 imm12:12=off/8 n:5 d:5").unwrap();
        let ops: Vec<String> = ["d", "n", "off"].iter().map(|s| s.to_string()).collect();
        assert!(e.fits(&env(&[("off", 16), ("n", 4), ("d", 3)]), &ops));
        assert!(!e.fits(&env(&[("off", 12), ("n", 4), ("d", 3)]), &ops));
        // ldr x3, [x4, #16]
        assert_eq!(w32(e.encode(&env(&[("off", 16), ("n", 4), ("d", 3)]))), Some(0xf9400883));
        let b = parse("01010100 imm19:s19=dest/4 0 c:4").unwrap();
        let ops: Vec<String> = ["dest", "c"].iter().map(|s| s.to_string()).collect();
        let w = b.encode(&env(&[("dest", -8), ("c", 11)])).unwrap();
        assert_eq!(b.decode(&w, &ops, &[]).unwrap().0["dest"], -8);
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

    /// An operand split over four fields, as RISC-V's branch offsets are.
    #[test]
    fn slices_are_put_back() {
        let e = parse("b12:s1=dest>>12 b10:6=(dest>>5)&63 m:5 n:5 100 b4:4=(dest>>1)&15 b11:1=(dest>>11)&1 1100011")
            .unwrap();
        let names = vec!["dest".to_string(), "m".to_string(), "n".to_string()];
        for dest in [0i64, 2, 8, 2046, 2048, 4094, -2, -4096, -1234] {
            let env: Env = [("dest".into(), dest), ("m".into(), 11), ("n".into(), 10)].into_iter().collect();
            let w = e.encode(&env).unwrap();
            assert_eq!(e.decode(&w, &names, &[]).unwrap().0["dest"], dest, "{dest}");
        }
        // blt a0, a1, +8 is 0x00b54463.
        let env: Env = [("dest".into(), 8), ("m".into(), 11), ("n".into(), 10)].into_iter().collect();
        assert_eq!(w32(e.encode(&env)), Some(0x00b54463));
    }

    fn hex(b: &[u8]) -> String {
        b.iter().map(|x| format!("{x:02x}")).collect::<Vec<_>>().join(" ")
    }

    /// x86's REX, ModRM, SIB and displacements, as fragments: what
    /// `llvm-mc` gives for each.
    fn x86() -> Fragments {
        let mut f = Fragments::new();
        let mut def = |name: &str, params: &str, body: &str| {
            f.insert(name.into(), (params.split_whitespace().map(String::from).collect(), body.into()));
        };
        def("rex", "w r x b", "{ if(w==0) ; 0100 W:1=w R:1=r>>3 X:1=x>>3 B:1=b>>3 }");
        // A memory operand's: RIP-relative has no base or index bits.
        def("rexm", "w r m", "{ if(m.base==16) rex(w, r, 0, 0) ; rex(w, r, m.index, m.base) }");
        def("rr", "r b", "11 reg:3=r&7 rm:3=b&7");
        def(
            "rm",
            "r m",
            "{ rip:0=m.base-16 i:0=m.index-4 s:0=m.scale-1 00 reg:3=r&7 101 | disp:s32=m.sym+m.disp-end ;
               if((m.base&7)!=4) if((m.base&7)!=5) i:0=m.index-4 s:0=m.scale-1 z:0=m.disp 00 reg:3=r&7 rm:3=m.base&7 ;
               if((m.base&7)!=4) i:0=m.index-4 s:0=m.scale-1 01 reg:3=r&7 rm:3=m.base&7 | disp:s8=m.disp ;
               if((m.base&7)!=4) i:0=m.index-4 s:0=m.scale-1 10 reg:3=r&7 rm:3=m.base&7 | disp:s32=m.disp ;
               if((m.base&7)!=5) z:0=m.disp 00 reg:3=r&7 100 | ss:2=log2(m.scale) idx:3=m.index&7 base:3=m.base&7 ;
               01 reg:3=r&7 100 | ss:2=log2(m.scale) idx:3=m.index&7 base:3=m.base&7 | disp:s8=m.disp ;
               10 reg:3=r&7 100 | ss:2=log2(m.scale) idx:3=m.index&7 base:3=m.base&7 | disp:s32=m.disp }",
        );
        f
    }

    #[test]
    fn x86_register_forms() {
        let f = x86();
        // addq %b, %d: REX.W + 01 /r
        let add = parse_with("rex(1, b, 0, d) | 00000001 | rr(b, d)", &f).unwrap();
        assert_eq!(hex(&add.encode(&env(&[("b", 6), ("d", 7)])).unwrap()), "48 01 f7");
        assert_eq!(hex(&add.encode(&env(&[("b", 9), ("d", 8)])).unwrap()), "4d 01 c8");
        let ops: Vec<String> = ["d", "b"].iter().map(|s| s.to_string()).collect();
        let (back, len) = add.decode(&[0x4d, 0x01, 0xc8, 0x90], &ops, &[]).unwrap();
        assert_eq!((back["b"], back["d"], len), (9, 8, 3));
        // addl %b, %d: no REX unless a register needs it.
        let addl = parse_with("rex(0, b, 0, d) | 00000001 | rr(b, d)", &f).unwrap();
        assert_eq!(hex(&addl.encode(&env(&[("b", 6), ("d", 7)])).unwrap()), "01 f7");
        assert_eq!(hex(&addl.encode(&env(&[("b", 9), ("d", 7)])).unwrap()), "44 01 cf");
        // addq $c, %d: 83 /0 ib, or 81 /0 id.
        let addi =
            parse_with("rex(1, 0, 0, d) | { 10000011 | rr(0, d) | ib:s8=c ; 10000001 | rr(0, d) | id:s32=c }", &f)
                .unwrap();
        assert_eq!(hex(&addi.encode(&env(&[("c", 5), ("d", 0)])).unwrap()), "48 83 c0 05");
        assert_eq!(hex(&addi.encode(&env(&[("c", 1000), ("d", 3)])).unwrap()), "48 81 c3 e8 03 00 00");
        // movabsq: REX.W + B8 +ro io.
        let movabs = parse_with("rex(1, 0, 0, d) | 10111 o:3=d&7 | io:64=c", &f).unwrap();
        assert_eq!(
            hex(&movabs.encode(&env(&[("c", 0x1122334455667788), ("d", 0)])).unwrap()),
            "48 b8 88 77 66 55 44 33 22 11"
        );
    }

    #[test]
    fn x86_memory_forms() {
        let f = x86();
        // addq m, %d: REX.W + 03 /r
        let add = parse_with("rexm(1, d, m) | 00000011 | rm(d, m)", &f).unwrap();
        let mem = |d: i64, base: i64, index: i64, scale: i64, disp: i64| {
            env(&[("d", d), ("m.base", base), ("m.index", index), ("m.scale", scale), ("m.disp", disp), ("m.sym", 0)])
        };
        let free = vec!["m.sym".to_string()];
        let enc = |e: &Env| hex(&add.encode_alt(e, &free).unwrap().0);
        assert_eq!(enc(&mem(0, 7, 6, 8, 0)), "48 03 04 f7"); // (%rdi,%rsi,8)
        assert_eq!(enc(&mem(0, 7, 4, 1, 16)), "48 03 47 10"); // 16(%rdi)
        assert_eq!(enc(&mem(0, 7, 4, 1, 0)), "48 03 07"); // (%rdi)
        assert_eq!(enc(&mem(0, 5, 4, 1, 0)), "48 03 45 00"); // (%rbp): a displacement
        assert_eq!(enc(&mem(0, 4, 4, 1, 0)), "48 03 04 24"); // (%rsp): a SIB byte
        assert_eq!(enc(&mem(0, 12, 4, 1, 0)), "49 03 04 24"); // (%r12)
        assert_eq!(enc(&mem(0, 13, 4, 1, 0)), "49 03 45 00"); // (%r13)
        assert_eq!(enc(&mem(9, 7, 4, 1, 1000)), "4c 03 8f e8 03 00 00"); // 1000(%rdi), %r9
        assert_eq!(enc(&mem(0, 7, 12, 2, -8)), "4a 03 44 67 f8"); // -8(%rdi,%r12,2)
        assert_eq!(enc(&mem(0, 16, 4, 1, 0)), "48 03 05 f9 ff ff ff"); // 0(%rip): -7 from the end
        // Decoding gives the operands back, the index 4 (none) included.
        let ops: Vec<String> =
            ["d", "m.base", "m.index", "m.scale", "m.disp", "m.sym"].iter().map(|s| s.to_string()).collect();
        for e in
            [mem(0, 7, 6, 8, 0), mem(0, 5, 4, 1, 0), mem(0, 4, 4, 1, 0), mem(9, 13, 12, 4, -300), mem(3, 16, 4, 1, 64)]
        {
            let bytes = add.encode_alt(&e, &free).unwrap().0;
            let (back, len) = add.decode(&bytes, &ops, &free).unwrap();
            assert_eq!(len, bytes.len());
            for n in ["d", "m.base", "m.index", "m.scale", "m.disp"] {
                assert_eq!(back[n], e[n], "{n} of {}", hex(&bytes));
            }
        }
    }
}
