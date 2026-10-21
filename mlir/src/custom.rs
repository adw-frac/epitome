//! Custom forms: the operations whose own syntax is read, each turned into
//! the operation the generic form would give, with the same properties.
//!
//! So far these are what torch-mlir writes: `builtin.module`, `func.func`
//! and `func.return`, and the `torch` dialect's operations. Most `torch`
//! operations share one form, `torch.aten.mm %a, %b : T1, T2 -> R`; the
//! constants, `torch.vtensor.literal` and `torch.prim.ListConstruct` have
//! their own.

use super::*;

/// `arith.cmpf`'s predicates, in the order of their numbers.
pub const CMPF_PREDICATES: &[&str] = &[
    "false", "oeq", "ogt", "oge", "olt", "ole", "one", "ord", "ueq", "ugt", "uge", "ult", "ule", "une", "uno", "true",
];

/// `arith.cmpi`'s predicates, in the order of their numbers.
pub const CMPI_PREDICATES: &[&str] = &["eq", "ne", "slt", "sle", "sgt", "sge", "ult", "ule", "ugt", "uge"];

/// `arith` operations from one type to another, `%y = arith.extsi %x : i8 to i32`.
const ARITH_CASTS: &[&str] = &[
    "arith.extsi",
    "arith.extui",
    "arith.trunci",
    "arith.sitofp",
    "arith.uitofp",
    "arith.fptosi",
    "arith.fptoui",
    "arith.extf",
    "arith.truncf",
    "arith.index_cast",
    "arith.index_castui",
    "arith.bitcast",
];

/// `arith` operations with a `fastmath` property.
const ARITH_FASTMATH: &[&str] = &[
    "arith.addf",
    "arith.subf",
    "arith.mulf",
    "arith.divf",
    "arith.remf",
    "arith.negf",
    "arith.maximumf",
    "arith.minimumf",
    "arith.maxnumf",
    "arith.minnumf",
];

/// `arith` operations with an `overflowFlags` property.
const ARITH_OVERFLOW: &[&str] = &["arith.addi", "arith.subi", "arith.muli", "arith.shli"];

impl<'a> Parser<'a> {
    /// The operation named by `name`, already read, in its custom form.
    pub(super) fn parse_custom_body(&mut self, op: OpId, name: Token<'a>) -> Result<(NameId, OpParts<'a>)> {
        let parts = match name.0 {
            "module" | "builtin.module" => {
                return Ok((self.m.intern_name("builtin.module"), self.parse_module(op, name)?));
            }
            "func.func" => self.parse_func(op, name)?,
            "return" | "func.return" => return Ok((self.m.intern_name("func.return"), self.parse_return(name)?)),
            "torch.constant.int" => self.parse_constant(name, |p| p.parse_signed_number(), "i64", "torch.int")?,
            "torch.constant.float" => self.parse_constant(name, |p| p.parse_signed_number(), "f64", "torch.float")?,
            "torch.constant.bool" => self.parse_constant(name, |p| p.parse_attr(), "", "torch.bool")?,
            "torch.constant.str" => self.parse_constant(name, |p| p.parse_attr(), "", "torch.str")?,
            "torch.constant.none" => {
                let none = self.dialect_type("torch.none");
                self.no_operands(name, None, none)
            }
            "torch.vtensor.literal" => {
                self.expect("(")?;
                let value = self.parse_attr()?;
                self.expect(")")?;
                self.expect(":")?;
                let ty_tok = self.peek();
                let ty = self.parse_type()?;
                let props = self.dict(vec![("value", value)]);
                self.no_operands(ty_tok, Some(props), ty)
            }
            "torch.prim.ListConstruct" => {
                let (operands, operand_toks) = self.operand_list()?;
                self.expect(":")?;
                let ty_tok = self.peek();
                let ty = self.parse_type()?;
                OpParts { operands, operand_toks, ..self.empty_parts(ty_tok, ty) }
            }
            _ if name.0.starts_with("torch.") => self.parse_torch_op()?,
            "arith.constant" => {
                let value = self.parse_attr()?;
                let ty = match self.m.attr(value) {
                    Attr::Bool(_) => self.m.intern_type(Type::Int { width: 1, signedness: Signedness::Signless }),
                    Attr::Int { ty: Some(t), .. }
                    | Attr::Float { ty: Some(t), .. }
                    | Attr::Builtin { ty: Some(t), .. } => *t,
                    _ => return Err(self.error_at(name, "expected a typed constant such as '1 : i32'")),
                };
                let props = self.dict(vec![("value", value)]);
                self.no_operands(name, Some(props), ty)
            }
            "arith.cmpf" | "arith.cmpi" => {
                let pred = self.next();
                let list = if name.0 == "arith.cmpf" { CMPF_PREDICATES } else { CMPI_PREDICATES };
                let Some(n) = list.iter().position(|&p| p == pred.0) else {
                    return Err(self.error_at(pred, format!("unknown predicate '{}'", pred.0)));
                };
                self.expect(",")?;
                let (operands, operand_toks) = self.operand_list()?;
                self.expect(":")?;
                let ty_tok = self.peek();
                let t = self.parse_type()?;
                let i64t = self.m.intern_type(Type::Int { width: 64, signedness: Signedness::Signless });
                let pred = self.m.intern_attr(Attr::Int { text: n.to_string(), ty: Some(i64t) });
                let mut props = vec![("predicate", pred)];
                if name.0 == "arith.cmpf" {
                    props.insert(
                        0,
                        (
                            "fastmath",
                            self.m.intern_attr(Attr::Dialect {
                                name: "arith.fastmath".into(),
                                body: Some("<none>".into()),
                            }),
                        ),
                    );
                }
                let i1 = self.m.intern_type(Type::Int { width: 1, signedness: Signedness::Signless });
                let ty = self.m.intern_type(Type::Function { inputs: vec![t, t], results: vec![i1] });
                let properties = Some(self.dict(props));
                OpParts { operands, operand_toks, properties, ..self.empty_parts(ty_tok, ty) }
            }
            "arith.select" => {
                let (operands, operand_toks) = self.operand_list()?;
                self.expect(":")?;
                let ty_tok = self.peek();
                let t = self.parse_type()?;
                let i1 = self.m.intern_type(Type::Int { width: 1, signedness: Signedness::Signless });
                let ty = self.m.intern_type(Type::Function { inputs: vec![i1, t, t], results: vec![t] });
                OpParts { operands, operand_toks, ..self.empty_parts(ty_tok, ty) }
            }
            _ if ARITH_CASTS.contains(&name.0) => {
                // `arith.extsi %x : i8 to i32`
                let (operands, operand_toks) = self.operand_list()?;
                self.expect(":")?;
                let ty_tok = self.peek();
                let from = self.parse_type()?;
                self.expect("to")?;
                let to = self.parse_type()?;
                let ty = self.m.intern_type(Type::Function { inputs: vec![from], results: vec![to] });
                OpParts { operands, operand_toks, ..self.empty_parts(ty_tok, ty) }
            }
            _ if name.0.starts_with("arith.") => {
                // `arith.addf %a, %b : f32`, with `fastmath<...>` or
                // `overflow<...>` before the type.
                let (operands, operand_toks) = self.operand_list()?;
                let flag = if self.peek().0 == "fastmath" || self.peek().0 == "overflow" {
                    let word = self.next();
                    let body = self.raw_body()?;
                    Some((word.0, body))
                } else {
                    None
                };
                self.expect(":")?;
                let ty_tok = self.peek();
                let t = self.parse_type()?;
                let props = if ARITH_FASTMATH.contains(&name.0) {
                    let body = flag.filter(|f| f.0 == "fastmath").map_or("<none>".to_string(), |f| f.1);
                    let a = self.m.intern_attr(Attr::Dialect { name: "arith.fastmath".into(), body: Some(body) });
                    Some(self.dict(vec![("fastmath", a)]))
                } else if ARITH_OVERFLOW.contains(&name.0) {
                    let body = flag.filter(|f| f.0 == "overflow").map_or("<none>".to_string(), |f| f.1);
                    let a = self.m.intern_attr(Attr::Dialect { name: "arith.overflow".into(), body: Some(body) });
                    Some(self.dict(vec![("overflowFlags", a)]))
                } else {
                    None
                };
                let ty = self.m.intern_type(Type::Function { inputs: vec![t; operands.len()], results: vec![t] });
                OpParts { operands, operand_toks, properties: props, ..self.empty_parts(ty_tok, ty) }
            }
            "linalg.yield" | "scf.yield" | "tensor.yield" => {
                // `linalg.yield %a, %b : f32, f32`
                let (operands, operand_toks) = self.operand_list()?;
                let inputs = if operands.is_empty() {
                    Vec::new()
                } else {
                    self.expect(":")?;
                    self.bare_type_list()?
                };
                let ty = self.m.intern_type(Type::Function { inputs, results: Vec::new() });
                OpParts { operands, operand_toks, ..self.empty_parts(name, ty) }
            }
            _ => {
                return Err(self.error_at(
                    name,
                    format!(
                        "the custom form of '{}' is not supported yet; print the input in the generic form \
                         (mlir-opt --mlir-print-op-generic)",
                        name.0
                    ),
                ));
            }
        };
        Ok((self.m.intern_name(name.0), parts))
    }

    fn empty_parts(&self, ty_tok: Token<'a>, ty: TypeId) -> OpParts<'a> {
        OpParts {
            operands: Vec::new(),
            operand_toks: Vec::new(),
            successors: Vec::new(),
            properties: None,
            regions: Vec::new(),
            attrs: None,
            ty,
            ty_tok,
        }
    }

    /// An operation with no operands and one result of type `result`.
    fn no_operands(&mut self, tok: Token<'a>, properties: Option<AttrId>, result: TypeId) -> OpParts<'a> {
        let ty = self.m.intern_type(Type::Function { inputs: Vec::new(), results: vec![result] });
        OpParts { properties, ..self.empty_parts(tok, ty) }
    }

    fn dialect_type(&mut self, name: &str) -> TypeId {
        self.m.intern_type(Type::Dialect { name: name.to_string(), body: None })
    }

    /// A dictionary of these entries, which must be in order of name, as
    /// MLIR keeps them.
    fn dict(&mut self, entries: Vec<(&str, AttrId)>) -> AttrId {
        debug_assert!(entries.windows(2).all(|w| w[0].0 < w[1].0));
        let entries = entries.into_iter().map(|(k, v)| (k.to_string(), v)).collect();
        self.m.intern_attr(Attr::Dict(entries))
    }

    /// `%a, %b`, possibly none, up to a `:` or `{`.
    fn operand_list(&mut self) -> Result<(Vec<ValueId>, Vec<Token<'a>>)> {
        let mut operands = Vec::new();
        let mut toks = Vec::new();
        if !self.peek().is_value() {
            return Ok((operands, toks));
        }
        loop {
            toks.push(self.peek());
            operands.push(self.value_use()?);
            if !self.eat(",") {
                return Ok((operands, toks));
            }
        }
    }

    /// `T1, T2`, possibly none, up to a `->` or the end of the operation.
    fn bare_type_list(&mut self) -> Result<Vec<TypeId>> {
        let mut list = Vec::new();
        let t = self.peek();
        if t.0 == "->" || t.is_eof() || t.0 == "}" || t.0 == "loc" {
            return Ok(list);
        }
        loop {
            list.push(self.parse_type()?);
            if !self.eat(",") {
                return Ok(list);
            }
        }
    }

    /// An integer or float, possibly negative, kept as written: the value
    /// of `torch.constant.int` and `torch.constant.float`.
    fn parse_signed_number(&mut self) -> Result<AttrId> {
        let tok = self.peek();
        if tok.0 != "-" && !tok.is_number() {
            return Err(self.error_here("expected a number"));
        }
        self.parse_attr()
    }

    /// `module [@name] [attributes {...}] { ... }`
    fn parse_module(&mut self, op: OpId, name: Token<'a>) -> Result<OpParts<'a>> {
        let mut properties = None;
        if self.peek().is_symbol() {
            let sym = self.next();
            let value = self.m.intern_attr(Attr::String { bytes: sym.name().into_bytes(), ty: None });
            properties = Some(self.dict(vec![("sym_name", value)]));
        }
        let attrs = if self.eat("attributes") { Some(self.parse_dict()?) } else { None };
        let region = self.parse_region(op, Some(Vec::new()))?;
        let ty = self.m.intern_type(Type::Function { inputs: Vec::new(), results: Vec::new() });
        Ok(OpParts { properties, regions: vec![region], attrs, ..self.empty_parts(name, ty) })
    }

    /// `func.func [private] @name(%arg0: T {attrs}, ...) -> (R {attrs}, ...)
    /// [attributes {...}] [{ body }]`. A declaration has no body, and its
    /// arguments no names.
    fn parse_func(&mut self, op: OpId, name: Token<'a>) -> Result<OpParts<'a>> {
        let mut visibility = None;
        if matches!(self.peek().0, "private" | "public" | "nested") {
            let v = self.next();
            visibility = Some(self.m.intern_attr(Attr::String { bytes: v.0.as_bytes().to_vec(), ty: None }));
        }
        let sym = self.next();
        if !sym.is_symbol() {
            return Err(self.error_at(sym, "expected the function's name, such as '@f'"));
        }

        // Arguments: named in a definition, types only in a declaration.
        self.expect("(")?;
        let mut args: Vec<EntryArg<'a>> = Vec::new();
        let mut inputs = Vec::new();
        let mut arg_attrs = Vec::new();
        if !self.eat(")") {
            loop {
                let tok = self.peek();
                if tok.is_value() {
                    self.next();
                    self.expect(":")?;
                }
                let ty = self.parse_type()?;
                let attrs = if self.peek().0 == "{" { Some(self.parse_dict()?) } else { None };
                let loc = if self.peek().0 == "loc" { Some(self.parse_loc()?) } else { None };
                if tok.is_value() {
                    args.push((tok, ty, loc));
                }
                inputs.push(ty);
                arg_attrs.push(attrs);
                if self.eat(")") {
                    break;
                }
                self.expect(",")?;
            }
        }
        if !args.is_empty() && args.len() != inputs.len() {
            return Err(self.error_at(sym, "either every argument is named or none is"));
        }

        // Results.
        let mut results = Vec::new();
        let mut res_attrs = Vec::new();
        if self.eat("->") {
            if self.eat("(") {
                if !self.eat(")") {
                    loop {
                        results.push(self.parse_type()?);
                        res_attrs.push(if self.peek().0 == "{" { Some(self.parse_dict()?) } else { None });
                        if self.eat(")") {
                            break;
                        }
                        self.expect(",")?;
                    }
                }
            } else {
                // A result's attributes need the parentheses: a `{` here
                // starts the body.
                results.push(self.parse_type()?);
                res_attrs.push(None);
            }
        }
        let attrs = if self.eat("attributes") { Some(self.parse_dict()?) } else { None };

        let regions = if self.peek().0 == "{" {
            if args.len() != inputs.len() {
                return Err(self.error_at(sym, "a function with a body names its arguments"));
            }
            vec![self.parse_region(op, Some(args))?]
        } else {
            let region = RegionId(self.m.regions.len() as u32);
            self.m.regions.push(Region { blocks: Vec::new(), parent: Some(op) });
            vec![region]
        };

        let function_type = self.m.intern_type(Type::Function { inputs, results });
        let mut props = Vec::new();
        if arg_attrs.iter().any(Option::is_some) {
            props.push(("arg_attrs", self.attr_list(arg_attrs)));
        }
        props.push(("function_type", self.m.intern_attr(Attr::Type(function_type))));
        if res_attrs.iter().any(Option::is_some) {
            props.push(("res_attrs", self.attr_list(res_attrs)));
        }
        props.push(("sym_name", self.m.intern_attr(Attr::String { bytes: sym.name().into_bytes(), ty: None })));
        if let Some(v) = visibility {
            props.push(("sym_visibility", v));
        }
        let properties = Some(self.dict(props));
        let ty = self.m.intern_type(Type::Function { inputs: Vec::new(), results: Vec::new() });
        Ok(OpParts { properties, regions, attrs, ..self.empty_parts(name, ty) })
    }

    /// An array of dictionaries, empty ones for those not given.
    fn attr_list(&mut self, list: Vec<Option<AttrId>>) -> AttrId {
        let empty = self.m.intern_attr(Attr::Dict(Vec::new()));
        let elems = list.into_iter().map(|a| a.unwrap_or(empty)).collect();
        self.m.intern_attr(Attr::Array(elems))
    }

    /// `return %a, %b : T1, T2`, or `return`.
    fn parse_return(&mut self, name: Token<'a>) -> Result<OpParts<'a>> {
        let (operands, operand_toks) = self.operand_list()?;
        let inputs = if operands.is_empty() {
            Vec::new()
        } else {
            self.expect(":")?;
            self.bare_type_list()?
        };
        let ty = self.m.intern_type(Type::Function { inputs, results: Vec::new() });
        Ok(OpParts { operands, operand_toks, ..self.empty_parts(name, ty) })
    }

    /// `torch.constant.int 3`: a `value` property, written with the type
    /// `value_ty` if one is given, and a result of type `!result`.
    fn parse_constant(
        &mut self,
        name: Token<'a>,
        value: impl FnOnce(&mut Self) -> Result<AttrId>,
        value_ty: &str,
        result: &str,
    ) -> Result<OpParts<'a>> {
        let mut v = value(self)?;
        if !value_ty.is_empty() {
            let t = match value_ty {
                "i64" => Type::Int { width: 64, signedness: Signedness::Signless },
                _ => Type::Float("f64"),
            };
            let t = self.m.intern_type(t);
            v = match self.m.attr(v).clone() {
                Attr::Int { text, ty: None } => self.m.intern_attr(Attr::Int { text, ty: Some(t) }),
                Attr::Float { text, ty: None } => self.m.intern_attr(Attr::Float { text, ty: Some(t) }),
                _ => v,
            };
        }
        let props = self.dict(vec![("value", v)]);
        let result = self.dialect_type(result);
        Ok(self.no_operands(name, Some(props), result))
    }

    /// The form most `torch` operations share:
    /// `%r = torch.aten.add.Tensor %a, %b, %c {attrs} : T1, T2, T3 -> R`,
    /// with `-> (R1, R2)` for several results.
    fn parse_torch_op(&mut self) -> Result<OpParts<'a>> {
        let (operands, operand_toks) = self.operand_list()?;
        let attrs = if self.peek().0 == "{" { Some(self.parse_dict()?) } else { None };
        self.expect(":")?;
        let ty_tok = self.peek();
        let inputs = self.bare_type_list()?;
        let results = if self.eat("->") {
            if self.peek().0 == "(" { self.parse_type_list()? } else { vec![self.parse_type()?] }
        } else {
            Vec::new()
        };
        let ty = self.m.intern_type(Type::Function { inputs, results });
        Ok(OpParts { operands, operand_toks, attrs, ..self.empty_parts(ty_tok, ty) })
    }
}

#[cfg(test)]
mod tests {
    use crate::parse_module;

    #[test]
    fn torch_function() {
        let src = r#"module {
  func.func @f(%arg0: !torch.vtensor<[2,3],f32>, %arg1: !torch.vtensor<[3],f32>) -> !torch.vtensor<[2,3],f32> {
    %int1 = torch.constant.int 1
    %float = torch.constant.float -5.000000e-01
    %none = torch.constant.none
    %0 = torch.prim.ListConstruct %int1, %int1 : (!torch.int, !torch.int) -> !torch.list<int>
    %1 = torch.aten.add.Tensor %arg0, %arg1, %int1 : !torch.vtensor<[2,3],f32>, !torch.vtensor<[3],f32>, !torch.int -> !torch.vtensor<[2,3],f32>
    return %1 : !torch.vtensor<[2,3],f32>
  }
}
"#;
        let m = parse_module(src).unwrap();
        let printed = m.to_string();
        assert!(printed.starts_with(
            "\"builtin.module\"() ({\n  \"func.func\"() <{function_type = (!torch.vtensor<[2,3],f32>, \
             !torch.vtensor<[3],f32>) -> !torch.vtensor<[2,3],f32>, sym_name = \"f\"}> ({\n  ^bb0(%arg0: "
        ));
        assert!(printed.contains("%int1 = \"torch.constant.int\"() <{value = 1 : i64}> : () -> !torch.int"));
        assert!(
            printed
                .contains("%float = \"torch.constant.float\"() <{value = -5.000000e-01 : f64}> : () -> !torch.float")
        );
        assert!(printed.contains("%none = \"torch.constant.none\"() : () -> !torch.none"));
        assert!(printed.contains("\"func.return\"(%1) : (!torch.vtensor<[2,3],f32>) -> ()"));
        assert_eq!(parse_module(&printed).unwrap().to_string(), printed);
    }

    #[test]
    fn arith() {
        let src = r#"%c = arith.constant 0.000000e+00 : f32
%t = arith.constant true
%a = arith.addf %c, %c : f32
%f = arith.mulf %a, %a fastmath<fast> : f32
%i = arith.constant 3 : i32
%j = arith.addi %i, %i overflow<nsw> : i32
%k = arith.extsi %j : i32 to i64
%p = arith.cmpf ugt, %a, %c : f32
%q = arith.cmpi sge, %i, %j : i32
%s = arith.select %p, %a, %f : f32
linalg.yield %s : f32
"#;
        let printed = parse_module(src).unwrap().to_string();
        let want = r#"%c = "arith.constant"() <{value = 0.000000e+00 : f32}> : () -> f32
%t = "arith.constant"() <{value = true}> : () -> i1
%a = "arith.addf"(%c, %c) <{fastmath = #arith.fastmath<none>}> : (f32, f32) -> f32
%f = "arith.mulf"(%a, %a) <{fastmath = #arith.fastmath<fast>}> : (f32, f32) -> f32
%i = "arith.constant"() <{value = 3 : i32}> : () -> i32
%j = "arith.addi"(%i, %i) <{overflowFlags = #arith.overflow<nsw>}> : (i32, i32) -> i32
%k = "arith.extsi"(%j) : (i32) -> i64
%p = "arith.cmpf"(%a, %c) <{fastmath = #arith.fastmath<none>, predicate = 9 : i64}> : (f32, f32) -> i1
%q = "arith.cmpi"(%i, %j) <{predicate = 5 : i64}> : (i32, i32) -> i1
%s = "arith.select"(%p, %a, %f) : (i1, f32, f32) -> f32
"linalg.yield"(%s) : (f32) -> ()
"#;
        assert_eq!(printed, want);
    }

    #[test]
    fn declarations() {
        let src = "module {\n  func.func private @g(i32 {llvm.noundef}, f32) -> i8\n}\n";
        let printed = parse_module(src).unwrap().to_string();
        assert!(printed.contains(
            "<{arg_attrs = [{llvm.noundef}, {}], function_type = (i32, f32) -> i8, sym_name = \"g\", \
             sym_visibility = \"private\"}> ({\n  })"
        ));
    }
}
