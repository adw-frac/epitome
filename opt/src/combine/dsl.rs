//! The rule language for combines.
//!
//! One rule per line:
//!
//! ```text
//! name: pattern -> replacement [if condition]
//! ```
//!
//! A **pattern** is an operation applied to sub-patterns, such as
//! `add(sub(x, C1), C2)`. Its leaves are:
//!
//! - a variable in lower case (`x`, `y`), which matches any value; a
//!   variable used twice must match the same value both times;
//! - a constant variable starting with `C` (`C`, `C1`, `Cmask`), which
//!   matches an integer constant, scalar or splat;
//! - a literal: an integer (`0`, `1`, `-1`), `true`, `false`, `poison`, or
//!   one of the floats `0.0`, `-0.0`, `1.0`. Integers are compared at the
//!   constant's own width, so `-1` means all ones.
//!
//! Operations are named as in IR text: `add`, `shl`, `zext`, `select`,
//! `fneg`, `freeze`, and `icmp.eq`, `icmp.ult` and so on for comparisons.
//!
//! A **replacement** has the same shape, except that a leaf may also be a
//! constant expression over the pattern's constants: `C1 + C2`, `-C`,
//! `~C`, `C - 1`, `log2(C)`, `bw - C`. Expressions are computed exactly
//! and then truncated to the width of the place they are used. A cast in a
//! replacement converts to the type of the instruction being replaced.
//!
//! A **condition** is one or more tests joined by `&&`: comparisons of
//! expressions (`C1 + C2 < bw`, unsigned), `pow2(C)`, `sametype(x, @)`, and
//! `oneuse`: every operation the pattern looks through has no other use.
//! `@` is the instruction being replaced, `bw` is its integer width (for
//! a comparison, the width of what it compares), and `bw(x)` is the width
//! of `x`.
//!
//! `#` starts a comment.

use std::fmt;

use draconian_ir::module::{BinOp, CastOp, ICmpPred};

/// An operation that patterns can name.
#[derive(Clone, Copy, PartialEq, Eq, Hash, Debug)]
pub enum Head {
    Bin(BinOp),
    ICmp(ICmpPred),
    Select,
    Cast(CastOp),
    FNeg,
    Freeze,
    /// `br label`: one block operand.
    Br,
    /// `br i1 cond, label, label`: a condition and two blocks.
    CondBr,
}

impl Head {
    pub fn arity(self) -> usize {
        match self {
            Head::Bin(_) | Head::ICmp(_) => 2,
            Head::Select | Head::CondBr => 3,
            Head::Cast(_) | Head::FNeg | Head::Freeze | Head::Br => 1,
        }
    }

    /// Terminators: rules rooted at them change control flow.
    pub fn is_terminator(self) -> bool {
        matches!(self, Head::Br | Head::CondBr)
    }

    /// True if operand `k` is a block.
    pub fn is_block_operand(self, k: usize) -> bool {
        match self {
            Head::Br => true,
            Head::CondBr => k > 0,
            _ => false,
        }
    }

    /// Operations whose two operands can be swapped.
    pub fn is_commutative(self) -> bool {
        match self {
            Head::Bin(op) => {
                matches!(op, BinOp::Add | BinOp::Mul | BinOp::And | BinOp::Or | BinOp::Xor | BinOp::FAdd | BinOp::FMul)
            }
            Head::ICmp(p) => matches!(p, ICmpPred::Eq | ICmpPred::Ne),
            _ => false,
        }
    }

    fn parse(name: &str) -> Option<Head> {
        if let Some(pred) = name.strip_prefix("icmp.") {
            return ICmpPred::ALL.iter().find(|(n, _)| *n == pred).map(|(_, p)| Head::ICmp(*p));
        }
        if let Some((_, op)) = BinOp::ALL.iter().find(|(n, _)| *n == name) {
            return Some(Head::Bin(*op));
        }
        if let Some((_, op)) = CastOp::ALL.iter().find(|(n, _)| *n == name) {
            return Some(Head::Cast(*op));
        }
        match name {
            "select" => Some(Head::Select),
            "fneg" => Some(Head::FNeg),
            "freeze" => Some(Head::Freeze),
            "br" => Some(Head::Br),
            "condbr" => Some(Head::CondBr),
            _ => None,
        }
    }
}

impl fmt::Display for Head {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Head::Bin(op) => f.write_str(op.keyword()),
            Head::ICmp(p) => write!(f, "icmp.{}", p.keyword()),
            Head::Select => f.write_str("select"),
            Head::Cast(op) => f.write_str(op.keyword()),
            Head::FNeg => f.write_str("fneg"),
            Head::Freeze => f.write_str("freeze"),
            Head::Br => f.write_str("br"),
            Head::CondBr => f.write_str("condbr"),
        }
    }
}

#[derive(Clone, Copy, PartialEq, Eq, Hash, Debug)]
pub enum FloatLit {
    PosZero,
    NegZero,
    One,
}

#[derive(Clone, Copy, PartialEq, Eq, Hash, Debug)]
pub enum Lit {
    /// An integer, compared at the constant's width.
    Int(i64),
    Float(FloatLit),
    Poison,
}

#[derive(Clone, PartialEq, Eq, Debug)]
pub enum Pat {
    /// Any value; the index is into `Rule::vars`.
    Var(usize),
    /// Any integer constant.
    Const(usize),
    Lit(Lit),
    /// Any block, as `^a`. Only in block operands.
    Block(usize),
    Op(Head, Vec<Pat>),
}

#[derive(Clone, Copy, PartialEq, Eq, Debug)]
pub enum UnOp {
    Neg,
    Not,
}

#[derive(Clone, Copy, PartialEq, Eq, Debug)]
pub enum BinExprOp {
    Add,
    Sub,
    Mul,
    And,
    Or,
    Xor,
    Shl,
    Shr,
}

#[derive(Clone, PartialEq, Eq, Debug)]
pub enum Expr {
    /// A constant variable.
    Var(usize),
    Num(i64),
    /// The width of `@`.
    Bw,
    /// The width of a variable.
    BwOf(usize),
    Log2(Box<Expr>),
    Un(UnOp, Box<Expr>),
    Bin(BinExprOp, Box<Expr>, Box<Expr>),
}

#[derive(Clone, PartialEq, Eq, Debug)]
pub enum Repl {
    Var(usize),
    Block(usize),
    Lit(Lit),
    Const(Expr),
    Op(Head, Vec<Repl>),
}

#[derive(Clone, Copy, PartialEq, Eq, Debug)]
pub enum CmpOp {
    Eq,
    Ne,
    Lt,
    Le,
    Gt,
    Ge,
}

/// A variable, or `@` for the instruction being replaced.
#[derive(Clone, Copy, PartialEq, Eq, Debug)]
pub enum Subject {
    Var(usize),
    Root,
}

#[derive(Clone, PartialEq, Eq, Debug)]
pub enum Cond {
    Cmp(CmpOp, Expr, Expr),
    Pow2(Expr),
    SameType(Subject, Subject),
    /// Every operation the pattern looks through has no other use, so
    /// the rule does not keep an old value alive beside the new one.
    OneUse,
}

#[derive(Clone, Debug)]
pub struct Rule {
    pub name: String,
    pub line: usize,
    pub pat: Pat,
    pub repl: Repl,
    /// All must hold.
    pub conds: Vec<Cond>,
    /// Variable names, indexed by the numbers in `Pat`, `Repl` and `Expr`.
    pub vars: Vec<String>,
}

#[derive(Debug)]
pub struct ParseError {
    pub line: usize,
    pub message: String,
}

impl fmt::Display for ParseError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "line {}: {}", self.line, self.message)
    }
}

/// Parses a rules file.
pub fn parse_rules(text: &str) -> Result<Vec<Rule>, ParseError> {
    let mut rules = Vec::new();
    for (k, raw) in text.lines().enumerate() {
        let line = k + 1;
        let body = raw.split('#').next().unwrap().trim();
        if body.is_empty() {
            continue;
        }
        let rule = parse_rule(body, line).map_err(|message| ParseError { line, message })?;
        if rules.iter().any(|r: &Rule| r.name == rule.name) {
            return Err(ParseError { line, message: format!("rule name '{}' is used twice", rule.name) });
        }
        rules.push(rule);
    }
    Ok(rules)
}

fn parse_rule(text: &str, line: usize) -> Result<Rule, String> {
    let (name, rest) = text.split_once(':').ok_or("expected 'name: pattern -> replacement'")?;
    let name = name.trim();
    if name.is_empty() || !name.chars().all(|c| c.is_ascii_alphanumeric() || c == '_') {
        return Err(format!("bad rule name '{name}'"));
    }
    let tokens = tokenize(rest)?;
    let mut p = Parser { tokens, pos: 0, vars: Vec::new() };
    let pat = p.pattern(true)?;
    let Pat::Op(root, _) = &pat else {
        return Err("a pattern must start with an operation".into());
    };
    let root = *root;
    check_blocks_pat(&pat)?;
    p.expect("->")?;
    let pattern_vars = p.vars.len();
    let repl = p.replacement()?;
    check_blocks_repl(&repl)?;
    // A terminator becomes a terminator, and a value a value.
    let repl_is_terminator = matches!(&repl, Repl::Op(h, _) if h.is_terminator());
    if root.is_terminator() != repl_is_terminator {
        return Err(if root.is_terminator() {
            "a branch must be replaced by a branch".into()
        } else {
            "only a branch can be replaced by a branch".into()
        });
    }
    let mut conds = Vec::new();
    if p.eat("if") {
        conds.push(p.cond()?);
        while p.eat("&&") {
            conds.push(p.cond()?);
        }
    }
    if p.pos != p.tokens.len() {
        return Err(format!("unexpected '{}'", p.tokens[p.pos]));
    }
    if p.vars.len() != pattern_vars {
        return Err(format!("'{}' is not bound by the pattern", p.vars[pattern_vars]));
    }
    Ok(Rule { name: name.to_string(), line, pat, repl, conds, vars: p.vars })
}

/// Blocks may only appear as block operands, and block operands must be
/// blocks.
fn check_blocks_pat(p: &Pat) -> Result<(), String> {
    if let Pat::Op(h, args) = p {
        for (k, a) in args.iter().enumerate() {
            if h.is_block_operand(k) != matches!(a, Pat::Block(_)) {
                return Err(format!(
                    "operand {} of '{h}' must {}be a block (`^name`)",
                    k + 1,
                    if h.is_block_operand(k) { "" } else { "not " }
                ));
            }
            check_blocks_pat(a)?;
        }
    }
    Ok(())
}

fn check_blocks_repl(r: &Repl) -> Result<(), String> {
    if let Repl::Op(h, args) = r {
        for (k, a) in args.iter().enumerate() {
            if h.is_block_operand(k) != matches!(a, Repl::Block(_)) {
                return Err(format!(
                    "operand {} of '{h}' must {}be a block (`^name`)",
                    k + 1,
                    if h.is_block_operand(k) { "" } else { "not " }
                ));
            }
            check_blocks_repl(a)?;
        }
    }
    Ok(())
}

fn tokenize(text: &str) -> Result<Vec<String>, String> {
    let chars: Vec<char> = text.chars().collect();
    let mut out = Vec::new();
    let mut i = 0;
    while i < chars.len() {
        let c = chars[i];
        if c.is_whitespace() {
            i += 1;
            continue;
        }
        let two: String = chars[i..(i + 2).min(chars.len())].iter().collect();
        if ["->", "&&", "<=", ">=", "==", "!=", "<<", ">>"].contains(&two.as_str()) {
            out.push(two);
            i += 2;
            continue;
        }
        // `^name` is a block variable; `^` alone is xor in an expression.
        if c == '^' && chars.get(i + 1).is_some_and(|n| n.is_ascii_alphabetic()) {
            let start = i;
            i += 1;
            while i < chars.len() && (chars[i].is_ascii_alphanumeric() || chars[i] == '_') {
                i += 1;
            }
            out.push(chars[start..i].iter().collect());
            continue;
        }
        if c.is_ascii_alphanumeric() || c == '_' || c == '.' {
            let start = i;
            while i < chars.len() && (chars[i].is_ascii_alphanumeric() || chars[i] == '_' || chars[i] == '.') {
                i += 1;
            }
            out.push(chars[start..i].iter().collect());
            continue;
        }
        if "(),+-*&|^~<>@".contains(c) {
            out.push(c.to_string());
            i += 1;
            continue;
        }
        return Err(format!("unexpected character '{c}'"));
    }
    Ok(out)
}

struct Parser {
    tokens: Vec<String>,
    pos: usize,
    vars: Vec<String>,
}

fn is_var_name(s: &str) -> bool {
    s.starts_with(|c: char| c.is_ascii_lowercase())
        && !s.contains('.')
        && !matches!(s, "true" | "false" | "poison" | "bw" | "log2" | "pow2" | "sametype" | "if")
}

fn is_const_name(s: &str) -> bool {
    s.starts_with('C') && s.chars().all(|c| c.is_ascii_alphanumeric() || c == '_')
}

impl Parser {
    fn peek(&self) -> Option<&str> {
        self.tokens.get(self.pos).map(|s| s.as_str())
    }

    fn peek_at(&self, k: usize) -> Option<&str> {
        self.tokens.get(self.pos + k).map(|s| s.as_str())
    }

    fn next(&mut self) -> Result<String, String> {
        let t = self.tokens.get(self.pos).cloned().ok_or("unexpected end of rule")?;
        self.pos += 1;
        Ok(t)
    }

    fn eat(&mut self, t: &str) -> bool {
        if self.peek() == Some(t) {
            self.pos += 1;
            true
        } else {
            false
        }
    }

    fn expect(&mut self, t: &str) -> Result<(), String> {
        if self.eat(t) { Ok(()) } else { Err(format!("expected '{t}', found '{}'", self.peek().unwrap_or("end"))) }
    }

    /// The index of a variable, adding it in a pattern.
    fn var(&mut self, name: &str, binding: bool) -> Result<usize, String> {
        if let Some(i) = self.vars.iter().position(|v| v == name) {
            return Ok(i);
        }
        if !binding {
            return Err(format!("'{name}' is not bound by the pattern"));
        }
        self.vars.push(name.to_string());
        Ok(self.vars.len() - 1)
    }

    fn args<T>(&mut self, head: Head, mut item: impl FnMut(&mut Self) -> Result<T, String>) -> Result<Vec<T>, String> {
        self.expect("(")?;
        let mut args = vec![item(self)?];
        while self.eat(",") {
            args.push(item(self)?);
        }
        self.expect(")")?;
        if args.len() != head.arity() {
            return Err(format!("'{head}' takes {} operands, found {}", head.arity(), args.len()));
        }
        Ok(args)
    }

    fn literal(&mut self) -> Result<Option<Lit>, String> {
        let negative =
            self.peek() == Some("-") && self.peek_at(1).is_some_and(|t| t.starts_with(|c: char| c.is_ascii_digit()));
        let at = if negative { 1 } else { 0 };
        let Some(t) = self.peek_at(at).map(str::to_string) else { return Ok(None) };
        let lit = match t.as_str() {
            "true" => Lit::Int(1),
            "false" => Lit::Int(0),
            "poison" => Lit::Poison,
            t if t.contains('.') && t.starts_with(|c: char| c.is_ascii_digit()) => match (t, negative) {
                ("0.0", false) => Lit::Float(FloatLit::PosZero),
                ("0.0", true) => Lit::Float(FloatLit::NegZero),
                ("1.0", false) => Lit::Float(FloatLit::One),
                _ => return Err(format!("unsupported float literal '{}{t}'", if negative { "-" } else { "" })),
            },
            t if t.starts_with(|c: char| c.is_ascii_digit()) => {
                let v: i64 = t.parse().map_err(|_| format!("bad number '{t}'"))?;
                Lit::Int(if negative { -v } else { v })
            }
            _ => return Ok(None),
        };
        if negative && matches!(lit, Lit::Poison) {
            return Err("'-poison'".into());
        }
        self.pos += at + 1;
        Ok(Some(lit))
    }

    fn pattern(&mut self, top: bool) -> Result<Pat, String> {
        if let Some(lit) = self.literal()? {
            return Ok(Pat::Lit(lit));
        }
        let t = self.next()?;
        if let Some(head) = Head::parse(&t)
            && self.peek() == Some("(")
        {
            let args = self.args(head, |p| p.pattern(false))?;
            return Ok(Pat::Op(head, args));
        }
        let _ = top;
        if t.starts_with('^') {
            return Ok(Pat::Block(self.var(&t, true)?));
        }
        if is_const_name(&t) {
            return Ok(Pat::Const(self.var(&t, true)?));
        }
        if is_var_name(&t) {
            return Ok(Pat::Var(self.var(&t, true)?));
        }
        Err(format!("unexpected '{t}' in a pattern"))
    }

    fn replacement(&mut self) -> Result<Repl, String> {
        let t = self.peek().ok_or("expected a replacement")?.to_string();
        if t.starts_with('^') {
            self.pos += 1;
            return Ok(Repl::Block(self.var(&t, false)?));
        }
        if let Some(head) = Head::parse(&t)
            && self.peek_at(1) == Some("(")
        {
            self.pos += 1;
            let args = self.args(head, |p| p.replacement())?;
            return Ok(Repl::Op(head, args));
        }
        if is_var_name(&t) && !matches!(self.peek_at(1), Some("+" | "-" | "*" | "&" | "|" | "^" | "<<" | ">>")) {
            self.pos += 1;
            let v = self.var(&t, false)?;
            return Ok(Repl::Var(v));
        }
        let save = self.pos;
        if let Some(lit) = self.literal()? {
            // A bare literal, unless it starts an expression such as `1 + C`.
            let ends = matches!(self.peek(), None | Some(",") | Some(")") | Some("if"));
            if ends && !matches!(lit, Lit::Int(_)) {
                return Ok(Repl::Lit(lit));
            }
            self.pos = save;
        }
        Ok(Repl::Const(self.expr()?))
    }

    fn expr(&mut self) -> Result<Expr, String> {
        self.binary(0)
    }

    fn binary(&mut self, min_prec: u8) -> Result<Expr, String> {
        let mut lhs = self.unary()?;
        loop {
            let (op, prec) = match self.peek() {
                Some("|") => (BinExprOp::Or, 1),
                Some("^") => (BinExprOp::Xor, 2),
                Some("&") => (BinExprOp::And, 3),
                Some("<<") => (BinExprOp::Shl, 4),
                Some(">>") => (BinExprOp::Shr, 4),
                Some("+") => (BinExprOp::Add, 5),
                Some("-") => (BinExprOp::Sub, 5),
                Some("*") => (BinExprOp::Mul, 6),
                _ => return Ok(lhs),
            };
            if prec < min_prec {
                return Ok(lhs);
            }
            self.pos += 1;
            let rhs = self.binary(prec + 1)?;
            lhs = Expr::Bin(op, Box::new(lhs), Box::new(rhs));
        }
    }

    fn unary(&mut self) -> Result<Expr, String> {
        if self.eat("-") {
            return Ok(Expr::Un(UnOp::Neg, Box::new(self.unary()?)));
        }
        if self.eat("~") {
            return Ok(Expr::Un(UnOp::Not, Box::new(self.unary()?)));
        }
        let t = self.next()?;
        match t.as_str() {
            "(" => {
                let e = self.expr()?;
                self.expect(")")?;
                Ok(e)
            }
            "bw" if self.eat("(") => {
                let name = self.next()?;
                let v = self.var(&name, false)?;
                self.expect(")")?;
                Ok(Expr::BwOf(v))
            }
            "bw" => Ok(Expr::Bw),
            "log2" => {
                self.expect("(")?;
                let e = self.expr()?;
                self.expect(")")?;
                Ok(Expr::Log2(Box::new(e)))
            }
            "true" => Ok(Expr::Num(1)),
            "false" => Ok(Expr::Num(0)),
            t if t.starts_with(|c: char| c.is_ascii_digit()) => {
                t.parse().map(Expr::Num).map_err(|_| format!("bad number '{t}'"))
            }
            t if is_const_name(t) => Ok(Expr::Var(self.var(t, false)?)),
            t => Err(format!("unexpected '{t}' in an expression")),
        }
    }

    fn subject(&mut self) -> Result<Subject, String> {
        if self.eat("@") {
            return Ok(Subject::Root);
        }
        let t = self.next()?;
        Ok(Subject::Var(self.var(&t, false)?))
    }

    fn cond(&mut self) -> Result<Cond, String> {
        if self.eat("oneuse") {
            return Ok(Cond::OneUse);
        }
        if self.eat("pow2") {
            self.expect("(")?;
            let e = self.expr()?;
            self.expect(")")?;
            return Ok(Cond::Pow2(e));
        }
        if self.eat("sametype") {
            self.expect("(")?;
            let a = self.subject()?;
            self.expect(",")?;
            let b = self.subject()?;
            self.expect(")")?;
            return Ok(Cond::SameType(a, b));
        }
        let lhs = self.expr()?;
        let op = match self.next()?.as_str() {
            "==" => CmpOp::Eq,
            "!=" => CmpOp::Ne,
            "<" => CmpOp::Lt,
            "<=" => CmpOp::Le,
            ">" => CmpOp::Gt,
            ">=" => CmpOp::Ge,
            t => return Err(format!("expected a comparison, found '{t}'")),
        };
        let rhs = self.expr()?;
        Ok(Cond::Cmp(op, lhs, rhs))
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn parses_a_rule() {
        let rules = parse_rules("r: add(sub(x, C1), C2) -> add(x, C2 - C1) if C1 != 0 # note").unwrap();
        let r = &rules[0];
        assert_eq!(r.vars, vec!["x", "C1", "C2"]);
        assert_eq!(
            r.pat,
            Pat::Op(
                Head::Bin(BinOp::Add),
                vec![Pat::Op(Head::Bin(BinOp::Sub), vec![Pat::Var(0), Pat::Const(1)]), Pat::Const(2)]
            )
        );
        assert_eq!(
            r.repl,
            Repl::Op(
                Head::Bin(BinOp::Add),
                vec![
                    Repl::Var(0),
                    Repl::Const(Expr::Bin(BinExprOp::Sub, Box::new(Expr::Var(2)), Box::new(Expr::Var(1))))
                ]
            )
        );
        assert_eq!(r.conds.len(), 1);
    }

    #[test]
    fn parses_branch_rules() {
        let r = &parse_rules("b: condbr(xor(c, true), ^a, ^b) -> condbr(c, ^b, ^a)").unwrap()[0];
        assert_eq!(r.vars, vec!["c", "^a", "^b"]);
        assert_eq!(
            parse_rules("b: condbr(c, x, ^b) -> br(^b)").unwrap_err().to_string(),
            "line 1: operand 2 of 'condbr' must be a block (`^name`)"
        );
        assert_eq!(
            parse_rules("b: condbr(c, ^a, ^b) -> c").unwrap_err().to_string(),
            "line 1: a branch must be replaced by a branch"
        );
    }

    #[test]
    fn reports_errors_with_lines() {
        let e = parse_rules("\n\nr: add(x) -> x").unwrap_err();
        assert_eq!(e.to_string(), "line 3: 'add' takes 2 operands, found 1");
        let e = parse_rules("r: add(x, 0) -> y").unwrap_err();
        assert_eq!(e.to_string(), "line 1: 'y' is not bound by the pattern");
    }
}
