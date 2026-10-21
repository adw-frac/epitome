//! `torch` to `linalg` on tensors, as torch-mlir's
//! `torch-backend-to-linalg-on-tensors-backend-pipeline` does: functions
//! on `!torch.vtensor` become functions on `tensor`, each `torch.aten`
//! operation a `linalg.generic` (with `tensor.empty`, `linalg.fill` and
//! `tensor.pad` where it needs them), each literal an `arith.constant`.
//!
//! What each operation computes is data, in `mlir/dialects/torch.mlir`:
//! its operands' roles, its indexing maps and its body. This pass reads
//! those descriptions and builds the operations from them. Shapes must be
//! static, as `torch.export` gives them for a fixed input size.

use std::collections::HashMap;
use std::sync::OnceLock;

use crate::affine::{Expr, Map};
use crate::build::{OpSpec, float_text};
use crate::ir::*;

const DESCRIPTIONS: &str = include_str!("../dialects/torch.mlir");

/// Lowers every function in `src` from `torch` to `linalg` on tensors.
pub fn run(src: &Module) -> Result<Module, String> {
    let d = descriptions()?;
    let mut out = src.empty_like();
    for top in src.top_ops().collect::<Vec<_>>() {
        match src.op_name(top) {
            "builtin.module" => {
                let o = &src.ops[top.index()];
                let mut spec = OpSpec::new("builtin.module").regions(1).loc(o.loc);
                spec = with_dicts(src, spec, o.properties, o.attrs);
                let module = spec.build(&mut out, None);
                let region = out.region_of(module, 0);
                let block = out.add_block(region, &[]);
                for &r in &o.regions {
                    for &b in &src.regions[r.index()].blocks {
                        for &op in &src.blocks[b.index()].ops {
                            lower_top(src, op, &mut out, Some(block), d)?;
                        }
                    }
                }
            }
            _ => lower_top(src, top, &mut out, None, d)?,
        }
    }
    Ok(out)
}

/// An operation's properties and attributes, copied entry by entry.
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

fn lower_top(src: &Module, op: OpId, out: &mut Module, block: Option<BlockId>, d: &Descriptions) -> Result<(), String> {
    match src.op_name(op) {
        "func.func" => lower_func(src, op, out, block, d),
        other => Err(format!("{other}: only functions are lowered")),
    }
}

// ---------------------------------------------------------------------------
// Descriptions

/// The parsed description file, and its entries by operation and kind of
/// element.
struct Descriptions {
    m: Module,
    entries: HashMap<(String, Class), OpId>,
}

#[derive(Clone, Copy, PartialEq, Eq, Hash, Debug)]
enum Class {
    Float,
    Int,
}

fn descriptions() -> Result<&'static Descriptions, String> {
    static D: OnceLock<Result<Descriptions, String>> = OnceLock::new();
    D.get_or_init(|| {
        let m = crate::parse_module(DESCRIPTIONS).map_err(|e| format!("dialects/torch.mlir:{e}"))?;
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

// ---------------------------------------------------------------------------
// Element types

/// A tensor's element type: the signless type MLIR keeps it as, and what
/// PyTorch's type says about it.
#[derive(Clone, Copy, PartialEq, Eq, Debug)]
struct Elem {
    ty: TypeId,
    class: Class,
    signed: bool,
    bits: u32,
}

/// The shape and element type of `!torch.vtensor<[2,3],f32>`.
fn vtensor(src: &Module, out: &mut Module, ty: TypeId) -> Result<(Vec<u64>, Elem), String> {
    let text = crate::printer::type_text(src, ty);
    let Type::Dialect { name, body: Some(body) } = src.ty(src.resolve_type(ty)) else {
        return Err(format!("expected a !torch.vtensor, found {text}"));
    };
    if name != "torch.vtensor" {
        return Err(format!("expected a !torch.vtensor, found {text}"));
    }
    let inner = &body[1..body.len() - 1];
    let Some((dims, dtype)) = inner.strip_prefix('[').and_then(|r| r.split_once("],")) else {
        return Err(format!("a tensor of unknown rank, {text}, is not supported"));
    };
    let mut shape = Vec::new();
    for dim in dims.split(',').filter(|d| !d.is_empty()) {
        match dim.trim().parse() {
            Ok(n) => shape.push(n),
            Err(_) => return Err(format!("dynamic shapes are not supported yet: {text}")),
        }
    }
    let dtype = dtype.trim();
    let elem = if FLOAT_TYPES.contains(&dtype) {
        let bits = match dtype {
            "f64" => 64,
            "f32" | "tf32" => 32,
            "f16" | "bf16" => 16,
            _ => 8,
        };
        Elem { ty: out.float_type(dtype), class: Class::Float, signed: true, bits }
    } else {
        let (signed, digits) = if let Some(d) = dtype.strip_prefix("si") {
            (true, d)
        } else if let Some(d) = dtype.strip_prefix("ui") {
            (false, d)
        } else if let Some(d) = dtype.strip_prefix('i') {
            (d != "1", d)
        } else {
            return Err(format!("element type '{dtype}' is not supported yet"));
        };
        let bits: u32 = digits.parse().map_err(|_| format!("element type '{dtype}' is not supported yet"))?;
        Elem { ty: out.int_type(bits), class: Class::Int, signed, bits }
    };
    Ok((shape, elem))
}

// ---------------------------------------------------------------------------
// Functions

/// What a `torch` value stands for once lowered.
#[derive(Clone, Debug)]
enum Val {
    Tensor {
        v: ValueId,
        shape: Vec<u64>,
        elem: Elem,
    },
    Int(i64),
    Float(f64),
    Bool(bool),
    None,
    List(Vec<i64>),
    /// A constant nothing here reads, such as a string.
    Other,
}

struct Lower<'a> {
    src: &'a Module,
    out: &'a mut Module,
    d: &'a Descriptions,
    vals: HashMap<ValueId, Val>,
    /// Where new operations go.
    block: BlockId,
}

fn lower_func(
    src: &Module,
    f: OpId,
    out: &mut Module,
    parent: Option<BlockId>,
    d: &Descriptions,
) -> Result<(), String> {
    let name = src.op_attr(f, "sym_name").and_then(|a| src.string_of(a)).unwrap_or_default();
    let fail = |e: String| format!("@{name}: {e}");
    let o = &src.ops[f.index()];
    let Some(&region) = o.regions.first() else { return Err(fail("no body".into())) };
    let [block] = src.regions[region.index()].blocks[..] else {
        return Err(fail("a body of more than one block is not supported".into()));
    };
    let body = &src.blocks[block.index()];
    let Some(&ret) = body.ops.last().filter(|&&r| src.op_name(r) == "func.return") else {
        return Err(fail("the body does not end in func.return".into()));
    };

    // The signature, on tensors.
    let mut inputs = Vec::new();
    let mut args = Vec::new();
    for &a in &body.args {
        let (shape, elem) = vtensor(src, out, src.value_type(a)).map_err(fail)?;
        inputs.push(out.tensor_type(&shape, elem.ty));
        args.push((shape, elem));
    }
    let mut results = Vec::new();
    for &v in &src.ops[ret.index()].operands {
        let (shape, elem) = vtensor(src, out, src.value_type(v)).map_err(fail)?;
        results.push(out.tensor_type(&shape, elem.ty));
    }
    let fty = out.function_type(&inputs, &results);
    let fty = out.type_attr(fty);
    let sym = out.string_attr(&name);
    let mut spec = OpSpec::new("func.func").prop("function_type", fty).prop("sym_name", sym).regions(1).loc(o.loc);
    if let Some(v) = src.op_attr(f, "sym_visibility") {
        spec = spec.prop("sym_visibility", v);
    }
    let func = spec.build(out, parent);
    let region = out.region_of(func, 0);
    let entry = out.add_block(region, &inputs);

    let mut l = Lower { src, out, d, vals: HashMap::new(), block: entry };
    for (k, (&a, (shape, elem))) in body.args.iter().zip(args).enumerate() {
        let v = l.out.blocks[entry.index()].args[k];
        l.vals.insert(a, Val::Tensor { v, shape, elem });
    }
    for &op in &body.ops[..body.ops.len() - 1] {
        l.op(op).map_err(|e| fail(format!("{}: {e}", src.op_name(op))))?;
    }
    let mut returned = Vec::new();
    for &v in &src.ops[ret.index()].operands {
        returned.push(l.tensor(v).map_err(fail)?.0);
    }
    OpSpec::new("func.return").operands(&returned).build(l.out, Some(entry));
    Ok(())
}

impl Lower<'_> {
    fn val(&self, v: ValueId) -> Result<&Val, String> {
        self.vals.get(&v).ok_or_else(|| "an operand from an operation that was not lowered".to_string())
    }

    fn tensor(&self, v: ValueId) -> Result<(ValueId, Vec<u64>, Elem), String> {
        match self.val(v)? {
            Val::Tensor { v, shape, elem } => Ok((*v, shape.clone(), *elem)),
            other => Err(format!("expected a tensor, found {other:?}")),
        }
    }

    fn int(&self, v: ValueId) -> Result<i64, String> {
        match self.val(v)? {
            Val::Int(i) => Ok(*i),
            Val::Bool(b) => Ok(*b as i64),
            other => Err(format!("expected a constant integer, found {other:?}")),
        }
    }

    fn list(&self, v: ValueId) -> Result<Vec<i64>, String> {
        match self.val(v)? {
            Val::List(l) => Ok(l.clone()),
            Val::None => Ok(Vec::new()),
            other => Err(format!("expected a list of constant integers, found {other:?}")),
        }
    }

    fn add(&mut self, spec: OpSpec) -> OpId {
        spec.build(self.out, Some(self.block))
    }

    fn op(&mut self, op: OpId) -> Result<(), String> {
        let src = self.src;
        let o = &src.ops[op.index()];
        let result = o.results.first().copied();
        let name = src.op_name(op);
        let value = || src.op_attr(op, "value").map(|a| src.attr(a).clone());
        let r = || result.ok_or_else(|| "no result".to_string());
        let val = match name {
            "torch.constant.int" => match value() {
                Some(Attr::Int { text, .. }) => Val::Int(text.parse().map_err(|_| format!("bad integer {text}"))?),
                _ => return Err("a constant without a value".into()),
            },
            "torch.constant.float" => match value() {
                Some(Attr::Float { text, .. } | Attr::Int { text, .. }) => {
                    Val::Float(text.parse().map_err(|_| format!("bad float {text}"))?)
                }
                _ => return Err("a constant without a value".into()),
            },
            "torch.constant.bool" => Val::Bool(matches!(value(), Some(Attr::Bool(true)))),
            "torch.constant.none" => Val::None,
            "torch.constant.str" | "torch.constant.device" => Val::Other,
            "torch.prim.ListConstruct" => Val::List(o.operands.iter().map(|&a| self.int(a)).collect::<Result<_, _>>()?),
            "torch.vtensor.literal" => {
                let (shape, elem) = vtensor(src, self.out, src.value_type(r()?))?;
                let attr = src.op_attr(op, "value").ok_or("a literal without a value")?;
                // The value is already typed as a builtin tensor.
                let ty = match src.attr(attr) {
                    Attr::Builtin { ty: Some(t), .. } => *t,
                    _ => self.out.tensor_type(&shape, elem.ty),
                };
                let c = self.add(OpSpec::new("arith.constant").results(&[ty]).prop("value", attr));
                Val::Tensor { v: self.out.result(c), shape, elem }
            }
            _ => self.described(op)?,
        };
        if let Some(v) = result {
            self.vals.insert(v, val);
        }
        Ok(())
    }

    /// An operation lowered as its description says.
    fn described(&mut self, op: OpId) -> Result<Val, String> {
        let src = self.src;
        let o = &src.ops[op.index()];
        let result = *o.results.first().ok_or("no result")?;
        let (shape, elem) = vtensor(src, self.out, src.value_type(result))?;
        let name = src.op_name(op);
        let dm = &self.d.m;
        let Some(&entry) = self.d.entries.get(&(name.to_string(), elem.class)) else {
            return Err("not supported yet".to_string());
        };
        let roles: Vec<String> = match dm.op_attr(entry, "operands").map(|a| dm.attr(a)) {
            Some(Attr::Array(es)) => es.iter().map(|&e| dm.string_of(e).unwrap_or_default()).collect(),
            _ => return Err("its description has no 'operands'".into()),
        };
        if roles.len() != o.operands.len() {
            return Err(format!("{} operands, but the description gives {} roles", o.operands.len(), roles.len()));
        }

        // Inputs and the other operands, by role.
        let mut ins: Vec<(ValueId, Vec<u64>, Elem)> = Vec::new();
        // The body's arguments before the output: tensors (by input
        // number) and scalars.
        let mut body_args: Vec<Arg> = Vec::new();
        let mut init = None;
        let mut perm = None;
        let mut swaps = Vec::new();
        let mut dims = None;
        let mut keepdim = false;
        for (k, (role, &a)) in roles.iter().zip(&o.operands).enumerate() {
            match role.as_str() {
                "tensor" => {
                    body_args.push(Arg::Input(ins.len()));
                    ins.push(self.tensor(a)?);
                }
                "scalar" => body_args.push(Arg::Scalar(match self.val(a)? {
                    Val::Int(i) => *i as f64,
                    Val::Float(f) => *f,
                    Val::Bool(b) => *b as i64 as f64,
                    other => return Err(format!("operand {k}: expected a constant number, found {other:?}")),
                })),
                "init" => {
                    if !matches!(self.val(a)?, Val::None) {
                        init = Some(self.tensor(a)?);
                    }
                }
                "list" | "ignore" => {}
                "perm" => perm = Some(self.list(a)?),
                "swap" => swaps.push(self.int(a)?),
                "dims" => dims = Some(self.list(a)?),
                "keepdim" => keepdim = self.int(a)? != 0,
                "false" | "1" => {
                    let want = if role == "false" { 0 } else { 1 };
                    if self.int(a)? != want {
                        return Err(format!("operand {k} must be {role}"));
                    }
                }
                other => return Err(format!("unknown role '{other}' in its description")),
            }
        }

        // Padding, before the maps read the input's shape.
        if let Some(pad) = dm.op_attr(entry, "pad") {
            let Some(&[t, list]) = dm.int_list(pad).as_deref() else {
                return Err("'pad' should be [tensor operand, list operand]".into());
            };
            let (t, list) = (t as usize, list as usize);
            let amounts = self.list(o.operands[list])?;
            let input = roles[..t].iter().filter(|r| *r == "tensor").count();
            if amounts.iter().any(|&p| p != 0) {
                ins[input] = self.pad(&ins[input], &amounts);
            }
        }

        // The maps and iterator types.
        let rank = shape.len();
        let (maps, iterators): (Vec<Map>, Vec<&str>) = if let Some(maps) = dm.op_attr(entry, "indexing_maps") {
            let symbols: Vec<i64> = match dm.op_attr(entry, "symbols").and_then(|a| int_pairs(dm, a)) {
                Some(pairs) => pairs
                    .iter()
                    .map(|&(operand, k)| {
                        let list = self.list(o.operands[operand as usize])?;
                        list.get(k as usize).copied().ok_or_else(|| format!("operand {operand} has no element {k}"))
                    })
                    .collect::<Result<_, String>>()?,
                None => Vec::new(),
            };
            let Attr::Array(ms) = dm.attr(maps) else { return Err("'indexing_maps' is not a list".into()) };
            let maps = ms.iter().map(|&m| affine_of(dm, m).map(|m| m.bind(&symbols))).collect::<Result<Vec<_>, _>>()?;
            let iterators = match dm.op_attr(entry, "iterator_types").map(|a| dm.attr(a)) {
                Some(Attr::Array(es)) => es
                    .iter()
                    .map(|&e| match dm.string_of(e).as_deref() {
                        Some("reduction") => "reduction",
                        _ => "parallel",
                    })
                    .collect(),
                _ => vec!["parallel"; maps[0].dims],
            };
            (maps, iterators)
        } else if perm.is_some() || !swaps.is_empty() {
            let mut p: Vec<usize> = (0..rank).collect();
            if let Some(list) = &perm {
                p = list.iter().map(|&d| dim(d, rank)).collect::<Result<_, _>>()?;
            }
            if let [a, b] = swaps[..] {
                p.swap(dim(a, rank)?, dim(b, rank)?);
            }
            // Output dimension i is input dimension p[i].
            let mut input = vec![Expr::Const(0); rank];
            for (i, &pi) in p.iter().enumerate() {
                input[pi] = Expr::Dim(i);
            }
            (vec![Map { dims: rank, syms: 0, results: input }, Map::identity(rank)], vec!["parallel"; rank])
        } else if let Some(reduce) = dims {
            let in_rank = ins[0].1.len();
            let reduce: Vec<usize> = if reduce.is_empty() {
                (0..in_rank).collect()
            } else {
                reduce.iter().map(|&d| dim(d, in_rank)).collect::<Result<_, _>>()?
            };
            let out_results = (0..in_rank)
                .filter_map(|d| match (reduce.contains(&d), keepdim) {
                    (false, _) => Some(Expr::Dim(d)),
                    (true, true) => Some(Expr::Const(0)),
                    (true, false) => None,
                })
                .collect();
            let iterators = (0..in_rank).map(|d| if reduce.contains(&d) { "reduction" } else { "parallel" }).collect();
            (vec![Map::identity(in_rank), Map { dims: in_rank, syms: 0, results: out_results }], iterators)
        } else {
            let mut maps: Vec<Map> = ins.iter().map(|t| broadcast_map(&t.1, &shape)).collect::<Result<_, _>>()?;
            maps.push(Map::identity(rank));
            (maps, vec!["parallel"; rank])
        };
        if maps.len() != ins.len() + 1 {
            return Err(format!("{} maps for {} inputs and an output", maps.len(), ins.len()));
        }

        // The output: empty, or filled with its starting value.
        let result_ty = self.out.tensor_type(&shape, elem.ty);
        let empty = self.add(OpSpec::new("tensor.empty").results(&[result_ty]));
        let mut outs = self.out.result(empty);
        let reduces = iterators.contains(&"reduction");
        if let Some((v, ishape, ielem)) = init {
            let map = match dm.op_attr(entry, "init_map") {
                Some(m) => affine_of(dm, m)?,
                None => broadcast_map(&ishape, &shape)?,
            };
            outs = self.generic(
                &[(v, ishape, ielem)],
                outs,
                elem,
                &[map, Map::identity(rank)],
                &vec!["parallel"; rank],
                |l, args| {
                    let x = l.convert(args[0], ielem, elem);
                    Ok(vec![x])
                },
            )?;
        } else if reduces {
            let zero = self.constant(0.0, elem);
            let segments = self.out.dense_array_attr("i32", &[1, 1]);
            let fill = self.add(
                OpSpec::new("linalg.fill")
                    .operands(&[zero, outs])
                    .results(&[result_ty])
                    .prop("operandSegmentSizes", segments)
                    .regions(1),
            );
            let region = self.out.region_of(fill, 0);
            let b = self.out.add_block(region, &[elem.ty, elem.ty]);
            let a = self.out.blocks[b.index()].args[0];
            OpSpec::new("linalg.yield").operands(&[a]).build(self.out, Some(b));
            outs = self.out.result(fill);
        }

        // The body, from the description's, for this element type.
        let desc_body = dm.regions[dm.region_of(entry, 0).index()].blocks[0];
        let ins_elems: Vec<Elem> = ins.iter().map(|t| t.2).collect();
        let v = self.generic(&ins, outs, elem, &maps, &iterators, |l, args| {
            let placeholder = match elem.class {
                Class::Float => dm.types().find(|(_, t)| **t == Type::Float("f32")).map(|(id, _)| id),
                Class::Int => dm
                    .types()
                    .find(|(_, t)| **t == Type::Int { width: 32, signedness: Signedness::Signless })
                    .map(|(id, _)| id),
            };
            let subst = move |t: TypeId| (Some(t) == placeholder).then_some(elem.ty);
            let mut map: HashMap<ValueId, ValueId> = HashMap::new();
            let dargs = &dm.blocks[desc_body.index()].args;
            if dargs.len() != body_args.len() + 1 {
                return Err(format!(
                    "its description's body has {} arguments, expected {}",
                    dargs.len(),
                    body_args.len() + 1
                ));
            }
            for (&da, arg) in dargs.iter().zip(&body_args) {
                let v = match *arg {
                    Arg::Input(k) => l.convert(args[k], ins_elems[k], elem),
                    Arg::Scalar(x) => l.constant(x, elem),
                };
                map.insert(da, v);
            }
            map.insert(*dargs.last().unwrap(), args[ins_elems.len()]);
            let mut yielded = Vec::new();
            for &dop in &dm.blocks[desc_body.index()].ops {
                let d = &dm.ops[dop.index()];
                let operands = d
                    .operands
                    .iter()
                    .map(|v| map.get(v).copied().ok_or("its description uses a value from outside its body"))
                    .collect::<Result<Vec<_>, _>>()?;
                if dm.op_name(dop) == "linalg.yield" {
                    yielded = operands;
                    break;
                }
                let results: Vec<TypeId> =
                    d.results.iter().map(|&r| l.out.import_type(dm, dm.value_type(r), &subst)).collect();
                let mut spec = OpSpec::new(dm.op_name(dop)).operands(&operands).results(&results);
                if let Some(Attr::Dict(es)) = d.properties.map(|p| dm.attr(p)) {
                    for (k, a) in es.clone() {
                        let a = l.out.import_attr(dm, a, &subst);
                        spec = spec.prop(&k, a);
                    }
                }
                let new = l.add(spec);
                for (&old, &new) in d.results.iter().zip(&l.out.ops[new.index()].results.clone()) {
                    map.insert(old, new);
                }
            }
            Ok(yielded)
        })?;
        Ok(Val::Tensor { v, shape, elem })
    }

    /// A `linalg.generic` over `ins` into `outs`, its body built by `body`
    /// from the block's arguments (the inputs' elements, then the
    /// output's); returns its result.
    #[allow(clippy::too_many_arguments)]
    fn generic(
        &mut self,
        ins: &[(ValueId, Vec<u64>, Elem)],
        outs: ValueId,
        elem: Elem,
        maps: &[Map],
        iterators: &[&str],
        body: impl FnOnce(&mut Self, &[ValueId]) -> Result<Vec<ValueId>, String>,
    ) -> Result<ValueId, String> {
        let result_ty = self.out.value_type(outs);
        let mut operands: Vec<ValueId> = ins.iter().map(|t| t.0).collect();
        operands.push(outs);
        let maps_attr: Vec<AttrId> = maps.iter().map(|m| self.out.affine_map_attr(&m.to_string())).collect();
        let maps_attr = self.out.array_attr(maps_attr);
        let iters: Vec<AttrId> =
            iterators.iter().map(|i| self.out.dialect_attr("linalg.iterator_type", Some(&format!("<{i}>")))).collect();
        let iters = self.out.array_attr(iters);
        let segments = self.out.dense_array_attr("i32", &[ins.len() as i64, 1]);
        let g = self.add(
            OpSpec::new("linalg.generic")
                .operands(&operands)
                .results(&[result_ty])
                .prop("indexing_maps", maps_attr)
                .prop("iterator_types", iters)
                .prop("operandSegmentSizes", segments)
                .regions(1),
        );
        let region = self.out.region_of(g, 0);
        let mut arg_types: Vec<TypeId> = ins.iter().map(|t| t.2.ty).collect();
        arg_types.push(elem.ty);
        let b = self.out.add_block(region, &arg_types);
        let saved = std::mem::replace(&mut self.block, b);
        let args = self.out.blocks[b.index()].args.clone();
        let yielded = body(self, &args);
        self.block = saved;
        let yielded = yielded?;
        OpSpec::new("linalg.yield").operands(&yielded).build(self.out, Some(b));
        Ok(self.out.result(g))
    }

    /// `x` padded with zeros by `amounts` on both sides of its last
    /// dimensions: `tensor.pad`.
    fn pad(&mut self, x: &(ValueId, Vec<u64>, Elem), amounts: &[i64]) -> (ValueId, Vec<u64>, Elem) {
        let (v, shape, elem) = x;
        let skip = shape.len() - amounts.len();
        let mut low = vec![0; shape.len()];
        low[skip..].copy_from_slice(amounts);
        let padded: Vec<u64> = shape.iter().zip(&low).map(|(&s, &p)| s + 2 * p as u64).collect();
        let zero = self.constant(0.0, *elem);
        let ty = self.out.tensor_type(&padded, elem.ty);
        let index = self.out.index_type();
        let segments = self.out.dense_array_attr("i32", &[1, 0, 0]);
        let lows = self.out.dense_array_attr("i64", &low);
        let p = self.add(
            OpSpec::new("tensor.pad")
                .operands(&[*v])
                .results(&[ty])
                .prop("operandSegmentSizes", segments)
                .prop("static_high", lows)
                .prop("static_low", lows)
                .regions(1),
        );
        let region = self.out.region_of(p, 0);
        let b = self.out.add_block(region, &vec![index; shape.len()]);
        OpSpec::new("tensor.yield").operands(&[zero]).build(self.out, Some(b));
        (self.out.result(p), padded, *elem)
    }

    /// `x` as an `arith.constant` of element type `e`.
    fn constant(&mut self, x: f64, e: Elem) -> ValueId {
        let attr = match e.class {
            Class::Float => self.out.float_attr(&float_text(x), e.ty),
            Class::Int if e.bits == 1 => self.out.bool_attr(x != 0.0),
            Class::Int => self.out.int_attr(x as i64, e.ty),
        };
        let c = self.add(OpSpec::new("arith.constant").results(&[e.ty]).prop("value", attr));
        self.out.result(c)
    }

    /// `v` of element type `from` as `to`, with the `arith` cast that
    /// converts it.
    fn convert(&mut self, v: ValueId, from: Elem, to: Elem) -> ValueId {
        if from.ty == to.ty && from.signed == to.signed {
            return v;
        }
        let op = match (from.class, to.class) {
            (Class::Float, Class::Float) if from.bits < to.bits => "arith.extf",
            (Class::Float, Class::Float) if from.bits > to.bits => "arith.truncf",
            (Class::Float, Class::Float) => return v,
            (Class::Int, Class::Float) if from.signed => "arith.sitofp",
            (Class::Int, Class::Float) => "arith.uitofp",
            (Class::Float, Class::Int) if to.signed => "arith.fptosi",
            (Class::Float, Class::Int) => "arith.fptoui",
            (Class::Int, Class::Int) if from.bits < to.bits && from.signed => "arith.extsi",
            (Class::Int, Class::Int) if from.bits < to.bits => "arith.extui",
            (Class::Int, Class::Int) if from.bits > to.bits => "arith.trunci",
            (Class::Int, Class::Int) => return v,
        };
        let c = self.add(OpSpec::new(op).operands(&[v]).results(&[to.ty]));
        self.out.result(c)
    }
}

/// An argument of a description's body, before the output.
enum Arg {
    /// The element of input `k`.
    Input(usize),
    /// A constant number.
    Scalar(f64),
}

/// The map reading an input of `shape` broadcast to `out`: its dimensions
/// line up with the last ones, and one of size 1 is repeated (`0`).
fn broadcast_map(shape: &[u64], out: &[u64]) -> Result<Map, String> {
    if shape.len() > out.len() {
        return Err(format!("{shape:?} does not broadcast to {out:?}"));
    }
    let skip = out.len() - shape.len();
    let mut results = Vec::new();
    for (k, &s) in shape.iter().enumerate() {
        let o = out[skip + k];
        results.push(if s == o {
            Expr::Dim(skip + k)
        } else if s == 1 {
            Expr::Const(0)
        } else {
            return Err(format!("{shape:?} does not broadcast to {out:?}"));
        });
    }
    Ok(Map { dims: out.len(), syms: 0, results })
}

/// A dimension number, negative counting from the end.
fn dim(d: i64, rank: usize) -> Result<usize, String> {
    let r = if d < 0 { d + rank as i64 } else { d };
    if r < 0 || r as usize >= rank.max(1) {
        return Err(format!("dimension {d} is out of range for rank {rank}"));
    }
    Ok(r as usize)
}

fn affine_of(m: &Module, attr: AttrId) -> Result<Map, String> {
    match m.attr(m.resolve_attr(attr)) {
        Attr::Builtin { keyword: "affine_map", body, .. } => Map::parse(&body[1..body.len() - 1]),
        _ => Err(format!("expected an affine map, found {}", crate::printer::attr_text(m, attr))),
    }
}

/// `[[a, b], [c, d]]`
fn int_pairs(m: &Module, attr: AttrId) -> Option<Vec<(i64, i64)>> {
    let Attr::Array(es) = m.attr(attr) else { return None };
    es.iter()
        .map(|&e| match m.int_list(e).as_deref() {
            Some(&[a, b]) => Some((a, b)),
            _ => None,
        })
        .collect()
}

#[cfg(test)]
mod tests {
    #[test]
    fn descriptions_read() {
        let d = super::descriptions().unwrap();
        assert!(d.entries.len() > 20);
    }
}
