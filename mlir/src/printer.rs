//! Writes a module in the generic form, laid out as `mlir-opt
//! --mlir-print-op-generic` lays it out, so that what it prints reads back
//! the same.

use std::collections::HashMap;
use std::fmt::{self, Write};

use crate::ir::*;
use crate::lexer::is_bare_char;

impl fmt::Display for Module {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.write_str(&print_module(self))
    }
}

/// Prints a whole module.
pub fn print_module(m: &Module) -> String {
    let mut p = Printer { m, out: String::new(), names: number_values(m) };
    for item in &m.items {
        match item {
            Item::Op(op) => p.op(*op, 0),
            Item::TypeAlias { name, ty } => {
                write!(p.out, "!{name} = ").unwrap();
                p.ty(*ty);
            }
            Item::AttrAlias { name, attr } => {
                write!(p.out, "#{name} = ").unwrap();
                p.attr(*attr);
            }
            Item::Resources(text) => write!(p.out, "{{-#{text}#-}}").unwrap(),
            Item::Blob { key, align, bytes } => {
                write!(p.out, "{{-#\n  dialect_resources: {{\n    builtin: {{\n      {key}: \"0x").unwrap();
                for b in align.to_le_bytes().iter().chain(bytes.iter()) {
                    write!(p.out, "{b:02X}").unwrap();
                }
                p.out.push_str("\"\n    }\n  }\n#-}");
            }
        }
        p.out.push('\n');
    }
    p.out
}

/// A type as text.
pub fn type_text(m: &Module, ty: TypeId) -> String {
    let mut p = Printer { m, out: String::new(), names: HashMap::new() };
    p.ty(ty);
    p.out
}

/// An attribute as text.
pub fn attr_text(m: &Module, attr: AttrId) -> String {
    let mut p = Printer { m, out: String::new(), names: HashMap::new() };
    p.attr(attr);
    p.out
}

/// Whether `s` can be written without quotes: a bare identifier.
pub fn is_bare(s: &str) -> bool {
    let b = s.as_bytes();
    !b.is_empty() && (b[0].is_ascii_alphabetic() || b[0] == b'_') && b[1..].iter().all(|&c| is_bare_char(c))
}

/// Writes `bytes` as a string literal: printable characters as they are,
/// `"` and `\` escaped, anything else as `\` and two hex digits.
pub fn write_string(out: &mut String, bytes: &[u8]) {
    out.push('"');
    for &c in bytes {
        match c {
            b'"' => out.push_str("\\\""),
            b'\\' => out.push_str("\\\\"),
            0x20..=0x7e => out.push(c as char),
            _ => write!(out, "\\{c:02X}").unwrap(),
        }
    }
    out.push('"');
}

struct Printer<'m> {
    m: &'m Module,
    out: String,
    /// Names for values made without one, from `number_values`.
    names: HashMap<ValueId, String>,
}

/// Names for the values that have none, such as those a pass makes,
/// numbered as MLIR's printer numbers them: within each operation at the
/// top level or in a module's body (a function), entry blocks' arguments
/// are `%arg0`, `%arg1`, and other values `%0`, `%1` in the order they are
/// printed. A number another value already has as its name
/// is skipped.
fn number_values(m: &Module) -> HashMap<ValueId, String> {
    let mut names = HashMap::new();
    for item in &m.items {
        if let Item::Op(op) = item {
            number_scope(m, *op, &mut names);
        }
    }
    names
}

fn number_scope(m: &Module, op: OpId, names: &mut HashMap<ValueId, String>) {
    if m.op_name(op) == "builtin.module" {
        for &r in &m.ops[op.index()].regions {
            for &b in &m.regions[r.index()].blocks {
                for &o in &m.blocks[b.index()].ops {
                    number_scope(m, o, names);
                }
            }
        }
        return;
    }
    // The names already taken in this scope.
    let mut taken = std::collections::HashSet::new();
    let mut unnamed = Vec::new();
    let mut entry_args = Vec::new();
    let mut visit = |v: ValueId, entry: bool| match &m.values[v.index()].name {
        Some(n) => {
            taken.insert(n.clone());
        }
        None if entry => entry_args.push(v),
        None => unnamed.push(v),
    };
    for &v in &m.ops[op.index()].results {
        visit(v, false);
    }
    fn walk(m: &Module, op: OpId, visit: &mut dyn FnMut(ValueId, bool)) {
        for &r in &m.ops[op.index()].regions {
            for (i, &b) in m.regions[r.index()].blocks.iter().enumerate() {
                for &a in &m.blocks[b.index()].args {
                    // Every entry block's arguments are `%argN`, as MLIR names them.
                    visit(a, i == 0);
                }
                for &o in &m.blocks[b.index()].ops {
                    for &v in &m.ops[o.index()].results {
                        visit(v, false);
                    }
                    walk(m, o, visit);
                }
            }
        }
    }
    walk(m, op, &mut visit);
    let fresh = |prefix: &str, next: &mut usize| loop {
        let name = format!("{prefix}{next}");
        *next += 1;
        if !taken.contains(&name) {
            return name;
        }
    };
    let mut next = 0;
    for v in entry_args {
        names.insert(v, fresh("arg", &mut next));
    }
    let mut next = 0;
    for v in unnamed {
        names.insert(v, fresh("", &mut next));
    }
}

impl Printer<'_> {
    fn indent(&mut self, n: usize) {
        for _ in 0..n {
            self.out.push(' ');
        }
    }

    fn name(&mut self, s: &str) {
        if is_bare(s) {
            self.out.push_str(s);
        } else {
            write_string(&mut self.out, s.as_bytes());
        }
    }

    fn value(&mut self, v: ValueId) {
        let value = &self.m.values[v.index()];
        match (&value.name, self.names.get(&v)) {
            (Some(n), _) | (None, Some(n)) => write!(self.out, "%{n}").unwrap(),
            (None, None) => write!(self.out, "%_{}", v.0).unwrap(),
        }
        if let Some(i) = value.group_index {
            write!(self.out, "#{i}").unwrap();
        }
    }

    fn block_name(&mut self, b: BlockId) {
        match &self.m.blocks[b.index()].name {
            Some(n) => write!(self.out, "^{n}").unwrap(),
            // An entry block written without a label: `^bb` and its place
            // in the region, as MLIR numbers blocks.
            None => {
                let block = &self.m.blocks[b.index()];
                let i = self.m.regions[block.parent.index()].blocks.iter().position(|&x| x == b).unwrap_or(0);
                write!(self.out, "^bb{i}").unwrap()
            }
        }
    }

    /// The results before `=`: `%0`, or `%0:2` for a group.
    fn results(&mut self, results: &[ValueId]) {
        let mut i = 0;
        while i < results.len() {
            if i > 0 {
                self.out.push_str(", ");
            }
            let first = &self.m.values[results[i].index()];
            let mut count = 1;
            if first.group_index.is_some() {
                while i + count < results.len() {
                    let next = &self.m.values[results[i + count].index()];
                    if next.name != first.name || next.group_index != Some(count as u32) {
                        break;
                    }
                    count += 1;
                }
            }
            match (&first.name, self.names.get(&results[i])) {
                (Some(n), _) | (None, Some(n)) => write!(self.out, "%{n}").unwrap(),
                (None, None) => write!(self.out, "%_{}", results[i].0).unwrap(),
            }
            if first.group_index.is_some() {
                write!(self.out, ":{count}").unwrap();
            }
            i += count;
        }
        self.out.push_str(" = ");
    }

    fn op(&mut self, op: OpId, indent: usize) {
        let o = &self.m.ops[op.index()];
        self.indent(indent);
        if !o.results.is_empty() {
            self.results(&o.results);
        }
        write_string(&mut self.out, self.m.name(o.name).as_bytes());
        self.out.push('(');
        for (i, &v) in o.operands.iter().enumerate() {
            if i > 0 {
                self.out.push_str(", ");
            }
            self.value(v);
        }
        self.out.push(')');
        if !o.successors.is_empty() {
            self.out.push('[');
            for (i, &b) in o.successors.iter().enumerate() {
                if i > 0 {
                    self.out.push_str(", ");
                }
                self.block_name(b);
            }
            self.out.push(']');
        }
        if let Some(p) = o.properties {
            self.out.push_str(" <");
            self.attr(p);
            self.out.push('>');
        }
        if !o.regions.is_empty() {
            self.out.push_str(" (");
            for (i, &r) in o.regions.iter().enumerate() {
                if i > 0 {
                    self.out.push_str(", ");
                }
                self.region(r, indent);
            }
            self.out.push(')');
        }
        if let Some(a) = o.attrs {
            self.out.push(' ');
            self.attr(a);
        }
        self.out.push_str(" : ");
        self.ty(o.ty);
        if let Some(l) = o.loc {
            self.out.push(' ');
            self.attr(l);
        }
    }

    fn region(&mut self, r: RegionId, indent: usize) {
        self.out.push_str("{\n");
        for (i, &b) in self.m.regions[r.index()].blocks.iter().enumerate() {
            let block = &self.m.blocks[b.index()];
            // The entry block's label is left out unless it has arguments,
            // or nothing else would show the block is there.
            if i > 0 || !block.args.is_empty() || block.ops.is_empty() {
                self.indent(indent);
                self.block_name(b);
                if !block.args.is_empty() {
                    self.out.push('(');
                    for (j, &a) in block.args.iter().enumerate() {
                        if j > 0 {
                            self.out.push_str(", ");
                        }
                        self.value(a);
                        self.out.push_str(": ");
                        let arg = &self.m.values[a.index()];
                        self.ty(arg.ty);
                        if let Some(l) = arg.loc {
                            self.out.push(' ');
                            self.attr(l);
                        }
                    }
                    self.out.push(')');
                }
                self.out.push_str(":\n");
            }
            for &op in &block.ops {
                self.op(op, indent + 2);
                self.out.push('\n');
            }
        }
        self.indent(indent);
        self.out.push('}');
    }

    fn ty_list(&mut self, list: &[TypeId]) {
        for (i, &t) in list.iter().enumerate() {
            if i > 0 {
                self.out.push_str(", ");
            }
            self.ty(t);
        }
    }

    fn shape(&mut self, shape: &Option<Vec<Dim>>) {
        match shape {
            None => self.out.push_str("*x"),
            Some(dims) => {
                for d in dims {
                    match d {
                        Some(n) => write!(self.out, "{n}x").unwrap(),
                        None => self.out.push_str("?x"),
                    }
                }
            }
        }
    }

    fn ty(&mut self, ty: TypeId) {
        match self.m.ty(ty) {
            Type::Int { width, signedness } => {
                let prefix = match signedness {
                    Signedness::Signless => "i",
                    Signedness::Signed => "si",
                    Signedness::Unsigned => "ui",
                };
                write!(self.out, "{prefix}{width}").unwrap();
            }
            Type::Index => self.out.push_str("index"),
            Type::Float(name) => self.out.push_str(name),
            Type::None => self.out.push_str("none"),
            Type::Complex(elem) => {
                self.out.push_str("complex<");
                self.ty(*elem);
                self.out.push('>');
            }
            Type::Tuple(elems) => {
                self.out.push_str("tuple<");
                self.ty_list(elems);
                self.out.push('>');
            }
            Type::Vector { dims, elem } => {
                self.out.push_str("vector<");
                for &(n, scalable) in dims {
                    if scalable {
                        write!(self.out, "[{n}]x").unwrap();
                    } else {
                        write!(self.out, "{n}x").unwrap();
                    }
                }
                self.ty(*elem);
                self.out.push('>');
            }
            Type::Tensor { shape, elem, encoding } => {
                self.out.push_str("tensor<");
                self.shape(shape);
                self.ty(*elem);
                if let Some(e) = encoding {
                    self.out.push_str(", ");
                    self.attr(*e);
                }
                self.out.push('>');
            }
            Type::MemRef { shape, elem, extra } => {
                self.out.push_str("memref<");
                self.shape(shape);
                self.ty(*elem);
                for &a in extra {
                    self.out.push_str(", ");
                    self.attr(a);
                }
                self.out.push('>');
            }
            Type::Function { inputs, results } => {
                self.out.push('(');
                self.ty_list(inputs);
                self.out.push_str(") -> ");
                let single = results.len() == 1 && !matches!(self.m.ty(results[0]), Type::Function { .. });
                if single {
                    self.ty(results[0]);
                } else {
                    self.out.push('(');
                    self.ty_list(results);
                    self.out.push(')');
                }
            }
            Type::Opaque { dialect, data } => {
                self.out.push_str("opaque<");
                write_string(&mut self.out, dialect);
                self.out.push_str(", ");
                write_string(&mut self.out, data);
                self.out.push('>');
            }
            Type::Dialect { name, body } => {
                write!(self.out, "!{name}{}", body.as_deref().unwrap_or("")).unwrap();
            }
            Type::Alias(name) => write!(self.out, "!{name}").unwrap(),
        }
    }

    fn type_suffix(&mut self, ty: &Option<TypeId>) {
        if let Some(t) = ty {
            self.out.push_str(" : ");
            self.ty(*t);
        }
    }

    fn attr(&mut self, attr: AttrId) {
        match self.m.attr(attr) {
            Attr::Unit => self.out.push_str("unit"),
            Attr::Bool(b) => self.out.push_str(if *b { "true" } else { "false" }),
            Attr::Int { text, ty } | Attr::Float { text, ty } => {
                self.out.push_str(text);
                self.type_suffix(ty);
            }
            Attr::String { bytes, ty } => {
                write_string(&mut self.out, bytes);
                self.type_suffix(ty);
            }
            Attr::Type(t) => self.ty(*t),
            Attr::Array(elems) => {
                self.out.push('[');
                for (i, &a) in elems.iter().enumerate() {
                    if i > 0 {
                        self.out.push_str(", ");
                    }
                    self.attr(a);
                }
                self.out.push(']');
            }
            Attr::Dict(entries) => {
                self.out.push('{');
                for (i, (key, value)) in entries.iter().enumerate() {
                    if i > 0 {
                        self.out.push_str(", ");
                    }
                    self.name(key);
                    if *self.m.attr(*value) != Attr::Unit {
                        self.out.push_str(" = ");
                        self.attr(*value);
                    }
                }
                self.out.push('}');
            }
            Attr::SymbolRef(path) => {
                for (i, part) in path.iter().enumerate() {
                    if i > 0 {
                        self.out.push_str("::");
                    }
                    self.out.push('@');
                    self.name(part);
                }
            }
            Attr::Builtin { keyword, body, ty } => {
                write!(self.out, "{keyword}{body}").unwrap();
                self.type_suffix(ty);
            }
            Attr::Dialect { name, body } => {
                write!(self.out, "#{name}{}", body.as_deref().unwrap_or("")).unwrap();
            }
            Attr::Alias(name) => write!(self.out, "#{name}").unwrap(),
            Attr::Loc(_) => {
                self.out.push_str("loc(");
                self.loc(attr);
                self.out.push(')');
            }
        }
    }

    /// A location without its `loc(...)`.
    fn loc(&mut self, attr: AttrId) {
        let Attr::Loc(loc) = self.m.attr(attr) else {
            self.attr(attr);
            return;
        };
        match loc {
            Loc::Unknown => self.out.push_str("unknown"),
            Loc::File { file, line, col, end } => {
                write_string(&mut self.out, file);
                write!(self.out, ":{line}:{col}").unwrap();
                if let Some(end) = end {
                    write!(self.out, " to {end}").unwrap();
                }
            }
            Loc::Name { name, child } => {
                write_string(&mut self.out, name);
                if let Some(c) = child {
                    self.out.push('(');
                    self.loc(*c);
                    self.out.push(')');
                }
            }
            Loc::CallSite { callee, caller } => {
                self.out.push_str("callsite(");
                self.loc(*callee);
                self.out.push_str(" at ");
                self.loc(*caller);
                self.out.push(')');
            }
            Loc::Fused { metadata, locs } => {
                self.out.push_str("fused");
                if let Some(m) = metadata {
                    self.out.push('<');
                    self.attr(*m);
                    self.out.push('>');
                }
                self.out.push('[');
                for (i, &l) in locs.iter().enumerate() {
                    if i > 0 {
                        self.out.push_str(", ");
                    }
                    self.loc(l);
                }
                self.out.push(']');
            }
            Loc::Alias(name) => write!(self.out, "#{name}").unwrap(),
        }
    }
}

#[cfg(test)]
mod tests {
    use crate::parse_module;

    #[test]
    fn round_trip() {
        let src = r#"#loc = loc("f.py":3:7)
"builtin.module"() ({
  "func.func"() <{function_type = (i32) -> (i32, i1), sym_name = "f"}> ({
  ^bb0(%arg0: i32 loc("f.py":1:2)):
    %0:2 = "x.pair"(%arg0) {flag, n = -1 : i64, s = "a\0Ab"} : (i32) -> (i32, i1) loc(#loc)
    "cf.cond_br"(%0#1, %0#0)[^bb1, ^bb2] : (i1, i32) -> ()
  ^bb1:
    "func.return"(%0#0, %0#1) : (i32, i1) -> () loc(callsite("a"("b":1:1) at fused<"m">[#loc, unknown]))
  ^bb2(%1: i32):
    "x.y"() <{t = tensor<2x?xf32>, d = dense<[1, 2]> : vector<2xi64>, m = affine_map<(d0) -> (d0 + 1)>}> : () -> ()
  }) : () -> ()
}) {dlti.dl_spec = #dlti.dl_spec<i64 = dense<64> : vector<2xi64>>} : () -> ()
"#;
        let m = parse_module(src).unwrap();
        assert_eq!(m.to_string(), src);
    }
}
