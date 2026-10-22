//! `stablehlo` to `linalg` on tensors, for what JAX exports
//! (`jax.jit(f).lower(...).compiler_ir("stablehlo")`): each operation a
//! `linalg.generic` (with `tensor.empty` and `linalg.fill`), a reshape a
//! `tensor.collapse_shape` and `tensor.expand_shape`, and a constant an
//! `arith.constant`, its data a `dense_resource` blob when it is large, as
//! the rest of the pipeline expects weights. Written from the StableHLO
//! specification's definitions of the operations.
//!
//! What each element-wise operation computes is data, in
//! `mlir/dialects/stablehlo.mlir`, as for `torch`. The structural
//! operations are here:
//!
//! - `broadcast_in_dim`: a generic reading the operand through the
//!   dimensions it maps to (a dimension of size 1 that grows reads index
//!   0), or a `linalg.fill` of a scalar constant;
//! - `dot_general`: a generic over the batch, free and contracting
//!   dimensions; operands are transposed first, when needed, so that a
//!   matrix product (or one per batch) has the maps `linalg.matmul` and
//!   `linalg.batch_matmul` have. A constant's transpose is then folded away
//!   by `linalg-fold-constants`, and the SME kernels match the product;
//! - `reduce` of one operand, its body one combining operation, from a
//!   constant initial value;
//! - `transpose`, `reshape`, `convert`, `compare`, `select`, `iota`.
//!
//! Calls to the module's private functions (JAX makes one of `jnp.where`)
//! are inlined, as upstream's `inline` pass would before this, and the
//! private functions dropped. Shapes must be static, as JAX exports them
//! for given input shapes.

use std::collections::HashMap;
use std::sync::{Arc, OnceLock};

use crate::affine::{Expr, Map};
use crate::build::OpSpec;
use crate::ir::*;

const DESCRIPTIONS: &str = include_str!("../dialects/stablehlo.mlir");

/// Constants larger than this many bytes become `dense_resource` blobs.
const BLOB_BYTES: usize = 64;

/// Lowers every function in `src` from `stablehlo` to `linalg` on tensors.
pub fn run(src: &Module) -> Result<Module, String> {
    let d = descriptions()?;
    let mut out = src.empty_like();
    let mut cx = Cx { d, blobs: Vec::new(), made: 0, private: HashMap::new() };
    for top in src.top_ops().collect::<Vec<_>>() {
        if src.op_name(top) != "builtin.module" {
            return Err(format!("{}: expected a builtin.module", src.op_name(top)));
        }
        let o = &src.ops[top.index()];
        let spec = with_dicts(src, OpSpec::new("builtin.module").regions(1).loc(o.loc), o.properties, o.attrs);
        let module = spec.build(&mut out, None);
        let region = out.region_of(module, 0);
        let block = out.add_block(region, &[]);
        cx.private.clear();
        for &r in &o.regions {
            for &b in &src.regions[r.index()].blocks {
                for &op in &src.blocks[b.index()].ops {
                    if src.op_name(op) == "func.func"
                        && src.op_attr(op, "sym_visibility").and_then(|a| src.string_of(a)).as_deref()
                            == Some("private")
                        && let Some(n) = src.op_attr(op, "sym_name").and_then(|a| src.string_of(a))
                    {
                        cx.private.insert(n, op);
                    }
                }
            }
        }
        for &r in &o.regions {
            for &b in &src.regions[r.index()].blocks {
                for &op in &src.blocks[b.index()].ops {
                    if src.op_name(op) == "func.func" {
                        if src.op_attr(op, "sym_visibility").and_then(|a| src.string_of(a)).as_deref()
                            == Some("private")
                        {
                            continue;
                        }
                        lower_func(src, op, &mut out, block, &mut cx)?;
                    } else {
                        out.clone_op(src, op, Some(block), &mut HashMap::new())?;
                    }
                }
            }
        }
    }
    let at = out.items.iter().position(|i| matches!(i, Item::Resources(_))).unwrap_or(out.items.len());
    for (k, b) in cx.blobs.into_iter().enumerate() {
        out.items.insert(at + k, b);
    }
    Ok(out)
}

fn with_dicts(src: &Module, mut spec: OpSpec, props: Option<AttrId>, attrs: Option<AttrId>) -> OpSpec {
    if let Some(Attr::Dict(es)) = props.map(|p| src.attr(p)) {
        for (k, v) in es {
            spec = spec.prop(k, *v);
        }
    }
    if let Some(Attr::Dict(es)) = attrs.map(|a| src.attr(a)) {
        for (k, v) in es {
            spec = spec.attr(k, *v);
        }
    }
    spec
}

// ---------------------------------------------------------------------------
// Descriptions

#[derive(Clone, Copy, PartialEq, Eq, Hash, Debug)]
enum Class {
    Float,
    Int,
}

struct Descriptions {
    m: Module,
    entries: HashMap<(String, Class), OpId>,
}

fn descriptions() -> Result<&'static Descriptions, String> {
    static D: OnceLock<Result<Descriptions, String>> = OnceLock::new();
    D.get_or_init(|| {
        let m = crate::parse_module(DESCRIPTIONS).map_err(|e| format!("dialects/stablehlo.mlir:{e}"))?;
        let mut entries = HashMap::new();
        for op in m.top_ops() {
            let name = m.op_attr(op, "op").and_then(|a| m.string_of(a)).ok_or("an entry without 'op'")?;
            let class = match m.op_attr(op, "element").and_then(|a| m.string_of(a)).as_deref() {
                Some("float") => Class::Float,
                Some("int") => Class::Int,
                _ => return Err(format!("{name}: 'element' must be \"float\" or \"int\"")),
            };
            entries.insert((name, class), op);
        }
        Ok(Descriptions { m, entries })
    })
    .as_ref()
    .map_err(Clone::clone)
}

/// What the pass carries from one function to the next.
struct Cx {
    d: &'static Descriptions,
    blobs: Vec<Item>,
    made: usize,
    /// The module's private functions, inlined where they are called.
    private: HashMap<String, OpId>,
}

// ---------------------------------------------------------------------------
// Functions

fn lower_func(src: &Module, f: OpId, out: &mut Module, parent: BlockId, cx: &mut Cx) -> Result<(), String> {
    let o = &src.ops[f.index()];
    let name = src.op_attr(f, "sym_name").and_then(|a| src.string_of(a)).unwrap_or_default();
    let spec = with_dicts(src, OpSpec::new("func.func").regions(o.regions.len()).loc(o.loc), o.properties, o.attrs);
    let new = spec.build(out, Some(parent));
    let Some(&r) = o.regions.first() else { return Ok(()) };
    let blocks = &src.regions[r.index()].blocks;
    let [body] = blocks[..] else {
        return if blocks.is_empty() { Ok(()) } else { Err(format!("@{name}: more than one block")) };
    };
    let region = out.region_of(new, 0);
    let types: Vec<TypeId> = src.blocks[body.index()].args.iter().map(|&a| src.value_type(a)).collect();
    let b = out.add_block(region, &types);
    let mut l = Lower { src, out, block: b, map: HashMap::new(), scalars: HashMap::new(), cx };
    for (&a, &n) in src.blocks[body.index()].args.iter().zip(&l.out.blocks[b.index()].args.clone()) {
        l.map.insert(a, n);
    }
    for &op in &src.blocks[body.index()].ops {
        l.op(op).map_err(|e| format!("@{name}: {}: {e}", src.op_name(op)))?;
    }
    Ok(())
}

/// A tensor value in the output: the value, its shape and element type.
#[derive(Clone)]
struct T {
    v: ValueId,
    shape: Vec<u64>,
    elem: TypeId,
}

struct Lower<'a> {
    src: &'a Module,
    out: &'a mut Module,
    block: BlockId,
    map: HashMap<ValueId, ValueId>,
    /// Zero-dimensional constants, as the scalar attribute of their value:
    /// a broadcast of one is a fill, a reduction's initial value is one.
    scalars: HashMap<ValueId, AttrId>,
    cx: &'a mut Cx,
}

impl Lower<'_> {
    fn add(&mut self, spec: OpSpec) -> OpId {
        spec.build(self.out, Some(self.block))
    }

    fn operand(&self, v: ValueId) -> Result<T, String> {
        let n = *self.map.get(&v).ok_or("an operand from outside")?;
        let (shape, elem) = self.out.shaped(self.out.value_type(n)).ok_or("an operand that is not a tensor")?;
        Ok(T { v: n, shape, elem })
    }

    fn class(&self, elem: TypeId) -> Result<Class, String> {
        match self.out.ty(elem) {
            Type::Float(_) => Ok(Class::Float),
            Type::Int { .. } => Ok(Class::Int),
            _ => Err(format!("elements of type {} are not supported", crate::printer::type_text(self.out, elem))),
        }
    }

    fn bits(&self, elem: TypeId) -> u32 {
        match self.out.ty(elem) {
            Type::Int { width, .. } => *width,
            Type::Float(f) => match *f {
                "f64" => 64,
                "f16" | "bf16" => 16,
                _ => 32,
            },
            _ => 0,
        }
    }

    fn empty(&mut self, shape: &[u64], elem: TypeId) -> ValueId {
        let ty = self.out.tensor_type(shape, elem);
        let e = self.add(OpSpec::new("tensor.empty").results(&[ty]));
        self.out.result(e)
    }

    fn scalar(&mut self, attr: AttrId, elem: TypeId) -> ValueId {
        let c = self.add(OpSpec::new("arith.constant").results(&[elem]).prop("value", attr));
        self.out.result(c)
    }

    fn zero(&mut self, elem: TypeId) -> Result<ValueId, String> {
        let a = match self.class(elem)? {
            Class::Float => self.out.float_attr("0.000000e+00", elem),
            Class::Int => self.out.int_attr(0, elem),
        };
        Ok(self.scalar(a, elem))
    }

    fn fill(&mut self, value: ValueId, shape: &[u64], elem: TypeId) -> ValueId {
        let e = self.empty(shape, elem);
        let ty = self.out.tensor_type(shape, elem);
        let segments = self.out.dense_array_attr("i32", &[1, 1]);
        let f = self.add(
            OpSpec::new("linalg.fill")
                .operands(&[value, e])
                .results(&[ty])
                .prop("operandSegmentSizes", segments)
                .regions(1),
        );
        let region = self.out.region_of(f, 0);
        let b = self.out.add_block(region, &[elem, elem]);
        let x = self.out.blocks[b.index()].args[0];
        OpSpec::new("linalg.yield").operands(&[x]).build(self.out, Some(b));
        self.out.result(f)
    }

    /// A `linalg.generic` over `ins` into `init` (of shape `shape`), with
    /// `maps` (the inputs', then the output's) and `iterators`; its body
    /// built by `body` from the block's arguments.
    #[allow(clippy::too_many_arguments)]
    fn generic(
        &mut self,
        ins: &[T],
        init: ValueId,
        shape: &[u64],
        elem: TypeId,
        maps: &[Map],
        iterators: &[&str],
        body: impl FnOnce(&mut Self, &[ValueId]) -> Result<Vec<ValueId>, String>,
    ) -> Result<T, String> {
        let ty = self.out.tensor_type(shape, elem);
        let mut operands: Vec<ValueId> = ins.iter().map(|t| t.v).collect();
        operands.push(init);
        let maps_attr: Vec<AttrId> = maps.iter().map(|m| self.out.affine_map_attr(&m.to_string())).collect();
        let maps_attr = self.out.array_attr(maps_attr);
        let iters: Vec<AttrId> =
            iterators.iter().map(|i| self.out.dialect_attr("linalg.iterator_type", Some(&format!("<{i}>")))).collect();
        let iters = self.out.array_attr(iters);
        let segments = self.out.dense_array_attr("i32", &[ins.len() as i64, 1]);
        let g = self.add(
            OpSpec::new("linalg.generic")
                .operands(&operands)
                .results(&[ty])
                .prop("indexing_maps", maps_attr)
                .prop("iterator_types", iters)
                .prop("operandSegmentSizes", segments)
                .regions(1),
        );
        let region = self.out.region_of(g, 0);
        let mut arg_types: Vec<TypeId> = ins.iter().map(|t| t.elem).collect();
        arg_types.push(elem);
        let b = self.out.add_block(region, &arg_types);
        let saved = std::mem::replace(&mut self.block, b);
        let args = self.out.blocks[b.index()].args.clone();
        let yielded = body(self, &args);
        self.block = saved;
        let yielded = yielded?;
        OpSpec::new("linalg.yield").operands(&yielded).build(self.out, Some(b));
        Ok(T { v: self.out.result(g), shape: shape.to_vec(), elem })
    }

    /// The body of `name`'s description for elements of type `elem`, on
    /// `args`: what it yields.
    fn described(&mut self, name: &str, elem: TypeId, args: &[ValueId]) -> Result<ValueId, String> {
        let class = self.class(elem)?;
        let d = self.cx.d;
        let dm = &d.m;
        let &entry = d
            .entries
            .get(&(name.to_string(), class))
            .ok_or_else(|| format!("{name} on {class:?} elements is not supported yet"))?;
        let body = dm.regions[dm.region_of(entry, 0).index()].blocks[0];
        let placeholder = match class {
            Class::Float => dm.types().find(|(_, t)| **t == Type::Float("f32")).map(|(id, _)| id),
            Class::Int => dm
                .types()
                .find(|(_, t)| **t == Type::Int { width: 32, signedness: Signedness::Signless })
                .map(|(id, _)| id),
        };
        let subst = move |t: TypeId| (Some(t) == placeholder).then_some(elem);
        let dargs = &dm.blocks[body.index()].args;
        if dargs.len() != args.len() + 1 {
            return Err(format!("its description takes {} operands, not {}", dargs.len() - 1, args.len()));
        }
        let mut map: HashMap<ValueId, ValueId> = dargs.iter().copied().zip(args.iter().copied()).collect();
        for &dop in &dm.blocks[body.index()].ops {
            let o = &dm.ops[dop.index()];
            let operands = o
                .operands
                .iter()
                .map(|v| map.get(v).copied().ok_or("its description uses a value from outside its body"))
                .collect::<Result<Vec<_>, _>>()?;
            if dm.op_name(dop) == "linalg.yield" {
                return operands.first().copied().ok_or_else(|| "its description yields nothing".to_string());
            }
            let results: Vec<TypeId> =
                o.results.iter().map(|&r| self.out.import_type(dm, dm.value_type(r), &subst)).collect();
            let mut spec = OpSpec::new(dm.op_name(dop)).operands(&operands).results(&results);
            if let Some(Attr::Dict(es)) = o.properties.map(|p| dm.attr(p)) {
                for (k, a) in es.clone() {
                    let a = self.out.import_attr(dm, a, &subst);
                    spec = spec.prop(&k, a);
                }
            }
            let new = self.add(spec);
            for (&old, &n) in o.results.iter().zip(&self.out.ops[new.index()].results.clone()) {
                map.insert(old, n);
            }
        }
        Err("its description has no linalg.yield".into())
    }

    fn op(&mut self, op: OpId) -> Result<(), String> {
        let src = self.src;
        let o = &src.ops[op.index()];
        let name = src.op_name(op);
        let result = |l: &Self| -> Result<(Vec<u64>, TypeId), String> {
            let r = *o.results.first().ok_or("no result")?;
            l.out.shaped(src.value_type(r)).ok_or_else(|| "a result that is not a tensor".to_string())
        };
        let new: T = match name {
            "stablehlo.constant" => return self.constant(op),
            "func.return" | "stablehlo.return" => {
                let args = o
                    .operands
                    .iter()
                    .map(|v| self.map.get(v).copied().ok_or("an operand from outside"))
                    .collect::<Result<Vec<_>, _>>()?;
                self.add(OpSpec::new("func.return").operands(&args));
                return Ok(());
            }
            "func.call" => {
                let callee = match src.op_attr(op, "callee").map(|a| src.attr(a)) {
                    Some(Attr::SymbolRef(p)) => p[0].clone(),
                    _ => return Err("no callee".into()),
                };
                let &f = self
                    .cx
                    .private
                    .get(&callee)
                    .ok_or_else(|| format!("@{callee} is not a private function of the module"))?;
                // The callee's body here, its arguments the call's operands.
                let body = src.regions[src.ops[f.index()].regions[0].index()].blocks[0];
                for (&a, &v) in src.blocks[body.index()].args.iter().zip(&o.operands) {
                    let n = *self.map.get(&v).ok_or("an operand from outside")?;
                    self.map.insert(a, n);
                }
                for &inner in &src.blocks[body.index()].ops {
                    if src.op_name(inner) == "func.return" {
                        for (&r, v) in o.results.iter().zip(&src.ops[inner.index()].operands) {
                            let n = *self.map.get(v).ok_or("a result from outside")?;
                            self.map.insert(r, n);
                        }
                        // A constant returned stays known as one.
                        for (&r, v) in o.results.iter().zip(&src.ops[inner.index()].operands) {
                            if let Some(&a) = self.scalars.get(v) {
                                self.scalars.insert(r, a);
                            }
                        }
                        return Ok(());
                    }
                    self.op(inner).map_err(|e| format!("in @{callee}: {}: {e}", src.op_name(inner)))?;
                }
                return Err(format!("@{callee} does not return"));
            }
            "stablehlo.broadcast_in_dim" => {
                let x = self.operand(o.operands[0])?;
                let (shape, elem) = result(self)?;
                let dims = src
                    .op_attr(op, "broadcast_dimensions")
                    .and_then(|a| src.int_list(a))
                    .ok_or("no broadcast_dimensions")?;
                if let Some(&a) = self.scalars.get(&o.operands[0]) {
                    let s = self.scalar(a, elem);
                    let v = self.fill(s, &shape, elem);
                    T { v, shape, elem }
                } else {
                    let results: Vec<Expr> = dims
                        .iter()
                        .enumerate()
                        .map(|(i, &d)| {
                            if x.shape[i] == 1 && shape[d as usize] != 1 {
                                Expr::Const(0)
                            } else {
                                Expr::Dim(d as usize)
                            }
                        })
                        .collect();
                    let n = shape.len();
                    let maps = [Map { dims: n, syms: 0, results }, Map::identity(n)];
                    let init = self.empty(&shape, elem);
                    self.generic(&[x], init, &shape, elem, &maps, &vec!["parallel"; n], |_, a| Ok(vec![a[0]]))?
                }
            }
            "stablehlo.dot_general" => self.dot_general(op)?,
            "stablehlo.reduce" => self.reduce(op)?,
            "stablehlo.transpose" => {
                let x = self.operand(o.operands[0])?;
                let perm = src.op_attr(op, "permutation").and_then(|a| src.int_list(a)).ok_or("no permutation")?;
                self.transpose(&x, &perm.iter().map(|&p| p as usize).collect::<Vec<_>>())?
            }
            "stablehlo.reshape" => {
                let x = self.operand(o.operands[0])?;
                let (shape, _) = result(self)?;
                self.reshape(&x, &shape)?
            }
            "stablehlo.convert" => {
                let x = self.operand(o.operands[0])?;
                let (shape, elem) = result(self)?;
                let n = shape.len();
                let init = self.empty(&shape, elem);
                self.generic(
                    &[x.clone()],
                    init,
                    &shape,
                    elem,
                    &[Map::identity(n), Map::identity(n)],
                    &vec!["parallel"; n],
                    |l, a| Ok(vec![l.convert(a[0], x.elem, elem)?]),
                )?
            }
            "stablehlo.compare" => {
                let (a, b) = (self.operand(o.operands[0])?, self.operand(o.operands[1])?);
                let (shape, elem) = result(self)?;
                let dir = match src.op_attr(op, "comparison_direction").map(|x| src.attr(x)) {
                    Some(Attr::Dialect { body: Some(b), .. }) => b.clone(),
                    _ => return Err("no comparison_direction".into()),
                };
                let unsigned = matches!(src.op_attr(op, "compare_type").map(|x| src.attr(x)), Some(Attr::Dialect { body: Some(b), .. }) if b.contains("UNSIGNED"));
                let float = self.class(a.elem)? == Class::Float;
                let which = ["EQ", "NE", "GE", "GT", "LE", "LT"]
                    .into_iter()
                    .find(|d| dir.contains(&format!(" {d}>")) || dir.contains(&format!("{d}>")))
                    .ok_or("an unknown direction")?;
                let pred: i64 = match (float, unsigned, which) {
                    (true, _, "EQ") => 1,
                    (true, _, "GT") => 2,
                    (true, _, "GE") => 3,
                    (true, _, "LT") => 4,
                    (true, _, "LE") => 5,
                    (true, _, _) => 13, // une: NaN is not equal to anything
                    (false, _, "EQ") => 0,
                    (false, _, "NE") => 1,
                    (false, false, "LT") => 2,
                    (false, false, "LE") => 3,
                    (false, false, "GT") => 4,
                    (false, false, _) => 5, // sge
                    (false, true, "LT") => 6,
                    (false, true, "LE") => 7,
                    (false, true, "GT") => 8,
                    (false, true, _) => 9,
                };
                let n = shape.len();
                let init = self.empty(&shape, elem);
                self.generic(
                    &[a, b],
                    init,
                    &shape,
                    elem,
                    &[Map::identity(n), Map::identity(n), Map::identity(n)],
                    &vec!["parallel"; n],
                    |l, x| {
                        let i64t = l.out.int_type(64);
                        let p = l.out.int_attr(pred, i64t);
                        let i1 = l.out.int_type(1);
                        let mut spec = OpSpec::new(if float { "arith.cmpf" } else { "arith.cmpi" })
                            .operands(&x[..2])
                            .results(&[i1])
                            .prop("predicate", p);
                        if float {
                            let fm = l.out.dialect_attr("arith.fastmath", Some("<none>"));
                            spec = spec.prop("fastmath", fm);
                        }
                        let c = l.add(spec);
                        Ok(vec![l.out.result(c)])
                    },
                )?
            }
            "stablehlo.select" => {
                let p = self.operand(o.operands[0])?;
                let (a, b) = (self.operand(o.operands[1])?, self.operand(o.operands[2])?);
                let (shape, elem) = result(self)?;
                let n = shape.len();
                let pmap =
                    if p.shape.is_empty() { Map { dims: n, syms: 0, results: vec![] } } else { Map::identity(n) };
                let init = self.empty(&shape, elem);
                self.generic(
                    &[p, a, b],
                    init,
                    &shape,
                    elem,
                    &[pmap, Map::identity(n), Map::identity(n), Map::identity(n)],
                    &vec!["parallel"; n],
                    |l, x| {
                        let s = l.add(OpSpec::new("arith.select").operands(&x[..3]).results(&[elem]));
                        Ok(vec![l.out.result(s)])
                    },
                )?
            }
            "stablehlo.iota" => {
                let (shape, elem) = result(self)?;
                let dim = src.op_attr(op, "iota_dimension").and_then(|a| src.int_of(a)).ok_or("no iota_dimension")?;
                let n = shape.len();
                let init = self.empty(&shape, elem);
                self.generic(&[], init, &shape, elem, &[Map::identity(n)], &vec!["parallel"; n], |l, _| {
                    let index = l.out.index_type();
                    let i64t = l.out.int_type(64);
                    let dim_attr = l.out.int_attr(dim, i64t);
                    let i = l.add(OpSpec::new("linalg.index").results(&[index]).prop("dim", dim_attr));
                    let i = l.out.result(i);
                    let c = l.add(OpSpec::new("arith.index_cast").operands(&[i]).results(&[i64t]));
                    let c = l.out.result(c);
                    Ok(vec![l.convert(c, i64t, elem)?])
                })?
            }
            _ if name.starts_with("stablehlo.") => {
                // Element by element, from the description.
                let ins = o.operands.iter().map(|&v| self.operand(v)).collect::<Result<Vec<_>, _>>()?;
                let (shape, elem) = result(self)?;
                if ins.iter().any(|t| t.shape != shape) {
                    return Err("operands of another shape than the result's".into());
                }
                let n = shape.len();
                let maps = vec![Map::identity(n); ins.len() + 1];
                let init = self.empty(&shape, elem);
                let name = name.to_string();
                self.generic(&ins, init, &shape, elem, &maps, &vec!["parallel"; n], |l, a| {
                    Ok(vec![l.described(&name, elem, &a[..a.len() - 1])?])
                })?
            }
            _ => return Err("not supported yet".into()),
        };
        self.map.insert(o.results[0], new.v);
        Ok(())
    }

    /// `stablehlo.constant`: a scalar or small one as it is; a larger one as
    /// a blob, its hexadecimal data decoded.
    fn constant(&mut self, op: OpId) -> Result<(), String> {
        let src = self.src;
        let r = src.ops[op.index()].results[0];
        let ty = src.value_type(r);
        let (shape, elem) = self.out.shaped(ty).ok_or("not a tensor")?;
        let value = src.op_attr(op, "value").ok_or("no value")?;
        let attr = match src.attr(src.resolve_attr(value)).clone() {
            Attr::Builtin { keyword: "dense", body, .. } => {
                let inner = body[1..body.len() - 1].trim();
                let hex = inner.strip_prefix("\"0x").and_then(|h| h.strip_suffix('"'));
                let count: u64 = shape.iter().product();
                let bytes_each = (self.bits(elem) as u64).div_ceil(8);
                match hex {
                    Some(h) if h.len() / 2 > BLOB_BYTES && (h.len() / 2) as u64 == count * bytes_each => {
                        let bytes = (0..h.len())
                            .step_by(2)
                            .map(|i| u8::from_str_radix(&h[i..i + 2], 16))
                            .collect::<Result<Vec<u8>, _>>()
                            .map_err(|_| "bad hexadecimal data")?;
                        self.cx.made += 1;
                        let key = format!("stablehlo_constant_{}", self.cx.made);
                        self.cx.blobs.push(Item::Blob {
                            key: key.clone(),
                            align: bytes_each.max(4) as u32,
                            bytes: Arc::new(bytes),
                        });
                        self.out.intern_attr(Attr::Builtin {
                            keyword: "dense_resource",
                            body: format!("<{key}>"),
                            ty: Some(ty),
                        })
                    }
                    _ => {
                        if shape.is_empty() && hex.is_none() {
                            // A scalar's value, for fills and initial values.
                            let a = if self.class(elem)? == Class::Float {
                                self.out.float_attr(inner, elem)
                            } else {
                                self.out.int_attr(inner.parse().map_err(|_| "a bad integer")?, elem)
                            };
                            self.scalars.insert(r, a);
                        }
                        value
                    }
                }
            }
            _ => value,
        };
        let c = self.add(OpSpec::new("arith.constant").results(&[ty]).prop("value", attr));
        let v = self.out.result(c);
        self.map.insert(r, v);
        Ok(())
    }

    /// `v` (of element type `from`) as `to`.
    fn convert(&mut self, v: ValueId, from: TypeId, to: TypeId) -> Result<ValueId, String> {
        if from == to {
            return Ok(v);
        }
        let (fb, tb) = (self.bits(from), self.bits(to));
        let name = match (self.class(from)?, self.class(to)?) {
            (Class::Float, Class::Float) if fb < tb => "arith.extf",
            (Class::Float, Class::Float) => "arith.truncf",
            (Class::Int, Class::Float) if fb == 1 => "arith.uitofp",
            (Class::Int, Class::Float) => "arith.sitofp",
            (Class::Float, Class::Int) => "arith.fptosi",
            (Class::Int, Class::Int) if fb == 1 => "arith.extui",
            (Class::Int, Class::Int) if fb < tb => "arith.extsi",
            (Class::Int, Class::Int) if fb > tb => "arith.trunci",
            _ => return Ok(v),
        };
        let c = self.add(OpSpec::new(name).operands(&[v]).results(&[to]));
        Ok(self.out.result(c))
    }

    /// `x` with its dimensions reordered: result dimension `i` is `x`'s
    /// dimension `perm[i]`.
    fn transpose(&mut self, x: &T, perm: &[usize]) -> Result<T, String> {
        let n = perm.len();
        let shape: Vec<u64> = perm.iter().map(|&p| x.shape[p]).collect();
        let mut results = vec![Expr::Const(0); n];
        for (i, &p) in perm.iter().enumerate() {
            results[p] = Expr::Dim(i);
        }
        let maps = [Map { dims: n, syms: 0, results }, Map::identity(n)];
        let init = self.empty(&shape, x.elem);
        self.generic(std::slice::from_ref(x), init, &shape, x.elem, &maps, &vec!["parallel"; n], |_, a| Ok(vec![a[0]]))
    }

    /// `x` as `shape`, with the same elements in order: dimensions merged
    /// (`tensor.collapse_shape`) then split (`tensor.expand_shape`).
    fn reshape(&mut self, x: &T, shape: &[u64]) -> Result<T, String> {
        let (a, b) = (&x.shape, shape);
        // Groups of each side's dimensions with equal products.
        let (mut ga, mut gb): (Vec<Vec<usize>>, Vec<Vec<usize>>) = (Vec::new(), Vec::new());
        let (mut i, mut j) = (0, 0);
        while i < a.len() && j < b.len() {
            let (mut gi, mut gj) = (vec![i], vec![j]);
            let (mut pi, mut pj) = (a[i], b[j]);
            while pi != pj {
                if pi < pj {
                    i += 1;
                    let &s = a.get(i).ok_or("shapes of different sizes")?;
                    gi.push(i);
                    pi *= s;
                } else {
                    j += 1;
                    let &s = b.get(j).ok_or("shapes of different sizes")?;
                    gj.push(j);
                    pj *= s;
                }
            }
            i += 1;
            j += 1;
            ga.push(gi);
            gb.push(gj);
        }
        // Dimensions of size one left over join the last group.
        while i < a.len() && a[i] == 1 {
            ga.last_mut().ok_or("a reshape of a scalar")?.push(i);
            i += 1;
        }
        while j < b.len() && b[j] == 1 {
            gb.last_mut().ok_or("a reshape to a scalar")?.push(j);
            j += 1;
        }
        if i != a.len() || j != b.len() {
            return Err("shapes of different sizes".into());
        }
        let reassociation = |out: &mut Module, groups: &[Vec<usize>]| -> AttrId {
            let gs: Vec<AttrId> = groups
                .iter()
                .map(|g| {
                    let es = g.iter().map(|&d| out.intern_attr(Attr::Int { text: d.to_string(), ty: None })).collect();
                    out.array_attr(es)
                })
                .collect();
            out.array_attr(gs)
        };
        let mid: Vec<u64> = ga.iter().map(|g| g.iter().map(|&d| a[d]).product()).collect();
        let mut v = x.v;
        if mid.len() != a.len() {
            let ty = self.out.tensor_type(&mid, x.elem);
            let r = reassociation(self.out, &ga);
            let c =
                self.add(OpSpec::new("tensor.collapse_shape").operands(&[v]).results(&[ty]).prop("reassociation", r));
            v = self.out.result(c);
        }
        if mid.len() != b.len() {
            let ty = self.out.tensor_type(b, x.elem);
            let r = reassociation(self.out, &gb);
            let s = self.out.dense_array_attr("i64", &b.iter().map(|&d| d as i64).collect::<Vec<_>>());
            let e = self.add(
                OpSpec::new("tensor.expand_shape")
                    .operands(&[v])
                    .results(&[ty])
                    .prop("reassociation", r)
                    .prop("static_output_shape", s),
            );
            v = self.out.result(e);
        }
        Ok(T { v, shape: b.to_vec(), elem: x.elem })
    }

    /// `stablehlo.dot_general`.
    fn dot_general(&mut self, op: OpId) -> Result<T, String> {
        let src = self.src;
        let o = &src.ops[op.index()];
        let (mut lhs, mut rhs) = (self.operand(o.operands[0])?, self.operand(o.operands[1])?);
        let r = o.results[0];
        let (shape, elem) = self.out.shaped(src.value_type(r)).ok_or("a result that is not a tensor")?;
        let body = match src.op_attr(op, "dot_dimension_numbers").map(|a| src.attr(a)) {
            Some(Attr::Dialect { body: Some(b), .. }) => b.clone(),
            _ => return Err("no dot_dimension_numbers".into()),
        };
        let list = |key: &str| -> Vec<usize> {
            body.split(&format!("{key} = ["))
                .nth(1)
                .and_then(|r| r.split(']').next())
                .map_or(Vec::new(), |l| l.split(',').filter_map(|x| x.trim().parse().ok()).collect())
        };
        let (mut lb, mut rb) = (list("lhs_batching_dimensions"), list("rhs_batching_dimensions"));
        let (mut lc, mut rc) = (list("lhs_contracting_dimensions"), list("rhs_contracting_dimensions"));
        let free = |rank: usize, b: &[usize], c: &[usize]| -> Vec<usize> {
            (0..rank).filter(|d| !b.contains(d) && !c.contains(d)).collect()
        };
        let (mut lf, mut rf) = (free(lhs.shape.len(), &lb, &lc), free(rhs.shape.len(), &rb, &rc));
        // A matrix product, or one per batch: operands in the layout
        // `linalg.matmul` and `linalg.batch_matmul` have, [b, m, k] and
        // [b, k, n], transposing them first if they are not.
        if lb.len() <= 1 && lc.len() == 1 && lf.len() == 1 && rf.len() == 1 {
            let lwant: Vec<usize> = lb.iter().chain(&lf).chain(&lc).copied().collect();
            if lwant.iter().enumerate().any(|(i, &d)| i != d) {
                lhs = self.transpose(&lhs, &lwant)?;
                (lb, lf, lc) = ((0..lb.len()).collect(), vec![lb.len()], vec![lb.len() + 1]);
            }
            let rwant: Vec<usize> = rb.iter().chain(&rc).chain(&rf).copied().collect();
            if rwant.iter().enumerate().any(|(i, &d)| i != d) {
                rhs = self.transpose(&rhs, &rwant)?;
                (rb, rc, rf) = ((0..rb.len()).collect(), vec![rb.len()], vec![rb.len() + 1]);
            }
        }
        // Loops: the result's dimensions (batch, lhs free, rhs free), then
        // the contracted ones.
        let (nb, nlf, nrf) = (lb.len(), lf.len(), rf.len());
        let nres = nb + nlf + nrf;
        let n = nres + lc.len();
        let map_of = |rank: usize, b: &[usize], f: &[usize], c: &[usize], free_at: usize| -> Map {
            let mut results = vec![Expr::Const(0); rank];
            for (t, &d) in b.iter().enumerate() {
                results[d] = Expr::Dim(t);
            }
            for (t, &d) in f.iter().enumerate() {
                results[d] = Expr::Dim(free_at + t);
            }
            for (t, &d) in c.iter().enumerate() {
                results[d] = Expr::Dim(nres + t);
            }
            Map { dims: n, syms: 0, results }
        };
        let lmap = map_of(lhs.shape.len(), &lb, &lf, &lc, nb);
        let rmap = map_of(rhs.shape.len(), &rb, &rf, &rc, nb + nlf);
        let omap = Map { dims: n, syms: 0, results: (0..nres).map(Expr::Dim).collect() };
        let mut iterators = vec!["parallel"; nres];
        iterators.extend(vec!["reduction"; lc.len()]);
        let zero = self.zero(elem)?;
        let init = self.fill(zero, &shape, elem);
        let float = self.class(elem)? == Class::Float;
        let (le, re) = (lhs.elem, rhs.elem);
        self.generic(&[lhs, rhs], init, &shape, elem, &[lmap, rmap, omap], &iterators, |l, a| {
            let (x, y) = (l.convert(a[0], le, elem)?, l.convert(a[1], re, elem)?);
            let fm = l.out.dialect_attr("arith.fastmath", Some("<none>"));
            let (mul, add) = if float { ("arith.mulf", "arith.addf") } else { ("arith.muli", "arith.addi") };
            let mut spec = OpSpec::new(mul).operands(&[x, y]).results(&[elem]);
            if float {
                spec = spec.prop("fastmath", fm);
            }
            let m = l.add(spec);
            let m = l.out.result(m);
            let mut spec = OpSpec::new(add).operands(&[a[2], m]).results(&[elem]);
            if float {
                spec = spec.prop("fastmath", fm);
            }
            let s = l.add(spec);
            Ok(vec![l.out.result(s)])
        })
    }

    /// `stablehlo.reduce` of one operand from a constant initial value,
    /// its body one element-wise operation of its two arguments.
    fn reduce(&mut self, op: OpId) -> Result<T, String> {
        let src = self.src;
        let o = &src.ops[op.index()];
        if o.operands.len() != 2 {
            return Err("a reduction of more than one operand is not supported yet".into());
        }
        let x = self.operand(o.operands[0])?;
        let &init = self.scalars.get(&o.operands[1]).ok_or("an initial value that is not a constant")?;
        let dims: Vec<usize> = src
            .op_attr(op, "dimensions")
            .and_then(|a| src.int_list(a))
            .ok_or("no dimensions")?
            .iter()
            .map(|&d| d as usize)
            .collect();
        let body = src.regions[o.regions[0].index()].blocks[0];
        let bops = &src.blocks[body.index()].ops;
        let bargs = &src.blocks[body.index()].args;
        let [comb, ret] = bops[..] else { return Err("a body of more than one operation is not supported yet".into()) };
        let co = &src.ops[comb.index()];
        if src.op_name(ret) != "stablehlo.return"
            || co.operands.len() != 2
            || !bargs.iter().all(|a| co.operands.contains(a))
        {
            return Err("a body that is not one operation of its two arguments".into());
        }
        let combine = src.op_name(comb).to_string();
        let r = o.results[0];
        let (shape, elem) = self.out.shaped(src.value_type(r)).ok_or("a result that is not a tensor")?;
        let start = self.scalar(init, elem);
        let filled = self.fill(start, &shape, elem);
        let n = x.shape.len();
        let kept: Vec<usize> = (0..n).filter(|d| !dims.contains(d)).collect();
        let maps = [Map::identity(n), Map { dims: n, syms: 0, results: kept.iter().map(|&d| Expr::Dim(d)).collect() }];
        let iterators: Vec<&str> = (0..n).map(|d| if dims.contains(&d) { "reduction" } else { "parallel" }).collect();
        self.generic(&[x], filled, &shape, elem, &maps, &iterators, |l, a| {
            Ok(vec![l.described(&combine, elem, &[a[0], a[1]])?])
        })
    }
}

#[cfg(test)]
mod tests {
    #[test]
    fn descriptions_read() {
        let d = super::descriptions().unwrap();
        assert!(d.entries.len() > 20);
    }
}
