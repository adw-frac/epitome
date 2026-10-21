//! The parser for MLIR text in the generic form.
//!
//! It works as `epitome_ir`'s parser does: tokens are slices of the source,
//! with unlimited lookahead; names may be used before they are defined, and
//! such forward references are resolved when the definition arrives, with
//! any left over reported at the end, where they were first used.
//!
//! Any operation can be read in the generic form, `"dialect.op"(...)`.
//! A custom form needs the operation's own grammar; those read so far are
//! in `custom.rs` (see `docs/design/mlir.md`).
//!
//! Value and block names are scoped by region. A use looks outwards
//! through the enclosing regions; a name not found there is a forward
//! reference in the innermost region, and one still undefined when that
//! region closes moves out to the region around it, since in a graph
//! region an operation may use a value defined after it, further out.

use std::collections::HashMap;

use epitome_ir::lexer::{line_col, offset_of};
pub use epitome_ir::parser::ParseError;

use crate::ir::*;
use crate::lexer::{Token, balanced_end, skip_trivia, token_at};

#[path = "custom.rs"]
mod custom;

pub type Result<T> = std::result::Result<T, ParseError>;

/// Parses a file of MLIR in the generic form.
pub fn parse_module(src: &str) -> Result<Module> {
    let mut p = Parser::new(src);
    p.parse_top_level()?;
    p.finish()
}

/// The type of a value used before its definition and before any
/// operation has said what its type is.
const UNSET: TypeId = TypeId(u32::MAX);

/// An operation as read, before it is checked against its type and its
/// results are defined.
struct OpParts<'a> {
    operands: Vec<ValueId>,
    /// Where each operand was written, for error messages.
    operand_toks: Vec<Token<'a>>,
    successors: Vec<BlockId>,
    properties: Option<AttrId>,
    regions: Vec<RegionId>,
    attrs: Option<AttrId>,
    ty: TypeId,
    ty_tok: Token<'a>,
}

/// An entry block's argument as a custom form writes it: its name, type
/// and location.
type EntryArg<'a> = (Token<'a>, TypeId, Option<AttrId>);

/// The names visible in one region.
struct Scope {
    region: Option<RegionId>,
    /// A value's name and its number in its group: `%x#1` is `("x", 1)`.
    values: HashMap<(String, u32), ValueId>,
    blocks: HashMap<String, BlockId>,
}

impl Scope {
    fn new(region: Option<RegionId>) -> Self {
        Scope { region, values: HashMap::new(), blocks: HashMap::new() }
    }
}

struct Parser<'a> {
    src: &'a str,
    /// The byte offset reading has reached; the next token starts here or
    /// after whitespace and comments.
    pos: usize,
    m: Module,
    scopes: Vec<Scope>,
    /// Where each forward reference was first used, for error messages.
    value_first_use: HashMap<ValueId, usize>,
    block_first_use: HashMap<BlockId, usize>,
    /// Blocks whose label has been seen, indexed by `BlockId`.
    placed: Vec<bool>,
    /// Forward references from an inner region that met one of the same
    /// name further out: the inner one's uses become the outer one's.
    replaced: HashMap<ValueId, ValueId>,
    type_alias_uses: HashMap<String, usize>,
    attr_alias_uses: HashMap<String, usize>,
}

impl<'a> Parser<'a> {
    fn new(src: &'a str) -> Self {
        Parser {
            src,
            pos: 0,
            m: Module::default(),
            scopes: vec![Scope::new(None)],
            value_first_use: HashMap::new(),
            block_first_use: HashMap::new(),
            placed: Vec::new(),
            replaced: HashMap::new(),
            type_alias_uses: HashMap::new(),
            attr_alias_uses: HashMap::new(),
        }
    }

    // -----------------------------------------------------------------------
    // Token helpers

    fn peek(&self) -> Token<'a> {
        token_at(self.src, skip_trivia(self.src.as_bytes(), self.pos))
    }

    /// The token after the next one.
    fn peek2(&self) -> Token<'a> {
        let t = self.peek();
        let after = self.offset(t) + t.0.len();
        token_at(self.src, skip_trivia(self.src.as_bytes(), after))
    }

    fn next(&mut self) -> Token<'a> {
        let t = self.peek();
        self.pos = self.offset(t) + t.0.len();
        t
    }

    fn eat(&mut self, text: &str) -> bool {
        if self.peek().0 == text {
            self.next();
            true
        } else {
            false
        }
    }

    fn expect(&mut self, text: &str) -> Result<Token<'a>> {
        if self.peek().0 == text { Ok(self.next()) } else { Err(self.error_here(format!("expected '{text}'"))) }
    }

    /// The character just after the last token, with no space between.
    fn adjacent(&self) -> Option<u8> {
        self.src.as_bytes().get(self.pos).copied()
    }

    fn offset(&self, tok: Token<'a>) -> usize {
        offset_of(self.src, tok.0)
    }

    fn error_at_offset(&self, offset: usize, message: impl Into<String>) -> ParseError {
        let (line, column) = line_col(self.src, offset);
        ParseError { offset, line, column, message: message.into() }
    }

    fn error_at(&self, tok: Token<'a>, message: impl Into<String>) -> ParseError {
        self.error_at_offset(self.offset(tok), message)
    }

    fn error_here(&self, message: impl Into<String>) -> ParseError {
        let tok = self.peek();
        let found = if tok.is_eof() { "end of file".to_string() } else { format!("'{}'", tok.0) };
        self.error_at(tok, format!("{}, found {found}", message.into()))
    }

    fn expect_u32(&mut self) -> Result<u32> {
        let tok = self.peek();
        match tok.0.parse::<u32>() {
            Ok(v) => {
                self.next();
                Ok(v)
            }
            Err(_) => Err(self.error_here("expected an unsigned integer")),
        }
    }

    fn expect_string(&mut self) -> Result<Vec<u8>> {
        let tok = self.peek();
        if tok.is_string() && tok.0.len() >= 2 && tok.0.ends_with('"') {
            self.next();
            Ok(tok.string_bytes())
        } else if tok.is_string() {
            Err(self.error_at(tok, "unterminated string"))
        } else {
            Err(self.error_here("expected a string"))
        }
    }

    /// The bracketed text that starts right after the last token, such as
    /// the `<...>` of `!llvm.struct<(i32)>`, and any groups that follow it
    /// directly (`distinct[0]<...>`). Empty if none follows.
    fn raw_body(&mut self) -> Result<String> {
        let b = self.src.as_bytes();
        let start = self.pos;
        while matches!(b.get(self.pos), Some(b'<' | b'[')) {
            match balanced_end(b, self.pos) {
                Some(end) => self.pos = end,
                None => return Err(self.error_at_offset(self.pos, "unbalanced brackets")),
            }
        }
        Ok(self.src[start..self.pos].to_string())
    }

    // -----------------------------------------------------------------------
    // Top level

    fn parse_top_level(&mut self) -> Result<()> {
        loop {
            let tok = self.peek();
            if tok.is_eof() {
                return Ok(());
            }
            if tok.0 == "{-#" {
                self.next();
                let start = self.pos;
                let Some(len) = self.src[start..].find("#-}") else {
                    return Err(self.error_at(tok, "'{-#' without '#-}'"));
                };
                self.m.items.push(Item::Resources(self.src[start..start + len].to_string()));
                self.pos = start + len + 3;
            } else if tok.is_type_id() {
                self.next();
                self.expect("=")?;
                let ty = self.parse_type()?;
                self.m.items.push(Item::TypeAlias { name: tok.name(), ty });
            } else if tok.is_attr_id() {
                self.next();
                self.expect("=")?;
                let attr = self.parse_attr()?;
                self.m.items.push(Item::AttrAlias { name: tok.name(), attr });
            } else {
                let op = self.parse_op(None)?;
                self.m.items.push(Item::Op(op));
            }
        }
    }

    fn finish(mut self) -> Result<Module> {
        let top = self.scopes.pop().expect("the top scope");
        if let Some((key, &v)) = top
            .values
            .iter()
            .filter(|(_, v)| self.m.values[v.index()].def == ValueDef::Forward)
            .min_by_key(|(_, v)| self.value_first_use[v])
        {
            let off = self.value_first_use[&v];
            return Err(self.error_at_offset(off, format!("use of undefined value '%{}'", value_key_text(key))));
        }
        let mut defined_types = std::collections::HashSet::new();
        let mut defined_attrs = std::collections::HashSet::new();
        for item in &self.m.items {
            match item {
                Item::TypeAlias { name, .. } => {
                    defined_types.insert(name.as_str());
                }
                Item::AttrAlias { name, .. } => {
                    defined_attrs.insert(name.as_str());
                }
                _ => {}
            }
        }
        let undefined_type =
            self.type_alias_uses.iter().filter(|(n, _)| !defined_types.contains(n.as_str())).min_by_key(|(_, o)| **o);
        if let Some((name, &off)) = undefined_type {
            return Err(self.error_at_offset(off, format!("undefined type alias '!{name}'")));
        }
        let undefined_attr =
            self.attr_alias_uses.iter().filter(|(n, _)| !defined_attrs.contains(n.as_str())).min_by_key(|(_, o)| **o);
        if let Some((name, &off)) = undefined_attr {
            return Err(self.error_at_offset(off, format!("undefined attribute alias '#{name}'")));
        }
        if !self.replaced.is_empty() {
            let resolve = |mut v: ValueId| {
                while let Some(&w) = self.replaced.get(&v) {
                    v = w;
                }
                v
            };
            for op in &mut self.m.ops {
                for v in &mut op.operands {
                    *v = resolve(*v);
                }
            }
        }
        Ok(self.m)
    }

    // -----------------------------------------------------------------------
    // Operations

    fn parse_op(&mut self, parent: Option<BlockId>) -> Result<OpId> {
        // `%a, %b:2 =`
        let mut groups: Vec<(Token<'a>, u32)> = Vec::new();
        if self.peek().is_value() {
            loop {
                let tok = self.next();
                if !tok.is_value() {
                    return Err(self.error_at(tok, "expected a result name such as '%0'"));
                }
                let count = if self.eat(":") { self.expect_u32()? } else { 1 };
                groups.push((tok, count));
                if !self.eat(",") {
                    break;
                }
            }
            self.expect("=")?;
        }
        let name_tok = self.peek();
        let op = OpId(self.m.ops.len() as u32);
        let placeholder = self.m.intern_name("");
        self.m.ops.push(Operation {
            name: placeholder,
            operands: Vec::new(),
            results: Vec::new(),
            successors: Vec::new(),
            properties: None,
            regions: Vec::new(),
            attrs: None,
            ty: UNSET,
            loc: None,
            parent,
        });
        let (name, parts) = if name_tok.is_string() {
            let name =
                String::from_utf8(self.expect_string()?).map_err(|_| self.error_at(name_tok, "name is not UTF-8"))?;
            (self.m.intern_name(&name), self.parse_generic_body(op)?)
        } else if name_tok.is_bare() {
            self.next();
            self.parse_custom_body(op, name_tok)?
        } else {
            return Err(self.error_here("expected an operation"));
        };
        self.m.ops[op.index()].name = name;
        self.finish_op(op, groups, parts)
    }

    /// The generic form after the name: `(operands)[successors] <{props}>
    /// (regions) {attrs} : type`.
    fn parse_generic_body(&mut self, op: OpId) -> Result<OpParts<'a>> {
        // Operands.
        self.expect("(")?;
        let mut operands = Vec::new();
        let mut operand_toks = Vec::new();
        if !self.eat(")") {
            loop {
                operand_toks.push(self.peek());
                operands.push(self.value_use()?);
                if self.eat(")") {
                    break;
                }
                self.expect(",")?;
            }
        }

        // Successors.
        let mut successors = Vec::new();
        if self.eat("[") {
            loop {
                let tok = self.next();
                if !tok.is_block() {
                    return Err(self.error_at(tok, "expected a block such as '^bb1'"));
                }
                successors.push(self.block_ref(tok)?);
                if self.eat("]") {
                    break;
                }
                self.expect(",")?;
            }
        }

        // Properties.
        let mut properties = None;
        if self.peek().0 == "<" {
            self.next();
            properties = Some(self.parse_dict()?);
            self.expect(">")?;
        }

        // Regions.
        let mut regions = Vec::new();
        if self.peek().0 == "(" && self.peek2().0 == "{" {
            self.next();
            loop {
                regions.push(self.parse_region(op, None)?);
                if self.eat(")") {
                    break;
                }
                self.expect(",")?;
            }
        }

        // Attributes and type.
        let attrs = if self.peek().0 == "{" { Some(self.parse_dict()?) } else { None };
        self.expect(":")?;
        let ty_tok = self.peek();
        let ty = self.parse_type()?;
        Ok(OpParts { operands, operand_toks, successors, properties, regions, attrs, ty, ty_tok })
    }

    /// Checks the operands against the type, defines the results and fills
    /// in the operation. A location may follow either form.
    fn finish_op(&mut self, op: OpId, groups: Vec<(Token<'a>, u32)>, parts: OpParts<'a>) -> Result<OpId> {
        let OpParts { operands, operand_toks, successors, properties, regions, attrs, ty, ty_tok } = parts;
        let Type::Function { inputs, results } = self.m.ty(ty).clone() else {
            return Err(self.error_at(ty_tok, "expected a function type such as '(i32) -> i32'"));
        };
        let loc = if self.peek().0 == "loc" { Some(self.parse_loc()?) } else { None };

        if inputs.len() != operands.len() {
            return Err(self.error_at(
                ty_tok,
                format!("{} operands, but the type has {} operand types", operands.len(), inputs.len()),
            ));
        }
        for ((&v, &t), &tok) in operands.iter().zip(&inputs).zip(&operand_toks) {
            let value = &mut self.m.values[v.index()];
            if value.ty == UNSET {
                value.ty = t;
            } else if value.ty != t {
                return Err(self.error_at(tok, "value used with a different type from its definition"));
            }
        }

        // Results are defined after the operation, so not inside its regions.
        let named: u32 = groups.iter().map(|g| g.1).sum();
        if !groups.is_empty() && named as usize != results.len() {
            return Err(self.error_at(
                groups[0].0,
                format!("{named} results named, but the type has {} result types", results.len()),
            ));
        }
        let mut result_values = Vec::with_capacity(results.len());
        let mut index = 0u32;
        if groups.is_empty() {
            for &t in &results {
                result_values.push(self.new_value(None, None, t, ValueDef::Result { op, index }));
                index += 1;
            }
        } else {
            for (tok, count) in groups {
                for i in 0..count {
                    let group_index = (count > 1).then_some(i);
                    let def = ValueDef::Result { op, index };
                    let v = self.define_value(tok, i, group_index, results[index as usize], def)?;
                    result_values.push(v);
                    index += 1;
                }
            }
        }

        let o = &mut self.m.ops[op.index()];
        o.operands = operands;
        o.results = result_values;
        o.successors = successors;
        o.properties = properties;
        o.regions = regions;
        o.attrs = attrs;
        o.ty = ty;
        o.loc = loc;
        Ok(op)
    }

    /// A region, `{ ... }`. `entry`, from a custom form such as
    /// `func.func`'s, gives the entry block and its arguments, which the
    /// text inside the braces then leaves out.
    fn parse_region(&mut self, op: OpId, entry: Option<Vec<EntryArg<'a>>>) -> Result<RegionId> {
        self.expect("{")?;
        let region = RegionId(self.m.regions.len() as u32);
        self.m.regions.push(Region { blocks: Vec::new(), parent: Some(op) });
        self.scopes.push(Scope::new(Some(region)));
        let mut current: Option<BlockId> = None;
        if let Some(args) = entry {
            let block = self.new_block(None, region);
            self.placed[block.index()] = true;
            self.m.regions[region.index()].blocks.push(block);
            for (index, (tok, ty, loc)) in args.into_iter().enumerate() {
                let v = self.define_value(tok, 0, None, ty, ValueDef::BlockArg { block, index: index as u32 })?;
                self.m.values[v.index()].loc = loc;
                self.m.blocks[block.index()].args.push(v);
            }
            current = Some(block);
        }
        loop {
            let tok = self.peek();
            if tok.0 == "}" {
                self.next();
                break;
            }
            if tok.is_eof() {
                return Err(self.error_here("expected '}'"));
            }
            if tok.is_block() {
                self.next();
                let block = self.define_block(tok, region)?;
                if self.eat("(") {
                    let mut index = 0;
                    loop {
                        let arg = self.next();
                        if !arg.is_value() {
                            return Err(self.error_at(arg, "expected an argument such as '%arg0'"));
                        }
                        self.expect(":")?;
                        let ty = self.parse_type()?;
                        let v = self.define_value(arg, 0, None, ty, ValueDef::BlockArg { block, index })?;
                        if self.peek().0 == "loc" {
                            let loc = self.parse_loc()?;
                            self.m.values[v.index()].loc = Some(loc);
                        }
                        self.m.blocks[block.index()].args.push(v);
                        index += 1;
                        if self.eat(")") {
                            break;
                        }
                        self.expect(",")?;
                    }
                }
                self.expect(":")?;
                current = Some(block);
                continue;
            }
            let block = match current {
                Some(b) => b,
                None => {
                    // The entry block, written without a label.
                    let b = self.new_block(None, region);
                    self.placed[b.index()] = true;
                    self.m.regions[region.index()].blocks.push(b);
                    current = Some(b);
                    b
                }
            };
            let op = self.parse_op(Some(block))?;
            self.m.blocks[block.index()].ops.push(op);
        }
        self.close_scope()?;
        Ok(region)
    }

    /// Ends the innermost region: its blocks must all be defined, and its
    /// undefined values move out to the region around it.
    fn close_scope(&mut self) -> Result<()> {
        let scope = self.scopes.pop().expect("a region scope");
        if let Some((name, &b)) =
            scope.blocks.iter().filter(|(_, b)| !self.placed[b.index()]).min_by_key(|(_, b)| self.block_first_use[b])
        {
            let off = self.block_first_use[&b];
            return Err(self.error_at_offset(off, format!("use of undefined block '^{name}'")));
        }
        let outer = self.scopes.last_mut().expect("the top scope");
        for (key, v) in scope.values {
            if self.m.values[v.index()].def != ValueDef::Forward {
                continue;
            }
            match outer.values.get(&key) {
                Some(&w) => {
                    let (t, u) = (self.m.values[v.index()].ty, self.m.values[w.index()].ty);
                    if t != UNSET && u != UNSET && t != u {
                        let off = self.value_first_use[&v];
                        return Err(self.error_at_offset(off, "value used with a different type from its definition"));
                    }
                    if u == UNSET {
                        self.m.values[w.index()].ty = t;
                    }
                    self.replaced.insert(v, w);
                }
                None => {
                    outer.values.insert(key, v);
                }
            }
        }
        Ok(())
    }

    // -----------------------------------------------------------------------
    // Values and blocks

    fn new_value(&mut self, name: Option<String>, group_index: Option<u32>, ty: TypeId, def: ValueDef) -> ValueId {
        let v = ValueId(self.m.values.len() as u32);
        self.m.values.push(Value { name, group_index, ty, def, loc: None });
        v
    }

    /// Defines result `index` of the group named by `tok`, or a block
    /// argument, in the innermost region.
    fn define_value(
        &mut self,
        tok: Token<'a>,
        index: u32,
        group_index: Option<u32>,
        ty: TypeId,
        def: ValueDef,
    ) -> Result<ValueId> {
        let name = tok.name();
        let key = (name.clone(), index);
        if let Some(&v) = self.scopes.last().unwrap().values.get(&key) {
            let value = &mut self.m.values[v.index()];
            if value.def != ValueDef::Forward {
                return Err(self.error_at(tok, format!("redefinition of value '{}'", tok.0)));
            }
            if value.ty != UNSET && value.ty != ty {
                let off = self.value_first_use[&v];
                return Err(self.error_at_offset(off, "value used with a different type from its definition"));
            }
            value.ty = ty;
            value.def = def;
            value.group_index = group_index;
            return Ok(v);
        }
        let v = self.new_value(Some(name), group_index, ty, def);
        self.scopes.last_mut().unwrap().values.insert(key, v);
        Ok(v)
    }

    /// A use of a value, `%x` or `%x#1`.
    fn value_use(&mut self) -> Result<ValueId> {
        let tok = self.next();
        if !tok.is_value() {
            return Err(self.error_at(tok, "expected a value such as '%0'"));
        }
        let mut index = 0;
        let b = self.src.as_bytes();
        if self.adjacent() == Some(b'#') && b.get(self.pos + 1).is_some_and(|c| c.is_ascii_digit()) {
            let start = self.pos + 1;
            let mut end = start;
            while end < b.len() && b[end].is_ascii_digit() {
                end += 1;
            }
            index = self.src[start..end].parse().map_err(|_| self.error_at(tok, "result number too large"))?;
            self.pos = end;
        }
        let key = (tok.name(), index);
        for scope in self.scopes.iter().rev() {
            if let Some(&v) = scope.values.get(&key) {
                return Ok(v);
            }
        }
        let v = self.new_value(Some(key.0.clone()), None, UNSET, ValueDef::Forward);
        self.value_first_use.insert(v, self.offset(tok));
        self.scopes.last_mut().unwrap().values.insert(key, v);
        Ok(v)
    }

    fn new_block(&mut self, name: Option<String>, region: RegionId) -> BlockId {
        let b = BlockId(self.m.blocks.len() as u32);
        self.m.blocks.push(Block { name, args: Vec::new(), ops: Vec::new(), parent: region });
        self.placed.push(false);
        b
    }

    /// The label at the start of a block, `^bb1`.
    fn define_block(&mut self, tok: Token<'a>, region: RegionId) -> Result<BlockId> {
        let name = tok.name();
        let block = match self.scopes.last().unwrap().blocks.get(&name) {
            Some(&b) if self.placed[b.index()] => {
                return Err(self.error_at(tok, format!("redefinition of block '{}'", tok.0)));
            }
            Some(&b) => b,
            None => {
                let b = self.new_block(Some(name.clone()), region);
                self.scopes.last_mut().unwrap().blocks.insert(name, b);
                b
            }
        };
        self.placed[block.index()] = true;
        self.m.regions[region.index()].blocks.push(block);
        Ok(block)
    }

    /// A successor, `^bb1`, which must be in the same region.
    fn block_ref(&mut self, tok: Token<'a>) -> Result<BlockId> {
        let name = tok.name();
        let scope = self.scopes.last().unwrap();
        if let Some(&b) = scope.blocks.get(&name) {
            return Ok(b);
        }
        let Some(region) = scope.region else {
            return Err(self.error_at(tok, "a successor outside any region"));
        };
        let b = self.new_block(Some(name.clone()), region);
        self.block_first_use.insert(b, self.offset(tok));
        self.scopes.last_mut().unwrap().blocks.insert(name, b);
        Ok(b)
    }

    // -----------------------------------------------------------------------
    // Types

    fn parse_type(&mut self) -> Result<TypeId> {
        let tok = self.peek();
        if tok.0 == "(" {
            return self.parse_function_type();
        }
        if tok.is_type_id() {
            self.next();
            let name = tok.name();
            let body = self.raw_body()?;
            let ty = if name.contains('.') || !body.is_empty() {
                Type::Dialect { name, body: (!body.is_empty()).then_some(body) }
            } else {
                let off = self.offset(tok);
                self.type_alias_uses.entry(name.clone()).or_insert(off);
                Type::Alias(name)
            };
            return Ok(self.m.intern_type(ty));
        }
        if !tok.is_bare() {
            return Err(self.error_here("expected a type"));
        }
        let word = tok.0;
        if let Some(ty) = int_type(word) {
            self.next();
            return Ok(self.m.intern_type(ty));
        }
        if let Some(&f) = FLOAT_TYPES.iter().find(|&&f| f == word) {
            self.next();
            return Ok(self.m.intern_type(Type::Float(f)));
        }
        let ty = match word {
            "index" => {
                self.next();
                Type::Index
            }
            "none" => {
                self.next();
                Type::None
            }
            "complex" => {
                self.next();
                self.expect("<")?;
                let elem = self.parse_type()?;
                self.expect(">")?;
                Type::Complex(elem)
            }
            "tuple" => {
                self.next();
                self.expect("<")?;
                let mut elems = Vec::new();
                if !self.eat(">") {
                    loop {
                        elems.push(self.parse_type()?);
                        if self.eat(">") {
                            break;
                        }
                        self.expect(",")?;
                    }
                }
                Type::Tuple(elems)
            }
            "vector" => {
                self.next();
                self.expect("<")?;
                let (shape, scalable) = self.parse_dims(false, true)?;
                let shape = shape.expect("vectors are ranked");
                let mut dims = Vec::with_capacity(shape.len());
                for (d, s) in shape.into_iter().zip(scalable) {
                    let Some(d) = d else { return Err(self.error_at(tok, "a vector's sizes must be known")) };
                    dims.push((d, s));
                }
                let elem = self.parse_type()?;
                self.expect(">")?;
                Type::Vector { dims, elem }
            }
            "tensor" => {
                self.next();
                self.expect("<")?;
                let (shape, _) = self.parse_dims(true, false)?;
                let elem = self.parse_type()?;
                let encoding = if self.eat(",") { Some(self.parse_attr()?) } else { None };
                self.expect(">")?;
                Type::Tensor { shape, elem, encoding }
            }
            "memref" => {
                self.next();
                self.expect("<")?;
                let (shape, _) = self.parse_dims(true, false)?;
                let elem = self.parse_type()?;
                let mut extra = Vec::new();
                while self.eat(",") {
                    extra.push(self.parse_attr()?);
                }
                self.expect(">")?;
                Type::MemRef { shape, elem, extra }
            }
            "opaque" => {
                self.next();
                self.expect("<")?;
                let dialect = self.expect_string()?;
                self.expect(",")?;
                let data = self.expect_string()?;
                self.expect(">")?;
                Type::Opaque { dialect, data }
            }
            _ => return Err(self.error_here("expected a type")),
        };
        Ok(self.m.intern_type(ty))
    }

    /// `(i32, f32) -> i8` or `() -> (i8, i8)`.
    fn parse_function_type(&mut self) -> Result<TypeId> {
        let inputs = self.parse_type_list()?;
        self.expect("->")?;
        let results = if self.peek().0 == "(" { self.parse_type_list()? } else { vec![self.parse_type()?] };
        Ok(self.m.intern_type(Type::Function { inputs, results }))
    }

    fn parse_type_list(&mut self) -> Result<Vec<TypeId>> {
        self.expect("(")?;
        let mut list = Vec::new();
        if self.eat(")") {
            return Ok(list);
        }
        loop {
            list.push(self.parse_type()?);
            if self.eat(")") {
                return Ok(list);
            }
            self.expect(",")?;
        }
    }

    /// The dimensions of a shaped type, each followed by `x`: `4x?x`, or
    /// `*x` for an unranked one. They are read as characters, since `4x8`
    /// is not split into tokens the way a shape needs. Returns the shape
    /// (`None` if unranked) and which dimensions were scalable, `[4]`.
    fn parse_dims(&mut self, unranked: bool, scalable: bool) -> Result<(Option<Vec<Dim>>, Vec<bool>)> {
        let b = self.src.as_bytes();
        let mut i = skip_trivia(b, self.pos);
        if unranked && b.get(i) == Some(&b'*') {
            i = skip_trivia(b, i + 1);
            if b.get(i) != Some(&b'x') {
                return Err(self.error_at_offset(i, "expected 'x' after '*'"));
            }
            self.pos = i + 1;
            return Ok((None, Vec::new()));
        }
        let mut dims = Vec::new();
        let mut flags = Vec::new();
        loop {
            let start = i;
            let (dim, is_scalable) = match b.get(i) {
                Some(c) if c.is_ascii_digit() => {
                    while b.get(i).is_some_and(|c| c.is_ascii_digit()) {
                        i += 1;
                    }
                    (Some(self.dim_value(start, i)?), false)
                }
                Some(b'?') if unranked => {
                    i += 1;
                    (None, false)
                }
                Some(b'[') if scalable => {
                    let digits = i + 1;
                    i = digits;
                    while b.get(i).is_some_and(|c| c.is_ascii_digit()) {
                        i += 1;
                    }
                    let d = self.dim_value(digits, i)?;
                    if b.get(i) != Some(&b']') {
                        return Err(self.error_at_offset(i, "expected ']'"));
                    }
                    i += 1;
                    (Some(d), true)
                }
                _ => break,
            };
            if b.get(i) != Some(&b'x') {
                return Err(self.error_at_offset(i, "expected 'x' in a dimension list"));
            }
            i = skip_trivia(b, i + 1);
            dims.push(dim);
            flags.push(is_scalable);
        }
        self.pos = i;
        Ok((Some(dims), flags))
    }

    fn dim_value(&self, start: usize, end: usize) -> Result<u64> {
        self.src[start..end].parse().map_err(|_| self.error_at_offset(start, "expected a dimension size"))
    }

    // -----------------------------------------------------------------------
    // Attributes

    fn parse_attr(&mut self) -> Result<AttrId> {
        let tok = self.peek();
        let attr = match tok.0 {
            "[" => {
                self.next();
                let mut elems = Vec::new();
                if !self.eat("]") {
                    loop {
                        elems.push(self.parse_attr()?);
                        if self.eat("]") {
                            break;
                        }
                        self.expect(",")?;
                    }
                }
                Attr::Array(elems)
            }
            "{" => return self.parse_dict(),
            "-" => {
                self.next();
                let num = self.next();
                if !num.is_number() || self.offset(num) != self.offset(tok) + 1 {
                    return Err(self.error_at(num, "expected a number after '-'"));
                }
                self.number_attr(format!("-{}", num.0))?
            }
            "true" | "false" => {
                self.next();
                Attr::Bool(tok.0 == "true")
            }
            "unit" => {
                self.next();
                Attr::Unit
            }
            "loc" => return self.parse_loc(),
            _ if tok.is_number() => {
                self.next();
                self.number_attr(tok.0.to_string())?
            }
            _ if tok.is_string() => {
                let bytes = self.expect_string()?;
                let ty = self.opt_type_suffix()?;
                Attr::String { bytes, ty }
            }
            _ if tok.is_symbol() => {
                self.next();
                let mut path = vec![tok.name()];
                while self.eat("::") {
                    let part = self.next();
                    if !part.is_symbol() {
                        return Err(self.error_at(part, "expected a symbol such as '@f'"));
                    }
                    path.push(part.name());
                }
                Attr::SymbolRef(path)
            }
            _ if tok.is_attr_id() => {
                self.next();
                let name = tok.name();
                let body = self.raw_body()?;
                if name.contains('.') || !body.is_empty() {
                    Attr::Dialect { name, body: (!body.is_empty()).then_some(body) }
                } else {
                    let off = self.offset(tok);
                    self.attr_alias_uses.entry(name.clone()).or_insert(off);
                    Attr::Alias(name)
                }
            }
            _ if BUILTIN_ATTRS.contains(&tok.0)
                && matches!(self.src.as_bytes().get(self.offset(tok) + tok.0.len()), Some(b'<' | b'[')) =>
            {
                self.next();
                let keyword = *BUILTIN_ATTRS.iter().find(|&&k| k == tok.0).unwrap();
                let body = self.raw_body()?;
                let ty = if TYPED_BUILTIN_ATTRS.contains(&keyword) { self.opt_type_suffix()? } else { None };
                Attr::Builtin { keyword, body, ty }
            }
            _ => Attr::Type(self.parse_type()?),
        };
        Ok(self.m.intern_attr(attr))
    }

    /// An integer or float attribute, with its type if one follows.
    fn number_attr(&mut self, text: String) -> Result<Attr> {
        let ty = self.opt_type_suffix()?;
        let is_float = !text.contains("0x") && (text.contains('.') || text.contains('e') || text.contains('E'));
        Ok(if is_float { Attr::Float { text, ty } } else { Attr::Int { text, ty } })
    }

    /// `: type` after a literal.
    fn opt_type_suffix(&mut self) -> Result<Option<TypeId>> {
        if self.peek().0 == ":" {
            self.next();
            Ok(Some(self.parse_type()?))
        } else {
            Ok(None)
        }
    }

    /// `{a = 1, b}`
    fn parse_dict(&mut self) -> Result<AttrId> {
        self.expect("{")?;
        let mut entries = Vec::new();
        if !self.eat("}") {
            loop {
                let key = self.next();
                let name = if key.is_string() {
                    String::from_utf8(key.string_bytes()).map_err(|_| self.error_at(key, "name is not UTF-8"))?
                } else if key.is_bare() {
                    key.0.to_string()
                } else {
                    return Err(self.error_at(key, "expected an attribute name"));
                };
                let value = if self.eat("=") { self.parse_attr()? } else { self.m.intern_attr(Attr::Unit) };
                entries.push((name, value));
                if self.eat("}") {
                    break;
                }
                self.expect(",")?;
            }
        }
        Ok(self.m.intern_attr(Attr::Dict(entries)))
    }

    /// `loc(...)`
    fn parse_loc(&mut self) -> Result<AttrId> {
        self.expect("loc")?;
        self.expect("(")?;
        let loc = self.parse_loc_body()?;
        self.expect(")")?;
        Ok(loc)
    }

    /// A location inside `loc(...)`, or a part of one.
    fn parse_loc_body(&mut self) -> Result<AttrId> {
        let tok = self.peek();
        let loc = match tok.0 {
            "unknown" => {
                self.next();
                Loc::Unknown
            }
            "callsite" => {
                self.next();
                self.expect("(")?;
                let callee = self.parse_loc_body()?;
                self.expect("at")?;
                let caller = self.parse_loc_body()?;
                self.expect(")")?;
                Loc::CallSite { callee, caller }
            }
            "fused" => {
                self.next();
                let metadata = if self.eat("<") {
                    let m = self.parse_attr()?;
                    self.expect(">")?;
                    Some(m)
                } else {
                    None
                };
                self.expect("[")?;
                let mut locs = Vec::new();
                if !self.eat("]") {
                    loop {
                        locs.push(self.parse_loc_body()?);
                        if self.eat("]") {
                            break;
                        }
                        self.expect(",")?;
                    }
                }
                Loc::Fused { metadata, locs }
            }
            _ if tok.is_attr_id() => {
                self.next();
                let name = tok.name();
                let off = self.offset(tok);
                self.attr_alias_uses.entry(name.clone()).or_insert(off);
                Loc::Alias(name)
            }
            _ if tok.is_string() => {
                let name = self.expect_string()?;
                if self.eat(":") {
                    let line = self.expect_u32()?;
                    self.expect(":")?;
                    let col = self.expect_u32()?;
                    let end = if self.eat("to") {
                        let mut end = String::new();
                        if self.peek().is_number() {
                            end += self.next().0;
                        }
                        if self.eat(":") {
                            end.push(':');
                            end += &self.expect_u32()?.to_string();
                        }
                        Some(end)
                    } else {
                        None
                    };
                    Loc::File { file: name, line, col, end }
                } else if self.eat("(") {
                    let child = self.parse_loc_body()?;
                    self.expect(")")?;
                    Loc::Name { name, child: Some(child) }
                } else {
                    Loc::Name { name, child: None }
                }
            }
            _ => return Err(self.error_here("expected a location")),
        };
        Ok(self.m.intern_attr(Attr::Loc(loc)))
    }
}

/// `i32`, `si8` or `ui16`.
fn int_type(word: &str) -> Option<Type> {
    let (signedness, digits) = if let Some(d) = word.strip_prefix("si") {
        (Signedness::Signed, d)
    } else if let Some(d) = word.strip_prefix("ui") {
        (Signedness::Unsigned, d)
    } else {
        (Signedness::Signless, word.strip_prefix('i')?)
    };
    if digits.is_empty() || !digits.bytes().all(|b| b.is_ascii_digit()) || (digits.starts_with('0') && digits != "0") {
        return None;
    }
    Some(Type::Int { width: digits.parse().ok()?, signedness })
}

fn value_key_text(key: &(String, u32)) -> String {
    if key.1 == 0 { key.0.clone() } else { format!("{}#{}", key.0, key.1) }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn a_function() {
        let src = r#""builtin.module"() ({
  "func.func"() <{function_type = (i32) -> i32, sym_name = "f"}> ({
  ^bb0(%arg0: i32):
    %0 = "arith.addi"(%arg0, %arg0) <{overflowFlags = #arith.overflow<none>}> : (i32, i32) -> i32
    "func.return"(%0) : (i32) -> ()
  }) : () -> ()
}) : () -> ()
"#;
        let m = parse_module(src).unwrap();
        assert_eq!(m.ops.len(), 4);
        let add = OpId(2);
        assert_eq!(m.op_name(add), "arith.addi");
        let ops = &m.ops[add.index()].operands;
        assert_eq!(ops[0], ops[1]);
        assert!(matches!(m.values[ops[0].index()].def, ValueDef::BlockArg { index: 0, .. }));
        let f = m.top_ops().next().unwrap();
        let mut names = Vec::new();
        m.walk(f, &mut |o| names.push(m.op_name(o).to_string()));
        assert_eq!(names, ["builtin.module", "func.func", "arith.addi", "func.return"]);
    }

    #[test]
    fn forward_references() {
        // A use in an earlier block, and a block used before its label.
        let src = r#""f"() ({
  "br"()[^bb2] : () -> ()
^bb1:
  "use"(%x) : (i8) -> ()
  "br"()[^bb2] : () -> ()
^bb2:
  %x = "def"() : () -> i8
  "br"()[^bb1] : () -> ()
}) : () -> ()
"#;
        let m = parse_module(src).unwrap();
        let user = m.ops.iter().find(|o| m.name(o.name) == "use").unwrap();
        assert!(matches!(m.values[user.operands[0].index()].def, ValueDef::Result { .. }));
    }

    #[test]
    fn graph_region_use_from_inside() {
        // A use inside a nested region of a value defined later outside it.
        let src = r#""m"() ({
  "w"() ({
    "use"(%y) : (i1) -> ()
  }) : () -> ()
  %y = "def"() : () -> i1
}) : () -> ()
"#;
        let m = parse_module(src).unwrap();
        let user = m.ops.iter().find(|o| m.name(o.name) == "use").unwrap();
        let def = m.ops.iter().position(|o| m.name(o.name) == "def").unwrap();
        assert_eq!(m.values[user.operands[0].index()].def, ValueDef::Result { op: OpId(def as u32), index: 0 });
    }

    #[test]
    fn multiple_results() {
        let src = "%0:2 = \"a\"() : () -> (i1, i8)\n\"b\"(%0#1, %0) : (i8, i1) -> ()\n";
        let m = parse_module(src).unwrap();
        let b = &m.ops[1];
        assert_eq!(b.operands, [m.ops[0].results[1], m.ops[0].results[0]]);
    }

    #[test]
    fn types() {
        let src = "\"a\"() : () -> (tensor<2x?xf32>, memref<*xi8, 1>, vector<[4]x8xbf16>, tuple<>, complex<f64>, \
                   !llvm.struct<(i32, ptr)>, ui16, (i1) -> i1, i0)\n";
        let m = parse_module(src).unwrap();
        let (_, results) = m.op_signature(OpId(0));
        let f32t = m.types().find(|(_, t)| **t == Type::Float("f32")).unwrap().0;
        assert_eq!(*m.ty(results[0]), Type::Tensor { shape: Some(vec![Some(2), None]), elem: f32t, encoding: None });
        assert!(matches!(m.ty(results[1]), Type::MemRef { shape: None, .. }));
        assert!(matches!(m.ty(results[2]), Type::Vector { dims, .. } if dims == &[(4, true), (8, false)]));
        assert!(
            matches!(m.ty(results[5]), Type::Dialect { name, body: Some(b) } if name == "llvm.struct" && b == "<(i32, ptr)>")
        );
        assert_eq!(*m.ty(results[6]), Type::Int { width: 16, signedness: Signedness::Unsigned });
        assert_eq!(*m.ty(results[8]), Type::Int { width: 0, signedness: Signedness::Signless });
    }

    #[test]
    fn errors() {
        let err = |s: &str| parse_module(s).unwrap_err().to_string();
        assert!(err("\"a\"(%x) : (i1) -> ()\n").contains("use of undefined value '%x'"));
        assert!(err("\"f\"() ({\n  \"br\"()[^bb9] : () -> ()\n}) : () -> ()\n").contains("undefined block '^bb9'"));
        assert!(err("%0 = \"a\"() : () -> i1\n%0 = \"b\"() : () -> i1\n").contains("redefinition"));
        assert!(err("%0 = \"a\"() : () -> i1\n\"b\"(%0) : (i8) -> ()\n").starts_with("2:5:"));
        assert!(err("my.op %a : i1\n").contains("custom form of 'my.op'"));
        assert!(err("\"a\"() : () -> !undefined\n").contains("undefined type alias"));
        assert!(err("\"a\"() : () -> () loc(#nowhere)\n").contains("undefined attribute alias '#nowhere'"));
    }
}
