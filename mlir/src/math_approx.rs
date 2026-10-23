//! `math` functions as arithmetic, as upstream's polynomial
//! approximations do: `math.exp` of `f32`, or of a vector of them, becomes
//! a few multiplies and adds, with no call to the C library, so that it
//! can be vectorized.
//!
//! e^x = 2^k e^r, with k = x / ln 2 rounded to the nearest integer and
//! r = x - k ln 2 (ln 2 in two parts, so that r is exact), |r| <= ln 2 / 2.
//! e^r is the polynomial of Cephes' `expf`, good to about an ulp; 2^k is k
//! put in a float's exponent. k is rounded by adding 1.5 * 2^23, which
//! leaves k in the low bits of the sum. x is clamped first, to where 2^k
//! is a normal float: e^x underflows to about 1.2e-38 rather than 0 below
//! -87.3, and stops at about 1.7e38 above 88.
//!
//! `math.tanh` of `f32` likewise: for |x| below 1/4, the odd Taylor series
//! to x^9 (the next term is under a hundredth of an ulp there); above, 1 -
//! 2 / (e^2|x| + 1), with e^2|x| as above, which loses no more than a few
//! ulps to the subtraction at 1/4 and none further out; |x| stops at 9,
//! where tanh is 1 to within half an ulp. The sign is x's, so tanh(-0) is
//! -0, and a NaN stays one.

use std::collections::HashMap;

use crate::build::OpSpec;
use crate::ir::*;

/// Expands the `math` operations it can in `src`.
pub fn run(src: &Module) -> Result<Module, String> {
    let mut out = src.empty_like();
    let mut map = HashMap::new();
    for top in src.top_ops().collect::<Vec<_>>() {
        copy(src, top, &mut out, None, &mut map)?;
    }
    Ok(out)
}

fn copy(
    src: &Module,
    op: OpId,
    out: &mut Module,
    block: Option<BlockId>,
    map: &mut HashMap<ValueId, ValueId>,
) -> Result<(), String> {
    let o = &src.ops[op.index()];
    if src.op_name(op) == "math.exp"
        && let Some(block) = block
        && f32_lanes(src, src.value_type(o.results[0])).is_some()
    {
        let x = *map.get(&o.operands[0]).ok_or("an operand from outside")?;
        let r = Expand { out, block, ty: src.value_type(o.results[0]) }.exp(x);
        map.insert(o.results[0], r);
        return Ok(());
    }
    if src.op_name(op) == "math.tanh"
        && let Some(block) = block
        && f32_lanes(src, src.value_type(o.results[0])).is_some()
    {
        let x = *map.get(&o.operands[0]).ok_or("an operand from outside")?;
        let r = Expand { out, block, ty: src.value_type(o.results[0]) }.tanh(x);
        map.insert(o.results[0], r);
        return Ok(());
    }
    if o.regions.is_empty() {
        out.clone_op(src, op, block, map)?;
        return Ok(());
    }
    let operands = o
        .operands
        .iter()
        .map(|v| map.get(v).copied().ok_or("an operand from outside"))
        .collect::<Result<Vec<_>, _>>()?;
    let results: Vec<TypeId> = o.results.iter().map(|&r| src.value_type(r)).collect();
    let mut spec = OpSpec::new(src.op_name(op))
        .operands(&operands)
        .results(&results)
        .successors(&o.successors)
        .regions(o.regions.len())
        .loc(o.loc);
    if let Some(Attr::Dict(es)) = o.properties.map(|p| src.attr(p)) {
        for (k, v) in es {
            spec = spec.prop(k, *v);
        }
    }
    if let Some(Attr::Dict(es)) = o.attrs.map(|a| src.attr(a)) {
        for (k, v) in es {
            spec = spec.attr(k, *v);
        }
    }
    let new = spec.build(out, block);
    for (&old, &n) in o.results.iter().zip(&out.ops[new.index()].results.clone()) {
        map.insert(old, n);
    }
    for (k, &r) in o.regions.iter().enumerate() {
        let region = out.region_of(new, k);
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
        if blocks.len() > 1 {
            return Err("branches between blocks are not supported here".into());
        }
        for (&b, &nb) in blocks.iter().zip(&new_blocks) {
            for &inner in &src.blocks[b.index()].ops {
                copy(src, inner, out, Some(nb), map)?;
            }
        }
    }
    Ok(())
}

/// `None` unless `ty` is `f32` or a one-dimensional vector of `f32`; then
/// the vector's length, if it is one.
fn f32_lanes(m: &Module, ty: TypeId) -> Option<Option<u64>> {
    match m.ty(m.resolve_type(ty)) {
        Type::Float("f32") => Some(None),
        Type::Vector { dims, elem } if dims.len() == 1 && !dims[0].1 && matches!(m.ty(*elem), Type::Float("f32")) => {
            Some(Some(dims[0].0))
        }
        _ => None,
    }
}

struct Expand<'a> {
    out: &'a mut Module,
    block: BlockId,
    /// `f32` or `vector<N x f32>`.
    ty: TypeId,
}

impl Expand<'_> {
    /// The integer type of the same shape: `i32` or `vector<N x i32>`.
    fn int_ty(&mut self) -> TypeId {
        let i32t = self.out.int_type(32);
        match self.out.ty(self.ty).clone() {
            Type::Vector { dims, .. } => self.out.intern_type(Type::Vector { dims, elem: i32t }),
            _ => i32t,
        }
    }

    fn constant(&mut self, ty: TypeId, text: String) -> ValueId {
        let attr = match self.out.ty(ty) {
            Type::Vector { .. } => {
                self.out.intern_attr(Attr::Builtin { keyword: "dense", body: format!("<{text}>"), ty: Some(ty) })
            }
            Type::Float(_) => self.out.float_attr(&text, ty),
            _ => self.out.int_attr(text.parse().unwrap(), ty),
        };
        let c = OpSpec::new("arith.constant").results(&[ty]).prop("value", attr).build(self.out, Some(self.block));
        self.out.result(c)
    }

    /// `f` exactly: nine significant digits tell every `f32` apart.
    fn float(&mut self, f: f32) -> ValueId {
        self.constant(self.ty, format!("{f:.8e}"))
    }

    fn op(&mut self, name: &str, args: &[ValueId], ty: TypeId) -> ValueId {
        let mut spec = OpSpec::new(name).operands(args).results(&[ty]);
        if name.ends_with('f') && name.starts_with("arith.") {
            let fm = self.out.dialect_attr("arith.fastmath", Some("<none>"));
            spec = spec.prop("fastmath", fm);
        }
        if matches!(name, "arith.addi" | "arith.subi" | "arith.shli") {
            let flags = self.out.dialect_attr("arith.overflow", Some("<none>"));
            spec = spec.prop("overflowFlags", flags);
        }
        let o = spec.build(self.out, Some(self.block));
        self.out.result(o)
    }

    /// a * b + c, rounded once.
    fn fma(&mut self, a: ValueId, b: ValueId, c: ValueId) -> ValueId {
        let fm = self.out.dialect_attr("arith.fastmath", Some("<none>"));
        let o = OpSpec::new("math.fma")
            .operands(&[a, b, c])
            .results(&[self.ty])
            .prop("fastmath", fm)
            .build(self.out, Some(self.block));
        self.out.result(o)
    }

    fn f(&mut self, name: &str, a: ValueId, b: ValueId) -> ValueId {
        self.op(name, &[a, b], self.ty)
    }

    /// The boolean type of the same shape: `i1` or `vector<N x i1>`.
    fn bool_ty(&mut self) -> TypeId {
        let i1 = self.out.int_type(1);
        match self.out.ty(self.ty).clone() {
            Type::Vector { dims, .. } => self.out.intern_type(Type::Vector { dims, elem: i1 }),
            _ => i1,
        }
    }

    /// `a < b`, ordered (false if either is a NaN).
    fn less(&mut self, a: ValueId, b: ValueId) -> ValueId {
        let bty = self.bool_ty();
        let fm = self.out.dialect_attr("arith.fastmath", Some("<none>"));
        let i64t = self.out.int_type(64);
        let olt = self.out.int_attr(4, i64t);
        let o = OpSpec::new("arith.cmpf")
            .operands(&[a, b])
            .results(&[bty])
            .prop("fastmath", fm)
            .prop("predicate", olt)
            .build(self.out, Some(self.block));
        self.out.result(o)
    }

    fn select(&mut self, c: ValueId, a: ValueId, b: ValueId) -> ValueId {
        self.op("arith.select", &[c, a, b], self.ty)
    }

    fn tanh(&mut self, x: ValueId) -> ValueId {
        let ity = self.int_ty();
        let a = self.op("math.absf", &[x], self.ty);
        // |x| at most 9; a NaN is not more than 9, and stays.
        let nine = self.float(9.0);
        let over = self.less(nine, a);
        let a = self.select(over, nine, a);
        // 1 - 2 / (e^2a + 1).
        let a2 = self.f("arith.addf", a, a);
        let e = self.exp(a2);
        let one = self.float(1.0);
        let e1 = self.f("arith.addf", e, one);
        let two = self.float(2.0);
        let q = self.f("arith.divf", two, e1);
        let far = self.f("arith.subf", one, q);
        // a - a^3/3 + 2a^5/15 - 17a^7/315 + 62a^9/2835.
        let s = self.f("arith.mulf", a, a);
        let coeffs = [62.0 / 2835.0, -17.0 / 315.0, 2.0 / 15.0, -1.0 / 3.0];
        let mut p = self.float(coeffs[0]);
        for &c in &coeffs[1..] {
            let c = self.float(c);
            p = self.fma(p, s, c);
        }
        let p = self.f("arith.mulf", p, s);
        let near = self.fma(a, p, a);
        let quarter = self.float(0.25);
        let small = self.less(a, quarter);
        let t = self.select(small, near, far);
        // x's sign.
        let tb = self.op("arith.bitcast", &[t], ity);
        let xb = self.op("arith.bitcast", &[x], ity);
        let sign = self.constant(ity, (i32::MIN).to_string());
        let xs = self.op("arith.andi", &[xb, sign], ity);
        let r = self.op("arith.ori", &[tb, xs], ity);
        self.op("arith.bitcast", &[r], self.ty)
    }

    fn exp(&mut self, x: ValueId) -> ValueId {
        let ity = self.int_ty();
        let (lo, hi) = (self.float(-87.336_55), self.float(88.0));
        let x = self.f("arith.maximumf", x, lo);
        let x = self.f("arith.minimumf", x, hi);
        // k = round(x / ln 2), as a float and as an integer.
        let log2e = self.float(std::f32::consts::LOG2_E);
        let magic = self.float(12_582_912.0); // 1.5 * 2^23
        let t = self.fma(x, log2e, magic);
        let k = self.f("arith.subf", t, magic);
        let tbits = self.op("arith.bitcast", &[t], ity);
        let mbits = self.constant(ity, (12_582_912f32.to_bits() as i32).to_string());
        let ki = self.op("arith.subi", &[tbits, mbits], ity);
        // r = x - k ln 2.
        let (ln2_hi, ln2_lo) = (self.float(-0.693_359_4), self.float(2.121_944_4e-4));
        let r = self.fma(k, ln2_hi, x);
        let r = self.fma(k, ln2_lo, r);
        // e^r = 1 + r + r^2 p(r), each step of p a fused multiply-add, as
        // upstream's approximations are written.
        let coeffs = [1.987_569_1e-4, 1.398_199_9e-3, 8.333_452e-3, 4.166_579_6e-2, 1.666_666_5e-1, 5.000_000_1e-1];
        let mut p = self.float(coeffs[0]);
        for &c in &coeffs[1..] {
            let c = self.float(c);
            p = self.fma(p, r, c);
        }
        let r2 = self.f("arith.mulf", r, r);
        let p = self.fma(p, r2, r);
        let one = self.float(1.0);
        let p = self.f("arith.addf", p, one);
        // 2^k: k + 127 in the exponent.
        let bias = self.constant(ity, "127".into());
        let e = self.op("arith.addi", &[ki, bias], ity);
        let shift = self.constant(ity, "23".into());
        let e = self.op("arith.shli", &[e, shift], ity);
        let scale = self.op("arith.bitcast", &[e], self.ty);
        self.f("arith.mulf", p, scale)
    }
}
