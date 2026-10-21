//! Building MLIR in code: operations, regions and blocks added to a
//! module, and the common types and attributes.
//!
//! A pass builds its output as new operations rather than changing its
//! input in place. Each new operation goes at the end of a block, as
//! `epitome_ir::build`'s instructions do.
//!
//! ```
//! use epitome_mlir::build::OpSpec;
//! use epitome_mlir::Module;
//!
//! let mut m = Module::default();
//! let f32t = m.float_type("f32");
//! let zero = m.float_attr("0.000000e+00", f32t);
//! let c = OpSpec::new("arith.constant").results(&[f32t]).prop("value", zero).build(&mut m, None);
//! assert_eq!(m.to_string(), "%0 = \"arith.constant\"() <{value = 0.000000e+00 : f32}> : () -> f32\n");
//! # let _ = c;
//! ```

use crate::ir::*;

/// An operation to add, its parts given one by one.
#[derive(Clone, Debug, Default)]
pub struct OpSpec {
    name: String,
    operands: Vec<ValueId>,
    results: Vec<TypeId>,
    successors: Vec<BlockId>,
    props: Vec<(String, AttrId)>,
    attrs: Vec<(String, AttrId)>,
    regions: usize,
    loc: Option<AttrId>,
}

impl OpSpec {
    pub fn new(name: &str) -> Self {
        OpSpec { name: name.to_string(), ..Default::default() }
    }

    pub fn operands(mut self, values: &[ValueId]) -> Self {
        self.operands.extend_from_slice(values);
        self
    }

    pub fn results(mut self, types: &[TypeId]) -> Self {
        self.results.extend_from_slice(types);
        self
    }

    pub fn successors(mut self, blocks: &[BlockId]) -> Self {
        self.successors.extend_from_slice(blocks);
        self
    }

    /// A property, `<{name = value}>`. Properties print in order of name,
    /// as MLIR keeps them.
    pub fn prop(mut self, name: &str, value: AttrId) -> Self {
        self.props.push((name.to_string(), value));
        self
    }

    /// An attribute, `{name = value}`.
    pub fn attr(mut self, name: &str, value: AttrId) -> Self {
        self.attrs.push((name.to_string(), value));
        self
    }

    /// `n` empty regions, filled with `Module::add_block`.
    pub fn regions(mut self, n: usize) -> Self {
        self.regions = n;
        self
    }

    pub fn loc(mut self, loc: Option<AttrId>) -> Self {
        self.loc = loc;
        self
    }

    /// Adds the operation at the end of `block`, or at the top level.
    pub fn build(mut self, m: &mut Module, block: Option<BlockId>) -> OpId {
        let name = m.intern_name(&self.name);
        let ty = m.intern_type(Type::Function {
            inputs: self.operands.iter().map(|&v| m.values[v.index()].ty).collect(),
            results: self.results.clone(),
        });
        self.props.sort_by(|a, b| a.0.cmp(&b.0));
        let properties = (!self.props.is_empty()).then(|| m.intern_attr(Attr::Dict(self.props)));
        let attrs = (!self.attrs.is_empty()).then(|| m.intern_attr(Attr::Dict(self.attrs)));
        let op = OpId(m.ops.len() as u32);
        m.ops.push(Operation {
            name,
            operands: self.operands,
            results: Vec::new(),
            successors: self.successors,
            properties,
            regions: Vec::new(),
            attrs,
            ty,
            loc: self.loc,
            parent: block,
        });
        let results = self
            .results
            .iter()
            .enumerate()
            .map(|(index, &ty)| m.new_value(ty, ValueDef::Result { op, index: index as u32 }))
            .collect();
        m.ops[op.index()].results = results;
        for _ in 0..self.regions {
            let r = RegionId(m.regions.len() as u32);
            m.regions.push(Region { blocks: Vec::new(), parent: Some(op) });
            m.ops[op.index()].regions.push(r);
        }
        match block {
            Some(b) => m.blocks[b.index()].ops.push(op),
            // At the top level, before the resources, which end a file.
            None => {
                let at = m.items.iter().position(|i| matches!(i, Item::Resources(_))).unwrap_or(m.items.len());
                m.items.insert(at, Item::Op(op));
            }
        }
        op
    }
}

impl Module {
    /// A new value with no name; the printer numbers it.
    pub fn new_value(&mut self, ty: TypeId, def: ValueDef) -> ValueId {
        let v = ValueId(self.values.len() as u32);
        self.values.push(Value { name: None, group_index: None, ty, def, loc: None });
        v
    }

    /// A new block at the end of `region`, with arguments of these types.
    pub fn add_block(&mut self, region: RegionId, args: &[TypeId]) -> BlockId {
        let b = BlockId(self.blocks.len() as u32);
        self.blocks.push(Block { name: None, args: Vec::new(), ops: Vec::new(), parent: region });
        self.regions[region.index()].blocks.push(b);
        for (index, &ty) in args.iter().enumerate() {
            let v = self.new_value(ty, ValueDef::BlockArg { block: b, index: index as u32 });
            self.blocks[b.index()].args.push(v);
        }
        b
    }

    /// Operation `op`'s region `k`.
    pub fn region_of(&self, op: OpId, k: usize) -> RegionId {
        self.ops[op.index()].regions[k]
    }

    /// The single result of `op`.
    pub fn result(&self, op: OpId) -> ValueId {
        self.ops[op.index()].results[0]
    }

    pub fn value_type(&self, v: ValueId) -> TypeId {
        self.values[v.index()].ty
    }

    // Types ------------------------------------------------------------------

    pub fn int_type(&mut self, width: u32) -> TypeId {
        self.intern_type(Type::Int { width, signedness: Signedness::Signless })
    }

    pub fn index_type(&mut self) -> TypeId {
        self.intern_type(Type::Index)
    }

    /// A float type by its keyword, `f32`; the keyword must be one of
    /// `FLOAT_TYPES`.
    pub fn float_type(&mut self, name: &str) -> TypeId {
        let k = FLOAT_TYPES.iter().find(|&&f| f == name).expect("a float type keyword");
        self.intern_type(Type::Float(k))
    }

    pub fn function_type(&mut self, inputs: &[TypeId], results: &[TypeId]) -> TypeId {
        self.intern_type(Type::Function { inputs: inputs.to_vec(), results: results.to_vec() })
    }

    pub fn tensor_type(&mut self, shape: &[u64], elem: TypeId) -> TypeId {
        self.intern_type(Type::Tensor { shape: Some(shape.iter().map(|&d| Some(d)).collect()), elem, encoding: None })
    }

    /// `memref<...>`, with a layout attribute if not the identity.
    pub fn memref_type(&mut self, shape: &[u64], elem: TypeId, layout: Option<AttrId>) -> TypeId {
        let shape = Some(shape.iter().map(|&d| Some(d)).collect());
        self.intern_type(Type::MemRef { shape, elem, extra: layout.into_iter().collect() })
    }

    /// A dialect type such as `!llvm.ptr`.
    pub fn dialect_type(&mut self, name: &str, body: Option<&str>) -> TypeId {
        self.intern_type(Type::Dialect { name: name.to_string(), body: body.map(str::to_string) })
    }

    /// The static shape and element type of a ranked tensor or memref.
    pub fn shaped(&self, ty: TypeId) -> Option<(Vec<u64>, TypeId)> {
        let (shape, elem) = match self.ty(self.resolve_type(ty)) {
            Type::Tensor { shape: Some(s), elem, .. } | Type::MemRef { shape: Some(s), elem, .. } => (s, *elem),
            _ => return None,
        };
        Some((shape.iter().map(|d| d.ok_or(())).collect::<Result<_, _>>().ok()?, elem))
    }

    // Attributes ---------------------------------------------------------------

    pub fn int_attr(&mut self, value: i64, ty: TypeId) -> AttrId {
        self.intern_attr(Attr::Int { text: value.to_string(), ty: Some(ty) })
    }

    /// A float as MLIR prints it, `1.000000e+00`.
    pub fn float_attr(&mut self, text: &str, ty: TypeId) -> AttrId {
        self.intern_attr(Attr::Float { text: text.to_string(), ty: Some(ty) })
    }

    pub fn string_attr(&mut self, s: &str) -> AttrId {
        self.intern_attr(Attr::String { bytes: s.as_bytes().to_vec(), ty: None })
    }

    pub fn type_attr(&mut self, ty: TypeId) -> AttrId {
        self.intern_attr(Attr::Type(ty))
    }

    pub fn unit_attr(&mut self) -> AttrId {
        self.intern_attr(Attr::Unit)
    }

    pub fn bool_attr(&mut self, b: bool) -> AttrId {
        self.intern_attr(Attr::Bool(b))
    }

    pub fn array_attr(&mut self, elems: Vec<AttrId>) -> AttrId {
        self.intern_attr(Attr::Array(elems))
    }

    pub fn symbol_attr(&mut self, name: &str) -> AttrId {
        self.intern_attr(Attr::SymbolRef(vec![name.to_string()]))
    }

    /// `array<i64: 1, 2>` and its kin.
    pub fn dense_array_attr(&mut self, elem: &str, values: &[i64]) -> AttrId {
        let list: Vec<String> = values.iter().map(|v| v.to_string()).collect();
        let body = if list.is_empty() { format!("<{elem}>") } else { format!("<{elem}: {}>", list.join(", ")) };
        self.intern_attr(Attr::Builtin { keyword: "array", body, ty: None })
    }

    /// `affine_map<...>`, from the text between the brackets.
    pub fn affine_map_attr(&mut self, map: &str) -> AttrId {
        self.intern_attr(Attr::Builtin { keyword: "affine_map", body: format!("<{map}>"), ty: None })
    }

    /// A dialect attribute, `#name<body>`.
    pub fn dialect_attr(&mut self, name: &str, body: Option<&str>) -> AttrId {
        self.intern_attr(Attr::Dialect { name: name.to_string(), body: body.map(str::to_string) })
    }

    /// The elements of `array<i64: ...>` or a list of integer attributes.
    pub fn int_list(&self, attr: AttrId) -> Option<Vec<i64>> {
        match self.attr(self.resolve_attr(attr)) {
            Attr::Builtin { keyword: "array", body, .. } => {
                let inner = &body[1..body.len() - 1];
                let values = inner.split_once(':').map_or("", |(_, v)| v);
                values.split(',').map(str::trim).filter(|s| !s.is_empty()).map(|s| s.parse().ok()).collect()
            }
            Attr::Array(elems) => elems
                .iter()
                .map(|&e| match self.attr(e) {
                    Attr::Int { text, .. } => text.parse().ok(),
                    _ => None,
                })
                .collect(),
            _ => None,
        }
    }

    /// The text of a string attribute.
    pub fn string_of(&self, attr: AttrId) -> Option<String> {
        match self.attr(self.resolve_attr(attr)) {
            Attr::String { bytes, .. } => Some(String::from_utf8_lossy(bytes).into_owned()),
            _ => None,
        }
    }

    /// The value of an integer attribute.
    pub fn int_of(&self, attr: AttrId) -> Option<i64> {
        match self.attr(self.resolve_attr(attr)) {
            Attr::Int { text, .. } => text.parse().ok(),
            Attr::Bool(b) => Some(*b as i64),
            _ => None,
        }
    }

    /// A module with this one's interned types, attributes and names, its
    /// aliases and resources, and no operations: what a pass builds into.
    pub fn empty_like(&self) -> Module {
        let mut m = self.clone();
        m.ops.clear();
        m.blocks.clear();
        m.regions.clear();
        m.values.clear();
        m.items.retain(|i| !matches!(i, Item::Op(_)));
        m
    }
}

impl Module {
    /// Type `ty` of module `from`, interned in this one. A type for which
    /// `subst` gives a replacement becomes that replacement, wherever it
    /// appears.
    pub fn import_type(&mut self, from: &Module, ty: TypeId, subst: &dyn Fn(TypeId) -> Option<TypeId>) -> TypeId {
        if let Some(t) = subst(ty) {
            return t;
        }
        let t = match from.ty(ty).clone() {
            Type::Complex(e) => Type::Complex(self.import_type(from, e, subst)),
            Type::Tuple(es) => Type::Tuple(es.iter().map(|&e| self.import_type(from, e, subst)).collect()),
            Type::Vector { dims, elem } => Type::Vector { dims, elem: self.import_type(from, elem, subst) },
            Type::Tensor { shape, elem, encoding } => Type::Tensor {
                shape,
                elem: self.import_type(from, elem, subst),
                encoding: encoding.map(|a| self.import_attr(from, a, subst)),
            },
            Type::MemRef { shape, elem, extra } => Type::MemRef {
                shape,
                elem: self.import_type(from, elem, subst),
                extra: extra.iter().map(|&a| self.import_attr(from, a, subst)).collect(),
            },
            Type::Function { inputs, results } => Type::Function {
                inputs: inputs.iter().map(|&t| self.import_type(from, t, subst)).collect(),
                results: results.iter().map(|&t| self.import_type(from, t, subst)).collect(),
            },
            other => other,
        };
        self.intern_type(t)
    }

    /// Attribute `attr` of module `from`, interned in this one, its types
    /// replaced by `subst` as in `import_type`.
    pub fn import_attr(&mut self, from: &Module, attr: AttrId, subst: &dyn Fn(TypeId) -> Option<TypeId>) -> AttrId {
        let ty = |m: &mut Module, t: Option<TypeId>| t.map(|t| m.import_type(from, t, subst));
        let a = match from.attr(attr).clone() {
            Attr::Int { text, ty: t } => Attr::Int { text, ty: ty(self, t) },
            Attr::Float { text, ty: t } => Attr::Float { text, ty: ty(self, t) },
            Attr::String { bytes, ty: t } => Attr::String { bytes, ty: ty(self, t) },
            Attr::Builtin { keyword, body, ty: t } => Attr::Builtin { keyword, body, ty: ty(self, t) },
            Attr::Type(t) => Attr::Type(self.import_type(from, t, subst)),
            Attr::Array(es) => Attr::Array(es.iter().map(|&e| self.import_attr(from, e, subst)).collect()),
            Attr::Dict(es) => {
                Attr::Dict(es.iter().map(|(k, v)| (k.clone(), self.import_attr(from, *v, subst))).collect())
            }
            Attr::Loc(l) => Attr::Loc(match l {
                Loc::Name { name, child } => Loc::Name { name, child: child.map(|c| self.import_attr(from, c, subst)) },
                Loc::CallSite { callee, caller } => Loc::CallSite {
                    callee: self.import_attr(from, callee, subst),
                    caller: self.import_attr(from, caller, subst),
                },
                Loc::Fused { metadata, locs } => Loc::Fused {
                    metadata: metadata.map(|a| self.import_attr(from, a, subst)),
                    locs: locs.iter().map(|&a| self.import_attr(from, a, subst)).collect(),
                },
                other => other,
            }),
            other => other,
        };
        self.intern_attr(a)
    }
}

/// The strides of a packed, row-major array of `shape`.
pub fn row_major_strides(shape: &[u64]) -> Vec<u64> {
    let mut s = vec![1; shape.len()];
    for d in (0..shape.len().saturating_sub(1)).rev() {
        s[d] = s[d + 1] * shape[d + 1];
    }
    s
}

/// The strides and offset of a `memref` type with a `strided<...>`
/// layout; `None` for one without (packed and row-major).
pub fn strided_layout(m: &Module, ty: TypeId) -> Option<(Vec<u64>, u64)> {
    let Type::MemRef { extra, .. } = m.ty(m.resolve_type(ty)) else { return None };
    for &a in extra {
        if let Attr::Builtin { keyword: "strided", body, .. } = m.attr(m.resolve_attr(a)) {
            let inner = &body[1..body.len() - 1];
            let (list, rest) = inner.split_once(']')?;
            let strides =
                list.trim_start_matches('[').split(',').map(|s| s.trim().parse().ok()).collect::<Option<_>>()?;
            let offset = rest.split_once("offset:").map_or(Some(0), |(_, o)| o.trim().parse().ok())?;
            return Some((strides, offset));
        }
    }
    None
}

/// `strided<[strides], offset: n>`
pub fn strided_attr(m: &mut Module, strides: &[u64], offset: u64) -> AttrId {
    let list: Vec<String> = strides.iter().map(|s| s.to_string()).collect();
    m.intern_attr(Attr::Builtin {
        keyword: "strided",
        body: format!("<[{}], offset: {offset}>", list.join(", ")),
        ty: None,
    })
}

/// A float as MLIR prints one, `1.000000e+00`.
pub fn float_text(f: f64) -> String {
    let s = format!("{f:.6e}");
    match s.split_once('e') {
        Some((mantissa, exp)) => {
            let e: i32 = exp.parse().unwrap_or(0);
            format!("{mantissa}e{}{:02}", if e < 0 { '-' } else { '+' }, e.abs())
        }
        None => s,
    }
}

impl Module {
    /// A copy of operation `op` of module `from`, whose types and attributes
    /// this module shares (it was made by `from.empty_like()`), at the end
    /// of `block`, with its regions. `map` takes `from`'s values to this
    /// module's: operands are looked up in it, and results and block
    /// arguments added. An operand not in `map` is an error.
    pub fn clone_op(
        &mut self,
        from: &Module,
        op: OpId,
        block: Option<BlockId>,
        map: &mut std::collections::HashMap<ValueId, ValueId>,
    ) -> Result<OpId, String> {
        let o = &from.ops[op.index()];
        let operands = o
            .operands
            .iter()
            .map(|v| map.get(v).copied().ok_or_else(|| format!("{}: an operand from outside", from.op_name(op))))
            .collect::<Result<Vec<_>, _>>()?;
        let results: Vec<TypeId> = o.results.iter().map(|&r| from.value_type(r)).collect();
        let mut spec = OpSpec::new(from.op_name(op)).operands(&operands).results(&results).loc(o.loc);
        if let Some(Attr::Dict(es)) = o.properties.map(|p| from.attr(p)) {
            for (k, v) in es {
                spec = spec.prop(k, *v);
            }
        }
        if let Some(Attr::Dict(es)) = o.attrs.map(|a| from.attr(a)) {
            for (k, v) in es {
                spec = spec.attr(k, *v);
            }
        }
        spec = spec.regions(o.regions.len());
        let new = spec.build(self, block);
        for (&old, &n) in o.results.iter().zip(&self.ops[new.index()].results.clone()) {
            map.insert(old, n);
        }
        for (k, &r) in o.regions.iter().enumerate() {
            let region = self.region_of(new, k);
            self.clone_region_into(from, r, region, map)?;
        }
        Ok(new)
    }

    /// The blocks of `from`'s region `r`, copied into this module's empty
    /// region `into`, as `clone_op` copies an operation.
    pub fn clone_region_into(
        &mut self,
        from: &Module,
        r: RegionId,
        into: RegionId,
        map: &mut std::collections::HashMap<ValueId, ValueId>,
    ) -> Result<(), String> {
        let blocks = &from.regions[r.index()].blocks;
        let mut new_blocks = Vec::new();
        for &b in blocks {
            let types: Vec<TypeId> = from.blocks[b.index()].args.iter().map(|&a| from.value_type(a)).collect();
            let nb = self.add_block(into, &types);
            for (&old, &n) in from.blocks[b.index()].args.iter().zip(&self.blocks[nb.index()].args.clone()) {
                map.insert(old, n);
            }
            new_blocks.push(nb);
        }
        for (&b, &nb) in blocks.iter().zip(&new_blocks) {
            for &op in &from.blocks[b.index()].ops {
                let new = self.clone_op(from, op, Some(nb), map)?;
                // Successors are blocks of the same region.
                let succ: Vec<BlockId> = from.ops[op.index()]
                    .successors
                    .iter()
                    .map(|s| new_blocks[blocks.iter().position(|x| x == s).expect("a successor in the region")])
                    .collect();
                self.ops[new.index()].successors = succ;
            }
        }
        Ok(())
    }
}
