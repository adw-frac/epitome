//! `linalg` on buffers to loops, as upstream's `convert-linalg-to-loops`
//! does: each `linalg.generic` and `linalg.fill` becomes a nest of
//! `scf.for`, one loop per dimension of its iteration space, outermost
//! first, whose body loads the inputs (`memref.load`), runs the
//! operation's body, and stores the result (`memref.store`). An index
//! that is not just a loop's is an `affine.apply`. Everything else is
//! copied.

use std::collections::HashMap;

use crate::affine::{Expr, Map};
use crate::build::OpSpec;
use crate::ir::*;

/// Lowers every `linalg` operation in `src` to loops.
pub fn run(src: &Module) -> Result<Module, String> {
    let mut out = src.empty_like();
    let mut map = HashMap::new();
    for top in src.top_ops().collect::<Vec<_>>() {
        copy(src, top, &mut out, None, &mut map)?;
    }
    Ok(out)
}

/// Copies `op`, with its regions, lowering the `linalg` operations in them.
fn copy(
    src: &Module,
    op: OpId,
    out: &mut Module,
    block: Option<BlockId>,
    map: &mut HashMap<ValueId, ValueId>,
) -> Result<(), String> {
    match src.op_name(op) {
        "linalg.generic" | "linalg.fill" => {
            let block = block.ok_or("a linalg operation outside a function")?;
            Loops { src, out, map }.lower(op, block).map_err(|e| format!("{}: {e}", src.op_name(op)))
        }
        "tm_tensor.scan" => {
            let block = block.ok_or("a scan outside a function")?;
            Loops { src, out, map }.scan(op, block).map_err(|e| format!("{}: {e}", src.op_name(op)))
        }
        _ => {
            // The operation with empty regions, then each region's blocks
            // copied by this function, so that nested operations are lowered.
            let o = &src.ops[op.index()];
            let stripped = {
                let mut m = OpSpec::new(src.op_name(op))
                    .operands(
                        &o.operands
                            .iter()
                            .map(|v| map.get(v).copied().ok_or("an operand from outside"))
                            .collect::<Result<Vec<_>, _>>()?,
                    )
                    .results(&o.results.iter().map(|&r| src.value_type(r)).collect::<Vec<_>>())
                    .regions(o.regions.len())
                    .loc(o.loc);
                if let Some(Attr::Dict(es)) = o.properties.map(|p| src.attr(p)) {
                    for (k, v) in es {
                        m = m.prop(k, *v);
                    }
                }
                if let Some(Attr::Dict(es)) = o.attrs.map(|a| src.attr(a)) {
                    for (k, v) in es {
                        m = m.attr(k, *v);
                    }
                }
                m.build(out, block)
            };
            for (&old, &new) in o.results.iter().zip(&out.ops[stripped.index()].results.clone()) {
                map.insert(old, new);
            }
            for (k, &r) in o.regions.iter().enumerate() {
                let region = out.region_of(stripped, k);
                let blocks = src.regions[r.index()].blocks.clone();
                let mut new_blocks = Vec::new();
                for &b in &blocks {
                    let types: Vec<TypeId> = src.blocks[b.index()].args.iter().map(|&a| src.value_type(a)).collect();
                    let nb = out.add_block(region, &types);
                    for (&a, &n) in src.blocks[b.index()].args.iter().zip(&out.blocks[nb.index()].args.clone()) {
                        map.insert(a, n);
                    }
                    new_blocks.push(nb);
                }
                for (&b, &nb) in blocks.iter().zip(&new_blocks) {
                    for &inner in &src.blocks[b.index()].ops {
                        copy(src, inner, out, Some(nb), map)?;
                        if !src.ops[inner.index()].successors.is_empty() {
                            return Err("branches between blocks are not supported here".into());
                        }
                    }
                }
            }
            Ok(())
        }
    }
}

struct Loops<'a> {
    src: &'a Module,
    out: &'a mut Module,
    map: &'a mut HashMap<ValueId, ValueId>,
}

impl Loops<'_> {
    fn index_const(&mut self, block: BlockId, v: i64) -> ValueId {
        let index = self.out.index_type();
        let attr = self.out.int_attr(v, index);
        let c = OpSpec::new("arith.constant").results(&[index]).prop("value", attr).build(self.out, Some(block));
        self.out.result(c)
    }

    /// `scf.for %iv = 0 to n step 1`, at the end of `block`; returns the
    /// loop's body block and its induction variable.
    fn for_loop(&mut self, block: BlockId, n: u64) -> (BlockId, ValueId) {
        let lb = self.index_const(block, 0);
        let ub = self.index_const(block, n as i64);
        let step = self.index_const(block, 1);
        let f = OpSpec::new("scf.for").operands(&[lb, ub, step]).regions(1).build(self.out, Some(block));
        let index = self.out.index_type();
        let region = self.out.region_of(f, 0);
        let body = self.out.add_block(region, &[index]);
        let iv = self.out.blocks[body.index()].args[0];
        (body, iv)
    }

    fn lower(&mut self, op: OpId, block: BlockId) -> Result<(), String> {
        let src = self.src;
        let o = &src.ops[op.index()];
        let operands: Vec<ValueId> = o
            .operands
            .iter()
            .map(|v| self.map.get(v).copied().ok_or("an operand from outside"))
            .collect::<Result<_, _>>()?;
        let n_ins = crate::bufferize::inputs_of(src, op);
        let (ins, outs) = operands.split_at(n_ins);
        let &dest = outs.first().ok_or("no output")?;
        let (out_shape, _) = self.out.shaped(self.out.value_type(dest)).ok_or("an output of unknown shape")?;

        // The maps, and the size of each loop.
        let maps: Vec<Map> = if src.op_name(op) == "linalg.fill" {
            vec![Map { dims: out_shape.len(), syms: 0, results: Vec::new() }, Map::identity(out_shape.len())]
        } else {
            let list = src.op_attr(op, "indexing_maps").ok_or("no indexing_maps")?;
            let Attr::Array(ms) = src.attr(src.resolve_attr(list)) else {
                return Err("indexing_maps is not a list".into());
            };
            ms.iter()
                .map(|&m| match src.attr(src.resolve_attr(m)) {
                    Attr::Builtin { keyword: "affine_map", body, .. } => Map::parse(&body[1..body.len() - 1]),
                    _ => Err("an indexing map that is not an affine map".to_string()),
                })
                .collect::<Result<_, _>>()?
        };
        if maps.len() != operands.len() {
            return Err(format!("{} maps for {} operands", maps.len(), operands.len()));
        }
        let n = maps[0].dims;
        let mut sizes = vec![None; n];
        for (k, (&v, m)) in operands.iter().zip(&maps).enumerate() {
            if src.op_name(op) == "linalg.fill" && k == 0 {
                continue;
            }
            let (shape, _) = self.out.shaped(self.out.value_type(v)).ok_or("an operand of unknown shape")?;
            for (r, &s) in shape.iter().enumerate() {
                if let Some(d) = m.dim_of(r) {
                    sizes[d].get_or_insert(s);
                }
            }
        }
        let sizes: Vec<u64> = sizes
            .into_iter()
            .enumerate()
            .map(|(d, s)| s.ok_or(format!("no operand gives the size of d{d}")))
            .collect::<Result<_, _>>()?;

        // The loops, outermost first.
        let mut at = block;
        let mut ivs = Vec::new();
        for &s in &sizes {
            let (body, iv) = self.for_loop(at, s);
            ivs.push(iv);
            at = body;
        }

        // Loads, the body, and the store.
        let mut args = Vec::new();
        for (k, &v) in ins.iter().enumerate() {
            if src.op_name(op) == "linalg.fill" {
                args.push(v);
                continue;
            }
            let idx = self.indices(at, &maps[k], &ivs);
            let elem = self.out.shaped(self.out.value_type(v)).map(|s| s.1).ok_or("an input of unknown shape")?;
            let mut operands = vec![v];
            operands.extend(idx);
            let l = OpSpec::new("memref.load").operands(&operands).results(&[elem]).build(self.out, Some(at));
            args.push(self.out.result(l));
        }
        let out_idx: Vec<Vec<ValueId>> =
            (0..outs.len()).map(|k| self.indices(at, &maps[ins.len() + k], &ivs)).collect();
        let body = src.regions[o.regions[0].index()].blocks[0];
        let bargs = &src.blocks[body.index()].args;
        for (&b, &a) in bargs.iter().zip(&args) {
            self.map.insert(b, a);
        }
        for (k, &out) in outs.iter().enumerate() {
            // An output's element, loaded only if the body reads it.
            let Some(&out_arg) = bargs.get(ins.len() + k) else { continue };
            let read = src.blocks[body.index()].ops.iter().any(|&b| src.ops[b.index()].operands.contains(&out_arg));
            if read {
                let elem = self.out.value_type(out);
                let elem = self.out.shaped(elem).map(|s| s.1).ok_or("an output of unknown shape")?;
                let mut operands = vec![out];
                operands.extend(out_idx[k].iter().copied());
                let l = OpSpec::new("memref.load").operands(&operands).results(&[elem]).build(self.out, Some(at));
                let v = self.out.result(l);
                self.map.insert(out_arg, v);
            }
        }
        let mut stored = false;
        for &inner in &src.blocks[body.index()].ops {
            if src.op_name(inner) == "linalg.yield" {
                for (k, y) in src.ops[inner.index()].operands.iter().enumerate() {
                    let v = *self.map.get(y).ok_or("a yield of an unknown value")?;
                    let &out = outs.get(k).ok_or("more values yielded than outputs")?;
                    let mut operands = vec![v, out];
                    operands.extend(out_idx[k].iter().copied());
                    OpSpec::new("memref.store").operands(&operands).build(self.out, Some(at));
                }
                stored = true;
                break;
            }
            if src.op_name(inner) == "linalg.index" {
                // The induction variable of loop `dim`.
                let d = src.op_attr(inner, "dim").and_then(|a| src.int_of(a)).ok_or("linalg.index without dim")?;
                let iv = *ivs.get(d as usize).ok_or("linalg.index of a loop that is not there")?;
                self.map.insert(src.ops[inner.index()].results[0], iv);
                continue;
            }
            copy(src, inner, self.out, Some(at), self.map)?;
        }
        if !stored {
            return Err("a body without linalg.yield".into());
        }

        // Each loop's body ends in `scf.yield`, innermost first. A
        // zero-dimensional operation has no loops.
        let mut b = at;
        while !ivs.is_empty() {
            OpSpec::new("scf.yield").build(self.out, Some(b));
            let region = self.out.blocks[b.index()].parent;
            let f = self.out.regions[region.index()].parent.expect("a loop");
            match self.out.ops[f.index()].parent {
                Some(p) if p != block => b = p,
                _ => break,
            }
        }
        Ok(())
    }

    /// `tm_tensor.scan` on buffers: along dimension `dim` of the input, each
    /// output element is the accumulator combined (by the body) with the
    /// input's element, and the accumulator becomes it; `inclusive` stores
    /// the combined value, otherwise the one before. The accumulator buffer
    /// has the input's shape without `dim`, and holds the starting value.
    fn scan(&mut self, op: OpId, block: BlockId) -> Result<(), String> {
        let src = self.src;
        let o = &src.ops[op.index()];
        let operands: Vec<ValueId> = o
            .operands
            .iter()
            .map(|v| self.map.get(v).copied().ok_or("an operand from outside"))
            .collect::<Result<_, _>>()?;
        let [input, output, acc] = operands[..] else { return Err("expected three operands".into()) };
        let dim = src.op_attr(op, "dimension").and_then(|a| src.int_of(a)).ok_or("no dimension")? as usize;
        let inclusive = matches!(src.op_attr(op, "inclusive").map(|a| src.attr(a)), Some(Attr::Bool(true)));
        let (shape, elem) = self.out.shaped(self.out.value_type(input)).ok_or("an input of unknown shape")?;
        if dim >= shape.len() {
            return Err("the dimension is out of range".into());
        }
        // The other dimensions outside, the scanned one innermost.
        let mut order: Vec<usize> = (0..shape.len()).filter(|&d| d != dim).collect();
        order.push(dim);
        let mut at = block;
        let mut ivs = vec![None; shape.len()];
        for &d in &order {
            let (body, iv) = self.for_loop(at, shape[d]);
            ivs[d] = Some(iv);
            at = body;
        }
        let ivs: Vec<ValueId> = ivs.into_iter().map(Option::unwrap).collect();
        let acc_idx: Vec<ValueId> = (0..shape.len()).filter(|&d| d != dim).map(|d| ivs[d]).collect();
        let load = |l: &mut Self, buffer: ValueId, idx: &[ValueId]| {
            let mut operands = vec![buffer];
            operands.extend_from_slice(idx);
            let ld = OpSpec::new("memref.load").operands(&operands).results(&[elem]).build(l.out, Some(at));
            l.out.result(ld)
        };
        let a = load(self, acc, &acc_idx);
        let x = load(self, input, &ivs);
        let body = src.regions[o.regions[0].index()].blocks[0];
        let bargs = &src.blocks[body.index()].args;
        if bargs.len() != 2 {
            return Err("a body of two arguments is expected".into());
        }
        self.map.insert(bargs[0], a);
        self.map.insert(bargs[1], x);
        let mut combined = None;
        for &inner in &src.blocks[body.index()].ops {
            if src.op_name(inner) == "tm_tensor.yield" {
                combined =
                    Some(*self.map.get(&src.ops[inner.index()].operands[0]).ok_or("a yield of an unknown value")?);
                break;
            }
            copy(src, inner, self.out, Some(at), self.map)?;
        }
        let combined = combined.ok_or("a body without tm_tensor.yield")?;
        let stored = if inclusive { combined } else { a };
        let mut operands = vec![stored, output];
        operands.extend_from_slice(&ivs);
        OpSpec::new("memref.store").operands(&operands).build(self.out, Some(at));
        let mut operands = vec![combined, acc];
        operands.extend_from_slice(&acc_idx);
        OpSpec::new("memref.store").operands(&operands).build(self.out, Some(at));
        self.close_loops(at, block, shape.len());
        Ok(())
    }

    /// Ends each loop's body from `at` outwards with `scf.yield`, up to
    /// `block`, for `n` loops.
    fn close_loops(&mut self, at: BlockId, block: BlockId, n: usize) {
        let mut b = at;
        for _ in 0..n {
            OpSpec::new("scf.yield").build(self.out, Some(b));
            let region = self.out.blocks[b.index()].parent;
            let f = self.out.regions[region.index()].parent.expect("a loop");
            match self.out.ops[f.index()].parent {
                Some(p) if p != block => b = p,
                _ => break,
            }
        }
    }

    /// The indices map `m` gives at the loops' induction variables: a
    /// loop's own variable, a constant, or an `affine.apply` of the loops
    /// it uses.
    fn indices(&mut self, block: BlockId, m: &Map, ivs: &[ValueId]) -> Vec<ValueId> {
        let mut out = Vec::new();
        for e in &m.results {
            out.push(match e {
                Expr::Dim(d) => ivs[*d],
                Expr::Const(c) => self.index_const(block, *c),
                _ => {
                    // Only the dimensions the expression uses, renumbered.
                    let mut used = Vec::new();
                    dims_of(e, &mut used);
                    used.sort_unstable();
                    used.dedup();
                    let renumber = |d: usize| used.iter().position(|&u| u == d).unwrap();
                    let e2 = map_dims(e, &renumber);
                    let map = Map { dims: used.len(), syms: 0, results: vec![e2] };
                    let attr = self.out.affine_map_attr(&map.to_string());
                    let index = self.out.index_type();
                    let operands: Vec<ValueId> = used.iter().map(|&d| ivs[d]).collect();
                    let a = OpSpec::new("affine.apply")
                        .operands(&operands)
                        .results(&[index])
                        .prop("map", attr)
                        .build(self.out, Some(block));
                    self.out.result(a)
                }
            });
        }
        out
    }
}

fn dims_of(e: &Expr, out: &mut Vec<usize>) {
    match e {
        Expr::Dim(d) => out.push(*d),
        Expr::Sym(_) | Expr::Const(_) => {}
        Expr::Add(a, b) | Expr::Mul(a, b) | Expr::FloorDiv(a, b) | Expr::CeilDiv(a, b) | Expr::Mod(a, b) => {
            dims_of(a, out);
            dims_of(b, out);
        }
    }
}

fn map_dims(e: &Expr, f: &dyn Fn(usize) -> usize) -> Expr {
    let b = |x: &Expr| Box::new(map_dims(x, f));
    match e {
        Expr::Dim(d) => Expr::Dim(f(*d)),
        Expr::Sym(_) | Expr::Const(_) => e.clone(),
        Expr::Add(x, y) => Expr::Add(b(x), b(y)),
        Expr::Mul(x, y) => Expr::Mul(b(x), b(y)),
        Expr::FloorDiv(x, y) => Expr::FloorDiv(b(x), b(y)),
        Expr::CeilDiv(x, y) => Expr::CeilDiv(b(x), b(y)),
        Expr::Mod(x, y) => Expr::Mod(b(x), b(y)),
    }
}
