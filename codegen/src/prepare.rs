//! Selection form: rewriting a copy of a function so that its IR has the
//! shapes the instruction descriptions' bodies have.
//!
//! - Every `getelementptr` becomes `getelementptr i8, ptr %base, i64 %off`,
//!   with the offset worked out in `i64`: indices sign-extended, scaled by
//!   `shl` for powers of two and `mul` otherwise, constant parts added up.
//! - `switch` becomes a chain of `icmp eq` and conditional branches.
//! - Edges from a block with several successors to a block with phis are
//!   split, so that the phis' copies have somewhere to go.
//! - Calls to intrinsics that do nothing in code (`llvm.lifetime.*`,
//!   `llvm.dbg.*`, `llvm.assume`) are removed.
//! - Comparisons, divisions and right shifts of values narrower than 32
//!   bits are done on 32-bit extensions of them: a narrow value lives in a
//!   W register with its upper bits undefined, so these operations, which
//!   read every bit, need them made right first.
//! - Loads and stores of small structs (`[2 x i64]`) become one per part.
//! - Intrinsics the description has no instruction for are written out:
//!   minimum, maximum and absolute value of narrow integers as a comparison
//!   and a select, and population count as bit arithmetic.
//! - Conversions between floating point and integers narrower than 32
//!   bits go through `i32`; `fcmp one` and `fcmp ueq`, which no single
//!   condition tests after AArch64's `fcmp`, are split into two; a store of
//!   a floating-point constant stores its bits as an integer.
//! - Division and remainder by constants become multiplications and
//!   shifts (see `divconst`).
//! - Integers of other widths below 64 (`i33`, say) are held in the next
//!   register width, with the same rule: masked or sign-extended in place
//!   before an operation that reads their top bits.

use epitome_ir::apint::ApInt;
use epitome_ir::layout::DataLayout;
use epitome_ir::module::*;
use epitome_ir::types::{Type, TypeId};

use crate::target::{Head, Tree, sext};

pub struct Ctx<'a> {
    pub m: &'a mut Module,
    pub dl: &'a DataLayout,
    /// The machine description, for what it says about the machine as a
    /// whole (its vector registers' width, which shuffles it has).
    pub t: &'a crate::target::Target,
    /// The features of the function being compiled.
    pub features: crate::features::Features,
}

impl Ctx<'_> {
    /// The width of the vector registers, or 0 if there are none (or their
    /// feature is off): then vectors are done lane by lane.
    pub fn vector_bits(&self) -> u32 {
        match &self.t.machine.vector_feature {
            Some(f) if !self.features.contains(f) => 0,
            _ => self.t.machine.vector_bits,
        }
    }

    /// Are instruction `i`'s features on?
    pub fn enabled(&self, i: usize) -> bool {
        self.t.instrs[i].features.iter().all(|f| self.features.contains(f))
    }

    /// Is there a pattern, of instructions that are on, with an IR node
    /// `want` accepts?
    pub fn selects_head(&self, want: impl Fn(&Head) -> bool) -> bool {
        self.selects(want)
    }

    /// Is there an instruction for intrinsic `name` whose last operand is
    /// the constant `last` (`llvm.epitome.cmpxchg.i64`'s ordering)?
    pub fn selects_intrinsic_with(&self, name: &str, last: i64) -> bool {
        let Some(id) = self.t.intrinsics.iter().position(|n| n == name) else { return false };
        fn has(t: &Tree, id: usize, last: i64) -> bool {
            match t {
                Tree::Op(Head::Intrinsic(k, _), kids) if *k as usize == id => {
                    matches!(kids.last(), Some(Tree::Lit(v, _)) if *v == last)
                }
                Tree::Op(_, kids) => kids.iter().any(|k| has(k, id, last)),
                _ => false,
            }
        }
        self.t.patterns.iter().any(|p| has(&p.tree, id, last) && p.emit.iter().all(|e| self.enabled(e.instr)))
    }

    fn selects(&self, want: impl Fn(&Head) -> bool) -> bool {
        fn has(t: &Tree, want: &dyn Fn(&Head) -> bool) -> bool {
            match t {
                Tree::Op(h, kids) => want(h) || kids.iter().any(|k| has(k, want)),
                _ => false,
            }
        }
        self.t.patterns.iter().any(|p| has(&p.tree, &want) && p.emit.iter().all(|e| self.enabled(e.instr)))
    }

    /// Is there an instruction for intrinsic `name` (`llvm.ctlz.i64`)?
    pub fn selects_intrinsic(&self, name: &str) -> bool {
        match self.t.intrinsics.iter().position(|n| n == name) {
            Some(id) => self.selects(|h| matches!(h, Head::Intrinsic(k, _) if *k as usize == id)),
            None => false,
        }
    }

    fn i64t(&mut self) -> TypeId {
        self.m.types.int(64)
    }

    fn i8t(&mut self) -> TypeId {
        self.m.types.int(8)
    }

    pub fn int(&mut self, ty: TypeId, v: i64) -> Value {
        let bits = match self.m.types.get(ty) {
            Type::Int(b) => *b,
            _ => 64,
        };
        Value::Const(self.m.consts.intern(Constant { ty, kind: ConstKind::Int(ApInt::from_i64(bits, v)) }))
    }

    pub fn const_int(&self, v: Value) -> Option<i64> {
        let Value::Const(c) = v else { return None };
        let k = self.m.constant(c);
        match (&k.kind, self.m.types.get(k.ty)) {
            (ConstKind::Int(a), Type::Int(b)) => Some(sext(a.low_u64(), *b)),
            _ => None,
        }
    }

    pub fn value_ty(&self, f: &Function, v: Value) -> TypeId {
        match v {
            Value::Local(x) => f.locals[x.index()].ty,
            Value::Const(c) => self.m.constant(c).ty,
            Value::Metadata(_) => unreachable!(),
        }
    }

    pub fn size_of(&self, ty: TypeId) -> Result<u64, String> {
        self.dl.alloc_size(&self.m.types, ty).ok_or_else(|| "a type without a size".to_string())
    }
}

/// Puts a copy of `f` into selection form.
pub fn prepare(cx: &mut Ctx, f: &Function, fname: &str) -> Result<Function, String> {
    let mut f = f.clone();
    thread_locals(cx, &mut f);
    one_lane_vectors(cx, &mut f);
    bit_masks(cx, &mut f);
    variable_lanes(cx, &mut f);
    vector_int_bitcasts(cx, &mut f);
    bitcast_round_trips(cx, &mut f);
    memset_patterns(cx, &mut f);
    crate::atomics::expand_atomics(cx, &mut f).map_err(|e| format!("@{fname}: {e}"))?;
    expand_overflow(cx, &mut f).map_err(|e| format!("@{fname}: {e}"))?;
    wide_intrinsics(cx, &mut f);
    crate::wide_vectors::scalarize(cx, &mut f).map_err(|e| format!("@{fname}: {e}"))?;
    crate::wide::split_wide(cx, &mut f).map_err(|e| format!("@{fname}: {e}"))?;
    crate::aggregates::scalarize(cx, &mut f).map_err(|e| format!("@{fname}: {e}"))?;
    split_struct_selects(cx, &mut f).map_err(|e| format!("@{fname}: {e}"))?;
    split_struct_phis(cx, &mut f).map_err(|e| format!("@{fname}: {e}"))?;
    check(cx, &f, fname)?;
    lower_dynamic_allocas(cx, &mut f)?;
    drop_noop_calls(cx, &mut f);
    lower_switches(cx, &mut f);
    expand_intrinsics(cx, &mut f);
    lane_indices(cx, &mut f);
    split_aggregate_memory(cx, &mut f);
    bool_memory(cx, &mut f);
    expand_small_mem_ops(cx, &mut f);
    crate::legalize::legalize_vectors(cx, &mut f).map_err(|e| format!("@{fname}: {e}"))?;
    // Lanes of masks legalisation leaves (it handles those of split masks,
    // at their comparisons' widths; before it, this would get in its way).
    mask_lanes(cx, &mut f);
    // Element-wise intrinsics split into scalars expand as scalars do.
    expand_intrinsics(cx, &mut f);
    sink_addresses(&mut f);
    lower_geps(cx, &mut f)?;
    promote_odd(cx, &mut f)?;
    widen_narrow(cx, &mut f);
    legalize_fp(cx, &mut f)?;
    lower_const_divs(cx, &mut f);
    if cx.t.machine.compare_booleans {
        compare_boolean_branches(cx, &mut f);
    }
    split_phi_edges(&mut f);
    Ok(f)
}

/// Field `k` of struct value `v` (of field type `fty`): a constant's, or
/// an `extractvalue` made in `s`.
fn struct_field(cx: &mut Ctx, s: &mut Seq, v: Value, k: usize, fty: TypeId) -> Result<Value, String> {
    Ok(match v {
        Value::Const(c) => {
            let kind = match &cx.m.constant(c).kind {
                ConstKind::Struct(e) => cx.m.constant(e[k]).kind.clone(),
                k @ (ConstKind::Poison | ConstKind::Undef | ConstKind::Zero) => k.clone(),
                _ => return Err("a struct constant not supported".into()),
            };
            Value::Const(cx.m.consts.intern(Constant { ty: fty, kind }))
        }
        _ => s.op(Op::ExtractValue { aggregate: v, indices: vec![k as u32] }, fty),
    })
}

/// A select of a struct of scalars (`{ ptr, i64 }`, a slice) is a select
/// of each field, and the struct made again of them.
fn split_struct_selects(cx: &mut Ctx, f: &mut Function) -> Result<(), String> {
    let blocks: Vec<BlockId> = f.layout.clone();
    for b in blocks {
        let mut k = 0;
        while k < f.blocks[b.index()].insts.len() {
            let i = f.blocks[b.index()].insts[k];
            // A freeze of an aggregate: in code, a value is what its
            // registers hold, so the freeze is its operand.
            if let Op::Freeze(v) = f.insts[i.index()].op
                && let Some(r) = f.insts[i.index()].result
                && matches!(cx.m.types.get(f.locals[r.index()].ty), Type::Struct { .. } | Type::Array { .. })
            {
                f.replace_uses(Value::Local(r), v);
                f.blocks[b.index()].insts.remove(k);
                continue;
            }
            let Op::Select { fmf, cond, then_value, else_value } = f.insts[i.index()].op.clone() else {
                k += 1;
                continue;
            };
            let r = f.insts[i.index()].result.unwrap();
            let ty = f.locals[r.index()].ty;
            let Type::Struct { fields, .. } = cx.m.types.get(ty).clone() else {
                k += 1;
                continue;
            };
            if fields.iter().any(|t| matches!(cx.m.types.get(*t), Type::Struct { .. } | Type::Array { .. })) {
                k += 1;
                continue;
            }
            let mut s = Seq { f, new: Vec::new() };
            let mut agg = Value::Const(cx.m.consts.intern(Constant { ty, kind: ConstKind::Poison }));
            for (n, &fty) in fields.iter().enumerate() {
                let a = struct_field(cx, &mut s, then_value, n, fty)?;
                let c = struct_field(cx, &mut s, else_value, n, fty)?;
                let v = s.op(Op::Select { fmf, cond, then_value: a, else_value: c }, fty);
                agg = s.op(Op::InsertValue { aggregate: agg, element: v, indices: vec![n as u32] }, ty);
            }
            s.f.replace_uses(Value::Local(r), agg);
            let new = std::mem::take(&mut s.new);
            let n = new.len();
            f.blocks[b.index()].insts.splice(k..=k, new);
            k += n;
        }
    }
    Ok(())
}

/// `llvm.experimental.memset.pattern(dst, pattern, count, volatile)`:
/// `count` stores of `pattern`, one after another from `dst`, as a loop.
fn memset_patterns(cx: &mut Ctx, f: &mut Function) {
    let (i1, i8t, i64t, ptr) = (cx.m.types.int(1), cx.m.types.int(8), cx.m.types.int(64), cx.m.types.ptr(0));
    let mut b = 0;
    'blocks: while b < f.layout.len() {
        let blk = f.layout[b];
        for (k, &i) in f.blocks[blk.index()].insts.iter().enumerate() {
            let Op::Call(call) = &f.insts[i.index()].op else { continue };
            if !callee_name(cx.m, call).is_some_and(|n| n.starts_with("llvm.experimental.memset.pattern.")) {
                continue;
            }
            let (dst, pat, count) = (call.args[0].value, call.args[1].value, call.args[2].value);
            let volatile = cx.const_int(call.args[3].value).is_some_and(|v| v != 0);
            let pty = cx.value_ty(f, pat);
            let size = cx.size_of(pty).unwrap_or(1) as i64;
            let count_ty = cx.value_ty(f, count);
            // blk: count == 0 ? done : lp
            // lp:  n = phi [0, blk], [n + 1, lp]; store pat at dst + n*size
            let lp = f.split_block(blk, k, None);
            let done = f.split_block(lp, 1, None);
            f.blocks[lp.index()].insts.clear();
            let mut s = Seq { f, new: Vec::new() };
            let count = if count_ty == i64t { count } else { s.cast(CastOp::ZExt, count, i64t) };
            let zero = cx.int(i64t, 0);
            let none = s.op(Op::ICmp { pred: ICmpPred::Eq, samesign: false, lhs: count, rhs: zero }, i1);
            let pre = std::mem::take(&mut s.new);
            let phi = s.f.add_inst(Op::Phi { fmf: FastMath::default(), incoming: vec![] }, Some((None, i64t)));
            let n = s.f.result(phi);
            let off = if size > 0 && size & (size - 1) == 0 {
                let sh = cx.int(i64t, i64::from(size.trailing_zeros()));
                s.bin(BinOp::Shl, n, sh, i64t)
            } else {
                let sz = cx.int(i64t, size);
                s.bin(BinOp::Mul, n, sz, i64t)
            };
            let at = s.op(
                Op::Gep { flags: GepFlags::default(), inrange: None, source_ty: i8t, ptr: dst, indices: vec![off] },
                ptr,
            );
            s.op_void(Op::Store { volatile, atomic: None, value: pat, ptr: at, align: None });
            let one = cx.int(i64t, 1);
            let next = s.bin(BinOp::Add, n, one, i64t);
            let more = s.op(Op::ICmp { pred: ICmpPred::Ult, samesign: false, lhs: next, rhs: count }, i1);
            let body = std::mem::take(&mut s.new);
            f.insts[phi.index()].op = Op::Phi { fmf: FastMath::default(), incoming: vec![(zero, blk), (next, lp)] };
            f.blocks[blk.index()].insts.extend(pre);
            f.push_inst(blk, Op::CondBr { cond: none, then_dest: done, else_dest: lp }, None);
            f.blocks[lp.index()].insts.push(phi);
            f.blocks[lp.index()].insts.extend(body);
            f.push_inst(lp, Op::CondBr { cond: more, then_dest: lp, else_dest: done }, None);
            b = f.layout.iter().position(|&x| x == done).unwrap();
            continue 'blocks;
        }
        b += 1;
    }
}

/// A phi of a struct of scalars (a landing pad's `{ ptr, i32 }`, carried
/// to its `resume`) becomes a phi for each field, each value's field
/// extracted at the end of its block, and the struct made again after the
/// phis, as instructions selection keeps aggregates: as their parts.
fn split_struct_phis(cx: &mut Ctx, f: &mut Function) -> Result<(), String> {
    let blocks: Vec<BlockId> = f.layout.clone();
    for b in blocks {
        let phis: Vec<InstId> =
            f.blocks[b.index()].insts.iter().copied().take_while(|&i| f.insts[i.index()].op.is_phi()).collect();
        // A struct an invoke returns, coming into a phi: its fields are
        // taken out on the edge, in a block of its own between the invoke
        // and this one (the invoke ends its block, and they can only be
        // taken once it has returned).
        let mut edges: Vec<BlockId> = Vec::new();
        for &i in &phis {
            let r = f.insts[i.index()].result.unwrap();
            if !matches!(cx.m.types.get(f.locals[r.index()].ty), Type::Struct { .. }) {
                continue;
            }
            let Op::Phi { incoming, .. } = &f.insts[i.index()].op else { unreachable!() };
            for &(v, pred) in incoming {
                let term = f.terminator(pred);
                if term.is_some_and(|t| f.insts[t.index()].result.map(Value::Local) == Some(v))
                    && !edges.contains(&pred)
                {
                    edges.push(pred);
                }
            }
        }
        for pred in edges {
            let e = f.add_block(None);
            let at = f.layout.iter().position(|&x| x == pred).unwrap();
            f.layout.insert(at + 1, e);
            f.push_inst(e, Op::Br(b), None);
            let t = f.terminator(pred).unwrap();
            if let Op::Invoke { normal, .. } = &mut f.insts[t.index()].op
                && *normal == b
            {
                *normal = e;
            }
            f.retarget_phis(b, pred, e);
        }
        let mut rebuilt = Vec::new();
        for &i in &phis {
            let r = f.insts[i.index()].result.unwrap();
            let ty = f.locals[r.index()].ty;
            let Type::Struct { fields, .. } = cx.m.types.get(ty).clone() else { continue };
            if fields.iter().any(|t| matches!(cx.m.types.get(*t), Type::Struct { .. } | Type::Array { .. })) {
                continue;
            }
            let Op::Phi { fmf, incoming } = f.insts[i.index()].op.clone() else { unreachable!() };
            let mut parts = Vec::new();
            for (k, &fty) in fields.iter().enumerate() {
                let mut inc = Vec::new();
                for &(v, pred) in &incoming {
                    let part = match v {
                        Value::Const(c) => {
                            let kind = match &cx.m.constant(c).kind {
                                ConstKind::Struct(e) => cx.m.constant(e[k]).kind.clone(),
                                k @ (ConstKind::Poison | ConstKind::Undef | ConstKind::Zero) => k.clone(),
                                _ => return Err("a phi of a struct constant not supported".into()),
                            };
                            Value::Const(cx.m.consts.intern(Constant { ty: fty, kind }))
                        }
                        _ => {
                            // At the end of the block it comes from, before
                            // its terminator (which must not define it).
                            let insts = &f.blocks[pred.index()].insts;
                            let term = *insts.last().unwrap();
                            if f.insts[term.index()].result.map(Value::Local) == Some(v) {
                                return Err("a phi of a struct an invoke returns".into());
                            }
                            let e = f.add_inst(
                                Op::ExtractValue { aggregate: v, indices: vec![k as u32] },
                                Some((None, fty)),
                            );
                            let n = f.blocks[pred.index()].insts.len();
                            f.blocks[pred.index()].insts.insert(n - 1, e);
                            f.result(e)
                        }
                    };
                    inc.push((part, pred));
                }
                let p = f.add_inst(Op::Phi { fmf, incoming: inc }, Some((None, fty)));
                parts.push(p);
            }
            rebuilt.push((i, r, ty, parts));
        }
        if rebuilt.is_empty() {
            continue;
        }
        let mut new_phis = Vec::new();
        let mut after = Vec::new();
        for (_, r, ty, parts) in rebuilt.iter() {
            let mut s = Seq { f, new: Vec::new() };
            let mut agg = Value::Const(cx.m.consts.intern(Constant { ty: *ty, kind: ConstKind::Poison }));
            for (k, &p) in parts.iter().enumerate() {
                new_phis.push(p);
                let pv = s.f.result(p);
                agg = s.op(Op::InsertValue { aggregate: agg, element: pv, indices: vec![k as u32] }, *ty);
            }
            after.extend(std::mem::take(&mut s.new));
            f.replace_uses(Value::Local(*r), agg);
        }
        let old: Vec<InstId> = rebuilt.iter().map(|x| x.0).collect();
        let insts = &mut f.blocks[b.index()].insts;
        let rest: Vec<InstId> = insts.drain(..).filter(|i| !old.contains(i)).collect();
        let n_phis = rest.iter().take_while(|&&i| f.insts[i.index()].op.is_phi()).count();
        let mut list = rest[..n_phis].to_vec();
        list.extend(new_phis);
        // A landing pad stays first after the phis.
        let mut tail = rest[n_phis..].to_vec();
        let lp = tail.first().is_some_and(|&i| matches!(f.insts[i.index()].op, Op::LandingPad { .. }));
        if lp {
            list.push(tail.remove(0));
        }
        list.extend(after);
        list.extend(tail);
        f.blocks[b.index()].insts = list;
    }
    Ok(())
}

/// The address of a thread-local variable, where the machine reaches them
/// by Mach-O's descriptors (`tlv.hi` and `tlv.lo`): its descriptor's
/// address (`llvm.epitome.tlv`), then a call of the descriptor's first
/// word with it, which returns the variable's address in this thread. (The
/// call keeps more registers than a call need, but is taken as one.)
fn thread_locals(cx: &mut Ctx, f: &mut Function) {
    let darwin = cx.m.triple.as_deref().is_some_and(|t| {
        let t = String::from_utf8_lossy(t);
        t.contains("apple") || t.contains("darwin") || t.contains("macos")
    });
    if !darwin || cx.t.role("tlv.hi").is_none() {
        return;
    }
    let ptr = cx.m.types.ptr(0);
    let blocks: Vec<BlockId> = f.layout.clone();
    for b in blocks {
        let mut k = 0;
        while k < f.blocks[b.index()].insts.len() {
            let i = f.blocks[b.index()].insts[k];
            let Op::Call(call) = &f.insts[i.index()].op else {
                k += 1;
                continue;
            };
            if !callee_name(cx.m, call).is_some_and(|n| n.starts_with("llvm.threadlocal.address.")) {
                k += 1;
                continue;
            }
            let var = call.args[0].value;
            let r = f.insts[i.index()].result.unwrap();
            let mut s = Seq { f, new: Vec::new() };
            let desc = call_intrinsic(cx, &mut s, "llvm.epitome.tlv", vec![var], ptr);
            let get = s.op(Op::Load { volatile: false, atomic: None, ptr: desc, align: Some(8) }, ptr);
            let fn_ty = cx.m.types.intern(Type::Function { ret: ptr, params: vec![ptr], varargs: false });
            let addr = s.op(
                Op::Call(Box::new(Call {
                    tail: TailKind::None,
                    fmf: FastMath::default(),
                    cconv: CallConv::default(),
                    ret_attrs: vec![],
                    addrspace: None,
                    fn_ty,
                    callee: get,
                    args: vec![CallArg { value: desc, attrs: vec![] }],
                    fn_attrs: vec![],
                    bundles: vec![],
                })),
                ptr,
            );
            s.f.replace_uses(Value::Local(r), addr);
            let new = std::mem::take(&mut s.new);
            let n = new.len();
            f.blocks[b.index()].insts.splice(k..=k, new);
            k += n;
        }
    }
}

/// A bitcast back to the type a bitcast came from is the value it started
/// as (the steps above make such pairs: `<1 x i64>` through `<8 x i8>` to
/// `i64` and back).
fn bitcast_round_trips(cx: &mut Ctx, f: &mut Function) {
    let order: Vec<InstId> = f.insts_in_order().collect();
    for i in order {
        let Op::Cast { op: CastOp::BitCast, value: Value::Local(x), .. } = f.insts[i.index()].op else { continue };
        let LocalDef::Inst(d) = f.locals[x.index()].def else { continue };
        let Op::Cast { op: CastOp::BitCast, value: orig, .. } = f.insts[d.index()].op else { continue };
        let r = f.insts[i.index()].result.unwrap();
        if cx.value_ty(f, orig) == f.locals[r.index()].ty {
            f.replace_uses(Value::Local(r), orig);
        }
    }
    // Bitcasts no longer used, until none is (a chain goes link by link).
    loop {
        let mut used = vec![false; f.locals.len()];
        for i in f.insts_in_order() {
            f.insts[i.index()].op.for_each_value(|v| {
                if let Value::Local(x) = v {
                    used[x.index()] = true;
                }
            });
        }
        let dead = |f: &Function, i: InstId| {
            matches!(f.insts[i.index()].op, Op::Cast { op: CastOp::BitCast, .. })
                && f.insts[i.index()].result.is_some_and(|r| !used[r.index()])
        };
        let mut removed = false;
        for b in f.layout.clone() {
            let before = f.blocks[b.index()].insts.len();
            let keep: Vec<InstId> = f.blocks[b.index()].insts.iter().copied().filter(|&i| !dead(f, i)).collect();
            removed |= keep.len() != before;
            f.blocks[b.index()].insts = keep;
        }
        if !removed {
            break;
        }
    }
}

/// Lanes of masks (`<N x i1>`), taken out or put in, through integer
/// lanes: the mask sign-extended (all ones or zeros a lane), the lane
/// taken and truncated; or put in sign-extended, and the vector compared
/// with zero to be a mask again.
fn mask_lanes(cx: &mut Ctx, f: &mut Function) {
    let i1 = cx.m.types.int(1);
    let wide = |cx: &mut Ctx, ty: TypeId| -> Option<(TypeId, TypeId)> {
        let Type::Vector { len, elem, scalable: false } = *cx.m.types.get(ty) else { return None };
        if elem != i1 {
            return None;
        }
        let w = (128 / len).clamp(8, 64);
        let e = cx.m.types.int(w);
        Some((cx.m.types.intern(Type::Vector { len, elem: e, scalable: false }), e))
    };
    let blocks: Vec<BlockId> = f.layout.clone();
    for b in blocks {
        let mut k = 0;
        while k < f.blocks[b.index()].insts.len() {
            let i = f.blocks[b.index()].insts[k];
            let Some(r) = f.insts[i.index()].result else {
                k += 1;
                continue;
            };
            let op = f.insts[i.index()].op.clone();
            let mty = match &op {
                Op::ExtractElement { vector, .. } => cx.value_ty(f, *vector),
                Op::InsertElement { .. } => f.locals[r.index()].ty,
                _ => {
                    k += 1;
                    continue;
                }
            };
            let Some((wt, e)) = wide(cx, mty) else {
                k += 1;
                continue;
            };
            let mut s = Seq { f, new: Vec::new() };
            let v = match op {
                Op::ExtractElement { vector, index } => {
                    let w = s.cast(CastOp::SExt, vector, wt);
                    let x = s.op(Op::ExtractElement { vector: w, index }, e);
                    s.cast(CastOp::Trunc, x, i1)
                }
                Op::InsertElement { vector, element, index } => {
                    let w = s.cast(CastOp::SExt, vector, wt);
                    let x = s.cast(CastOp::SExt, element, e);
                    let w = s.op(Op::InsertElement { vector: w, element: x, index }, wt);
                    let zero = Value::Const(cx.m.consts.intern(Constant { ty: wt, kind: ConstKind::Zero }));
                    s.op(Op::ICmp { pred: ICmpPred::Ne, samesign: false, lhs: w, rhs: zero }, mty)
                }
                _ => unreachable!(),
            };
            s.f.replace_uses(Value::Local(r), v);
            let new = std::mem::take(&mut s.new);
            let n = new.len();
            f.blocks[b.index()].insts.splice(k..=k, new);
            k += n;
        }
    }
}

/// A bitcast of bits to a vector of booleans (`bitcast <8 x i8> to <64 x
/// i1>`, a set of flags), whose lanes are only taken out: each lane is a
/// bit of the bits as an integer, shifted down and truncated.
fn bit_masks(cx: &mut Ctx, f: &mut Function) {
    let i1 = cx.m.types.int(1);
    let order: Vec<InstId> = f.insts_in_order().collect();
    for i in order {
        let Op::Cast { op: CastOp::BitCast, value, .. } = f.insts[i.index()].op else { continue };
        let Some(r) = f.insts[i.index()].result else { continue };
        let Type::Vector { len, elem, scalable: false } = *cx.m.types.get(f.locals[r.index()].ty) else { continue };
        if elem != i1
            || len > 64
            || matches!(cx.m.types.get(cx.value_ty(f, value)), Type::Vector { elem, .. } if *elem == i1)
        {
            continue;
        }
        // Only extractelements of it.
        let mut users = Vec::new();
        let mut other = false;
        for j in f.insts_in_order() {
            let mut uses = false;
            f.insts[j.index()].op.for_each_value(|v| uses |= *v == Value::Local(r));
            if uses {
                match f.insts[j.index()].op {
                    Op::ExtractElement { vector: Value::Local(x), .. } if x == r => users.push(j),
                    _ => other = true,
                }
            }
        }
        if other || users.is_empty() {
            continue;
        }
        let it = cx.m.types.int(len);
        for j in users {
            let Op::ExtractElement { index, .. } = f.insts[j.index()].op else { unreachable!() };
            let jr = f.insts[j.index()].result.unwrap();
            let blk = f.blocks.iter().position(|b| b.insts.contains(&j)).unwrap();
            let k = f.blocks[blk].insts.iter().position(|&x| x == j).unwrap();
            let mut s = Seq { f, new: Vec::new() };
            let bits = s.cast(CastOp::BitCast, value, it);
            let ity = cx.value_ty(s.f, index);
            let idx = match cx.m.types.get(ity) {
                Type::Int(b) if *b > len => s.cast(CastOp::Trunc, index, it),
                Type::Int(b) if *b < len => s.cast(CastOp::ZExt, index, it),
                _ => index,
            };
            let sh = s.bin(BinOp::LShr, bits, idx, it);
            let v = s.cast(CastOp::Trunc, sh, i1);
            let new = std::mem::take(&mut s.new);
            f.replace_uses(Value::Local(jr), v);
            f.blocks[blk].insts.splice(k..=k, new);
        }
    }
}

/// A lane chosen by a value, not a constant (`extractelement <4 x i32> %v,
/// i64 %k`), through memory: the vector stored to a stack slot, and the
/// lane loaded from it (or stored into it, and the vector loaded back).
/// The index is taken modulo the lanes, a power of two, so that one past
/// the end (poison in LLVM) stays in the slot. (Not vectors of `i1`,
/// whose bits memory packs.)
fn variable_lanes(cx: &mut Ctx, f: &mut Function) {
    let (i8t, i64t, ptr) = (cx.m.types.int(8), cx.m.types.int(64), cx.m.types.ptr(0));
    let Some(&entry) = f.layout.first() else { return };
    let mut slots = Vec::new();
    let blocks: Vec<BlockId> = f.layout.clone();
    for b in blocks {
        let mut k = 0;
        while k < f.blocks[b.index()].insts.len() {
            let i = f.blocks[b.index()].insts[k];
            let (vector, index, element) = match f.insts[i.index()].op {
                Op::ExtractElement { vector, index } if cx.const_int(index).is_none() => (vector, index, None),
                Op::InsertElement { vector, element, index } if cx.const_int(index).is_none() => {
                    (vector, index, Some(element))
                }
                _ => {
                    k += 1;
                    continue;
                }
            };
            let vty = cx.value_ty(f, vector);
            let Type::Vector { len, elem, scalable: false } = *cx.m.types.get(vty) else {
                k += 1;
                continue;
            };
            if matches!(cx.m.types.get(elem), Type::Int(1)) || !len.is_power_of_two() {
                k += 1;
                continue;
            }
            let r = f.insts[i.index()].result.unwrap();
            let esize = cx.size_of(elem).unwrap_or(1) as i64;
            let align = Some(cx.size_of(vty).unwrap_or(16).next_power_of_two().clamp(1, 16));
            let mut s = Seq { f, new: Vec::new() };
            let slot = s.f.add_inst(
                Op::Alloca { inalloca: false, ty: vty, count: None, align, addrspace: None },
                Some((None, ptr)),
            );
            slots.push(slot);
            let at = s.f.result(slot);
            s.op_void(Op::Store { volatile: false, atomic: None, value: vector, ptr: at, align });
            let idx = if cx.value_ty(s.f, index) == i64t { index } else { s.cast(CastOp::ZExt, index, i64t) };
            let mask = cx.int(i64t, i64::from(len) - 1);
            let idx = s.bin(BinOp::And, idx, mask, i64t);
            let off = if esize & (esize - 1) == 0 {
                let sh = cx.int(i64t, i64::from(esize.trailing_zeros()));
                s.bin(BinOp::Shl, idx, sh, i64t)
            } else {
                let sz = cx.int(i64t, esize);
                s.bin(BinOp::Mul, idx, sz, i64t)
            };
            let lane = s.op(
                Op::Gep { flags: GepFlags::default(), inrange: None, source_ty: i8t, ptr: at, indices: vec![off] },
                ptr,
            );
            let ealign = Some(esize as u64);
            let v = match element {
                None => s.op(Op::Load { volatile: false, atomic: None, ptr: lane, align: ealign }, elem),
                Some(e) => {
                    s.op_void(Op::Store { volatile: false, atomic: None, value: e, ptr: lane, align: ealign });
                    s.op(Op::Load { volatile: false, atomic: None, ptr: at, align }, vty)
                }
            };
            s.f.replace_uses(Value::Local(r), v);
            let new = std::mem::take(&mut s.new);
            let n = new.len();
            f.blocks[b.index()].insts.splice(k..=k, new);
            k += n;
        }
    }
    f.blocks[entry.index()].insts.splice(0..0, slots);
}

/// Vectors of one lane (`<1 x i64>`, as NEON's `vget_lane_u64` has them)
/// stay vectors where the convention passes them (in a d register), but
/// what is done with them is done to their element: taking out or putting
/// in the lane is a bitcast, and arithmetic is the element's, between
/// bitcasts.
fn one_lane_vectors(cx: &mut Ctx, f: &mut Function) {
    let one = |cx: &Ctx, ty: TypeId| match cx.m.types.get(ty) {
        Type::Vector { len: 1, elem, scalable: false } => Some(*elem),
        _ => None,
    };
    let blocks: Vec<BlockId> = f.layout.clone();
    for b in blocks {
        let mut k = 0;
        while k < f.blocks[b.index()].insts.len() {
            let i = f.blocks[b.index()].insts[k];
            // A store of one: of its element.
            if let Op::Store { volatile, atomic: None, value, ptr, align } = f.insts[i.index()].op.clone()
                && let Some(e) = one(cx, cx.value_ty(f, value))
            {
                let mut s = Seq { f, new: Vec::new() };
                let x = s.cast(CastOp::BitCast, value, e);
                s.op_void(Op::Store { volatile, atomic: None, value: x, ptr, align });
                let new = std::mem::take(&mut s.new);
                let n = new.len();
                f.blocks[b.index()].insts.splice(k..=k, new);
                k += n;
                continue;
            }
            let Some(r) = f.insts[i.index()].result else {
                k += 1;
                continue;
            };
            let ty = f.locals[r.index()].ty;
            let mut s = Seq { f, new: Vec::new() };
            let v = match s.f.insts[i.index()].op.clone() {
                Op::Load { volatile, atomic: None, ptr, align } if let Some(e) = one(cx, ty) => {
                    let x = s.op(Op::Load { volatile, atomic: None, ptr, align }, e);
                    s.cast(CastOp::BitCast, x, ty)
                }
                Op::ExtractElement { vector, .. } if one(cx, cx.value_ty(s.f, vector)).is_some() => {
                    s.cast(CastOp::BitCast, vector, ty)
                }
                Op::InsertElement { element, .. } if one(cx, ty).is_some() => s.cast(CastOp::BitCast, element, ty),
                // A shuffle of one-lane vectors into a wider one (a splat):
                // the lanes (a's as 0, b's as 1) put into one of the
                // result's width, shuffled by the same mask.
                Op::ShuffleVector { a, b: bv, mask }
                    if let Some(e) = one(cx, cx.value_ty(s.f, a))
                        && matches!(cx.m.types.get(ty), Type::Vector { len, .. } if *len >= 2) =>
                {
                    let i64t = cx.m.types.int(64);
                    // A one-lane value's lane: a constant's, or a bitcast.
                    let lane = |cx: &mut Ctx, s: &mut Seq, v: Value| match v {
                        Value::Const(c) => {
                            let kind = match cx.m.constant(c).kind.clone() {
                                ConstKind::Vector(es) => cx.m.constant(es[0]).kind.clone(),
                                ConstKind::Splat(e1) => cx.m.constant(e1).kind.clone(),
                                k => k,
                            };
                            Value::Const(cx.m.consts.intern(Constant { ty: e, kind }))
                        }
                        v => s.cast(CastOp::BitCast, v, e),
                    };
                    let x = lane(cx, &mut s, a);
                    let poison = Value::Const(cx.m.consts.intern(Constant { ty, kind: ConstKind::Poison }));
                    let (z, o) = (cx.int(i64t, 0), cx.int(i64t, 1));
                    let mut w = s.op(Op::InsertElement { vector: poison, element: x, index: z }, ty);
                    if crate::target::mask_lanes(cx.m, mask).is_some_and(|m| m.contains(&1)) {
                        let y = lane(cx, &mut s, bv);
                        w = s.op(Op::InsertElement { vector: w, element: y, index: o }, ty);
                    }
                    s.op(Op::ShuffleVector { a: w, b: poison, mask }, ty)
                }
                Op::Binary { op, flags, fmf, lhs, rhs } if let Some(e) = one(cx, ty) => {
                    let (a, c) = (s.cast(CastOp::BitCast, lhs, e), s.cast(CastOp::BitCast, rhs, e));
                    let x = s.op(Op::Binary { op, flags, fmf, lhs: a, rhs: c }, e);
                    s.cast(CastOp::BitCast, x, ty)
                }
                _ => {
                    k += 1;
                    continue;
                }
            };
            s.f.replace_uses(Value::Local(r), v);
            let new = std::mem::take(&mut s.new);
            let n = new.len();
            f.blocks[b.index()].insts.splice(k..=k, new);
            k += n;
        }
    }
}

/// Bitcasts between integers and vectors of their width, in forms the
/// description has: a 64-bit vector and `i64` through `<8 x i8>` (`fmov`);
/// a 128-bit one and `i128` through memory, stored as one type to a stack
/// slot and loaded back as the other. (Not vectors of `i1`, whose bits
/// memory packs, nor 32-bit ones, which are widened later.)
fn vector_int_bitcasts(cx: &mut Ctx, f: &mut Function) {
    let i8t = cx.m.types.int(8);
    let v8i8 = cx.m.types.intern(Type::Vector { len: 8, elem: i8t, scalable: false });
    let ptr = cx.m.types.ptr(0);
    let vector = |cx: &Ctx, ty: TypeId| match cx.m.types.get(ty) {
        Type::Vector { scalable: false, elem, .. } => !matches!(cx.m.types.get(*elem), Type::Int(1)),
        _ => false,
    };
    let int = |cx: &Ctx, ty: TypeId| matches!(cx.m.types.get(ty), Type::Int(_));
    let Some(&entry) = f.layout.first() else { return };
    let mut slots = Vec::new();
    let blocks: Vec<BlockId> = f.layout.clone();
    for b in blocks {
        let mut k = 0;
        while k < f.blocks[b.index()].insts.len() {
            let i = f.blocks[b.index()].insts[k];
            let Op::Cast { op: CastOp::BitCast, value, .. } = f.insts[i.index()].op else {
                k += 1;
                continue;
            };
            let r = f.insts[i.index()].result.unwrap();
            let (from, to) = (cx.value_ty(f, value), f.locals[r.index()].ty);
            if !(vector(cx, from) && int(cx, to) || int(cx, from) && vector(cx, to)) {
                k += 1;
                continue;
            }
            let size = cx.size_of(to).unwrap_or(0);
            if size != 8 && size != 16 {
                k += 1;
                continue;
            }
            let mut s = Seq { f, new: Vec::new() };
            let v = if size == 8 {
                if from == v8i8 || to == v8i8 {
                    k += 1;
                    continue;
                }
                let x = s.cast(CastOp::BitCast, value, v8i8);
                s.cast(CastOp::BitCast, x, to)
            } else {
                let align = Some(size.next_power_of_two().clamp(1, 16));
                let slot = s.f.add_inst(
                    Op::Alloca { inalloca: false, ty: from, count: None, align, addrspace: None },
                    Some((None, ptr)),
                );
                slots.push(slot);
                let at = s.f.result(slot);
                s.op_void(Op::Store { volatile: false, atomic: None, value, ptr: at, align });
                s.op(Op::Load { volatile: false, atomic: None, ptr: at, align }, to)
            };
            s.f.replace_uses(Value::Local(r), v);
            let new = std::mem::take(&mut s.new);
            let n = new.len();
            f.blocks[b.index()].insts.splice(k..=k, new);
            k += n;
        }
    }
    // The slots, first in the entry block, as fixed allocas are.
    f.blocks[entry.index()].insts.splice(0..0, slots);
}

/// An `i1` in memory is a byte, 0 or 1: its stores store it zero-extended,
/// and its loads truncate the byte.
fn bool_memory(cx: &mut Ctx, f: &mut Function) {
    let (i1, i8t) = (cx.m.types.int(1), cx.m.types.int(8));
    let blocks: Vec<BlockId> = f.layout.clone();
    for b in blocks {
        let mut k = 0;
        while k < f.blocks[b.index()].insts.len() {
            let i = f.blocks[b.index()].insts[k];
            let mut s = Seq { f, new: Vec::new() };
            match s.f.insts[i.index()].op.clone() {
                Op::Store { volatile, atomic, value, ptr, align } if cx.value_ty(s.f, value) == i1 => {
                    let v = s.cast(CastOp::ZExt, value, i8t);
                    s.op_void(Op::Store { volatile, atomic, value: v, ptr, align });
                }
                Op::Load { volatile, atomic, ptr, align }
                    if s.f.insts[i.index()].result.is_some_and(|r| s.f.locals[r.index()].ty == i1) =>
                {
                    let r = s.f.insts[i.index()].result.unwrap();
                    let v = s.op(Op::Load { volatile, atomic, ptr, align }, i8t);
                    let t = s.cast(CastOp::Trunc, v, i1);
                    s.f.replace_uses(Value::Local(r), t);
                }
                _ => {
                    k += 1;
                    continue;
                }
            }
            let new = std::mem::take(&mut s.new);
            let n = new.len();
            f.blocks[b.index()].insts.splice(k..=k, new);
            k += n;
        }
    }
}

/// The most loads and stores a `memset` or `memcpy` is written out as.
const MAX_MEM_PIECES: u64 = 16;

/// Small `llvm.memset` and `llvm.memcpy` calls of a constant length are
/// written out as stores (and, for a copy, loads), each as wide as the
/// alignment and what is left allow (8, 4, 2 or 1 bytes), when that is at
/// most `MAX_MEM_PIECES` of them; longer ones stay calls to the C library.
/// `memcpyopt` turns runs of stores into memsets that come back here as
/// wider stores. Volatile ones, and memsets of a value not known, stay
/// calls.
fn expand_small_mem_ops(cx: &mut Ctx, f: &mut Function) {
    let blocks: Vec<BlockId> = f.layout.clone();
    for b in blocks {
        let mut k = 0;
        while k < f.blocks[b.index()].insts.len() {
            let i = f.blocks[b.index()].insts[k];
            let Op::Call(call) = &f.insts[i.index()].op else {
                k += 1;
                continue;
            };
            let name = callee_name(cx.m, call).unwrap_or_default();
            let copy = name.starts_with("llvm.memcpy.");
            if !(copy || name.starts_with("llvm.memset.")) || call.args.len() != 4 {
                k += 1;
                continue;
            }
            let arg = |n: usize| call.args[n].value;
            let align = |n: usize| {
                call.args[n]
                    .attrs
                    .iter()
                    .find_map(|a| match a {
                        Attr::Int { name, value, .. } if name == "align" => Some(*value),
                        _ => None,
                    })
                    .unwrap_or(1)
            };
            let (Some(len), Some(0)) = (cx.const_int(arg(2)), cx.const_int(arg(3))) else {
                k += 1;
                continue;
            };
            let byte = if copy { None } else { cx.const_int(arg(1)).map(|v| v as u8) };
            if len <= 0 || (!copy && byte.is_none()) {
                k += 1;
                continue;
            }
            let len = len as u64;
            let widest = if cx.t.machine.unaligned_fast {
                8
            } else {
                if copy { align(0).min(align(1)) } else { align(0) }.clamp(1, 8)
            };
            // The pieces: (offset, bytes), each as wide as it can be.
            let mut pieces = Vec::new();
            let mut at = 0u64;
            while at < len {
                let w = [8u64, 4, 2, 1].into_iter().find(|&w| w <= widest && at + w <= len).unwrap();
                pieces.push((at, w));
                at += w;
            }
            if pieces.len() as u64 > MAX_MEM_PIECES
                || !epitome_ir::chop::allow(|| {
                    format!("write the {name} at {} as {} accesses", epitome_ir::printer::inst_name(f, i), pieces.len())
                })
            {
                k += 1;
                continue;
            }
            let (dst, src) = (arg(0), arg(1));
            let (dst_align, src_align) = (align(0), if copy { align(1) } else { 1 });
            let (i8t, i64t, ptr) = (cx.m.types.int(8), cx.m.types.int(64), cx.m.types.ptr(0));
            let mut s = Seq { f, new: Vec::new() };
            // Two pieces at a time: both loads, then both stores, so that
            // the accesses are neighbours a load or store pair can take
            // (`peephole::pair_memory`). A memcpy's two ranges do not
            // overlap, so the order is free.
            for two in pieces.chunks(2) {
                let mut values = Vec::new();
                for &(off, w) in two {
                    // What alignment each piece really has: the call's, at
                    // most, and no more than its offset's.
                    let real = |a: u64| if off == 0 { a } else { a.min(1 << off.trailing_zeros()) };
                    let ty = cx.m.types.int(8 * w as u32);
                    let value = match byte {
                        Some(b) => {
                            let v = (0..w).fold(0u64, |acc, _| (acc << 8) | b as u64);
                            cx.int(ty, v as i64)
                        }
                        None => {
                            let from = offset_ptr(cx, &mut s, src, off, i8t, i64t, ptr);
                            s.op(
                                Op::Load {
                                    volatile: false,
                                    atomic: None,
                                    ptr: from,
                                    align: Some(real(src_align).min(w)),
                                },
                                ty,
                            )
                        }
                    };
                    values.push(value);
                }
                for (&(off, w), value) in two.iter().zip(values) {
                    let real = |a: u64| if off == 0 { a } else { a.min(1 << off.trailing_zeros()) };
                    let to = offset_ptr(cx, &mut s, dst, off, i8t, i64t, ptr);
                    let st = s.f.add_inst(
                        Op::Store {
                            volatile: false,
                            atomic: None,
                            value,
                            ptr: to,
                            align: Some(real(dst_align).min(w)),
                        },
                        None,
                    );
                    s.new.push(st);
                }
            }
            let new = std::mem::take(&mut s.new);
            let n = new.len();
            f.blocks[b.index()].insts.splice(k..=k, new);
            k += n;
        }
    }
}

/// Address sinking, the local half of LLVM's `codegenprepare`: a
/// `getelementptr` used as the address of loads and stores in other blocks
/// is copied into each of them, so that instruction selection, which looks
/// within a block, can fold it into the access (`ldr x0, [x1, #24]`, `ldr
/// x0, [x1, x2, lsl #3]`) instead of computing it into a register first.
///
/// Only address operands move, and only into blocks that are not on a
/// cycle the original's block is not on: an address that does not fold
/// would otherwise be computed every time round a loop. Each block gets one
/// copy, before its first use there. Each sink is an elective choice
/// (autochop).
fn sink_addresses(f: &mut Function) {
    let blocks = f.inst_blocks();
    let on_cycle = cycles(f);
    // Each GEP's address uses, by block.
    let mut uses: std::collections::HashMap<InstId, Vec<(BlockId, InstId)>> = Default::default();
    for &b in &f.layout {
        for &i in &f.blocks[b.index()].insts {
            let ptr = match &f.insts[i.index()].op {
                Op::Load { ptr, .. } | Op::Store { ptr, .. } => *ptr,
                _ => continue,
            };
            if let Value::Local(l) = ptr
                && let LocalDef::Inst(d) = f.locals[l.index()].def
                && matches!(f.insts[d.index()].op, Op::Gep { .. })
                && blocks[d.index()].is_some_and(|db| db != b)
            {
                uses.entry(d).or_default().push((b, i));
            }
        }
    }
    let mut gepped: Vec<InstId> = uses.keys().copied().collect();
    gepped.sort();
    for d in gepped {
        let Some(home) = blocks[d.index()] else { continue };
        let r = f.insts[d.index()].result.unwrap();
        let mut list = uses[&d].clone();
        list.sort_by_key(|&(b, _)| b);
        let mut k = 0;
        while k < list.len() {
            let b = list[k].0;
            let users: Vec<InstId> = list[k..].iter().take_while(|x| x.0 == b).map(|x| x.1).collect();
            k += users.len();
            if on_cycle[b.index()].is_some() && on_cycle[b.index()] != on_cycle[home.index()] {
                continue;
            }
            if !epitome_ir::chop::allow(|| {
                format!(
                    "sink the address {} into {}",
                    epitome_ir::printer::local_name(f, r),
                    epitome_ir::printer::local_name(f, f.blocks[b.index()].local)
                )
            }) {
                continue;
            }
            let ty = f.locals[r.index()].ty;
            let copy = f.add_inst(f.insts[d.index()].op.clone(), Some((None, ty)));
            let first =
                users.iter().filter_map(|u| f.blocks[b.index()].insts.iter().position(|x| x == u)).min().unwrap();
            f.blocks[b.index()].insts.insert(first, copy);
            let new = f.result(copy);
            for u in users {
                match &mut f.insts[u.index()].op {
                    Op::Load { ptr, .. } | Op::Store { ptr, .. } => *ptr = new,
                    _ => {}
                }
            }
        }
    }
}

/// For each block on a cycle, its strongly connected component (Tarjan's
/// algorithm); `None` for the rest.
fn cycles(f: &Function) -> Vec<Option<usize>> {
    let n = f.blocks.len();
    let succs: Vec<Vec<BlockId>> = (0..n).map(|b| f.successors(BlockId(b as u32))).collect();
    let (mut index, mut low, mut on_stack) = (vec![usize::MAX; n], vec![0; n], vec![false; n]);
    let mut stack = Vec::new();
    let mut comp = vec![None; n];
    let mut next = 0;
    let mut count = 0;
    for &root in &f.layout {
        if index[root.index()] != usize::MAX {
            continue;
        }
        // An explicit stack of (block, next successor to look at).
        let mut work = vec![(root.index(), 0usize)];
        index[root.index()] = next;
        low[root.index()] = next;
        next += 1;
        stack.push(root.index());
        on_stack[root.index()] = true;
        while let Some(&mut (v, ref mut k)) = work.last_mut() {
            if let Some(&w) = succs[v].get(*k) {
                *k += 1;
                let w = w.index();
                if index[w] == usize::MAX {
                    index[w] = next;
                    low[w] = next;
                    next += 1;
                    stack.push(w);
                    on_stack[w] = true;
                    work.push((w, 0));
                } else if on_stack[w] {
                    low[v] = low[v].min(index[w]);
                }
            } else {
                work.pop();
                if let Some(&(u, _)) = work.last() {
                    low[u] = low[u].min(low[v]);
                }
                if low[v] == index[v] {
                    let mut members = Vec::new();
                    loop {
                        let w = stack.pop().unwrap();
                        on_stack[w] = false;
                        members.push(w);
                        if w == v {
                            break;
                        }
                    }
                    let self_loop = succs[v].iter().any(|s| s.index() == v);
                    if members.len() > 1 || self_loop {
                        for w in members {
                            comp[w] = Some(count);
                        }
                        count += 1;
                    }
                }
            }
        }
    }
    comp
}

/// A dynamic alloca (`alloca T, i32 %n`) becomes one of bytes,
/// `alloca i8, i64 %size`, its size rounded up to keep `sp` 16-aligned.
fn lower_dynamic_allocas(cx: &mut Ctx, f: &mut Function) -> Result<(), String> {
    let i8t = cx.m.types.int(8);
    let i64t = cx.m.types.int(64);
    let blocks: Vec<BlockId> = f.layout.clone();
    for b in blocks {
        let mut k = 0;
        while k < f.blocks[b.index()].insts.len() {
            let i = f.blocks[b.index()].insts[k];
            let Op::Alloca { ty, count: Some(c), align, inalloca, addrspace } = f.insts[i.index()].op.clone() else {
                k += 1;
                continue;
            };
            if cx.const_int(c).is_some() {
                k += 1;
                continue;
            }
            let elem = cx.size_of(ty)? as i64;
            let mut s = Seq { f, new: Vec::new() };
            let n = match cx.m.types.get(cx.value_ty(s.f, c)) {
                Type::Int(64) => c,
                Type::Int(b) if *b > 64 => s.cast(CastOp::Trunc, c, i64t),
                _ => s.cast(CastOp::ZExt, c, i64t),
            };
            let size = cx.int(i64t, elem);
            let bytes = s.bin(BinOp::Mul, n, size, i64t);
            let fifteen = cx.int(i64t, 15);
            let up = s.bin(BinOp::Add, bytes, fifteen, i64t);
            let mask = cx.int(i64t, -16);
            let rounded = s.bin(BinOp::And, up, mask, i64t);
            let new = std::mem::take(&mut s.new);
            f.insts[i.index()].op = Op::Alloca {
                inalloca,
                ty: i8t,
                count: Some(rounded),
                align: Some(align.unwrap_or(16).max(16)),
                addrspace,
            };
            let n = new.len();
            f.blocks[b.index()].insts.splice(k..k, new);
            k += n + 1;
        }
    }
    Ok(())
}

/// Rejects what the code generator cannot do yet.
fn check(cx: &Ctx, f: &Function, fname: &str) -> Result<(), String> {
    // Small structs, as clang passes them ([2 x i64]), live as their parts.
    let small_struct = |ty: &Type| match ty {
        Type::Array { len, elem } => *len <= 2 && matches!(cx.m.types.get(*elem), Type::Int(64)),
        Type::Struct { fields, .. } => {
            fields.len() <= 2 && fields.iter().all(|f| matches!(cx.m.types.get(*f), Type::Int(64)))
        }
        _ => false,
    };
    let bad_type = |ty: TypeId| match cx.m.types.get(ty) {
        // i128 remains only in the high half of a product (see wide.rs).
        Type::Int(b) => *b > 64 && *b != 128,
        Type::Ptr(a) => *a != 0,
        Type::Void | Type::Label | Type::Double | Type::Float => false,
        // Vectors that do not fit a register are split (see
        // `legalize_vectors`); scalable ones are not supported.
        Type::Vector { scalable: false, elem, .. } => !matches!(
            cx.m.types.get(*elem),
            Type::Int(1 | 8 | 16 | 32 | 64) | Type::Float | Type::Double | Type::Ptr(0)
        ),
        t => !small_struct(t),
    };
    for p in &f.params {
        if bad_type(f.locals[p.local.index()].ty) {
            return Err(format!("@{fname}: parameters of this type are not supported yet"));
        }
    }
    for i in f.insts_in_order() {
        let inst = &f.insts[i.index()];
        if let Some(r) = inst.result
            && bad_type(f.locals[r.index()].ty)
            && !matches!(
                inst.op,
                Op::Alloca { .. } | Op::Call(_) | Op::Invoke { .. } | Op::LandingPad { .. } | Op::InsertValue { .. }
            )
        {
            return Err(format!(
                "@{fname}: values of type {} are not supported yet",
                type_name(cx, f.locals[r.index()].ty)
            ));
        }
        match &inst.op {
            Op::CallBr { .. } | Op::IndirectBr { .. } => {
                return Err(format!("@{fname}: indirect branches are not supported yet"));
            }
            Op::CatchSwitch { .. }
            | Op::CatchPad { .. }
            | Op::CleanupPad { .. }
            | Op::CatchRet { .. }
            | Op::CleanupRet { .. } => {
                return Err(format!("@{fname}: Windows exception handling is not supported"));
            }
            _ => {}
        }
    }
    Ok(())
}

fn type_name(cx: &Ctx, ty: TypeId) -> String {
    format!("{:?}", cx.m.types.get(ty))
}

pub fn callee_name(m: &Module, call: &Call) -> Option<String> {
    let Value::Const(c) = call.callee else { return None };
    match m.constant(c).kind {
        ConstKind::Global(g) => m.global(g).name.clone(),
        _ => None,
    }
}

fn drop_noop_calls(cx: &Ctx, f: &mut Function) {
    let order: Vec<BlockId> = f.layout.clone();
    for b in order {
        let insts = f.blocks[b.index()].insts.clone();
        let keep: Vec<InstId> = insts
            .into_iter()
            .filter(|&i| match &f.insts[i.index()].op {
                Op::Call(call) => !callee_name(cx.m, call).is_some_and(|n| {
                    n.starts_with("llvm.lifetime.")
                        || n.starts_with("llvm.dbg.")
                        || n == "llvm.assume"
                        || n.starts_with("llvm.experimental.noalias")
                }),
                _ => true,
            })
            .collect();
        f.blocks[b.index()].insts = keep;
    }
}

fn lower_switches(cx: &mut Ctx, f: &mut Function) {
    let blocks: Vec<BlockId> = f.layout.clone();
    for b in blocks {
        let Some(t) = f.terminator(b) else { continue };
        let Op::Switch { value, default, cases } = f.insts[t.index()].op.clone() else { continue };
        let ty = cx.value_ty(f, value);
        let i1 = cx.m.types.int(1);
        // The block each test is in: `b` for the first, then new ones.
        let mut at = b;
        let mut pos = f.layout.iter().position(|&x| x == b).unwrap() + 1;
        // The phi values `b` sent to each target.
        let phi_value = |f: &Function, target: BlockId, phi: InstId| -> Option<Value> {
            match &f.insts[phi.index()].op {
                Op::Phi { incoming, .. } => incoming.iter().find(|(_, p)| *p == b).map(|(v, _)| *v),
                _ => None,
            }
            .filter(|_| f.blocks[target.index()].insts.contains(&phi))
        };
        let mut edges: Vec<(BlockId, BlockId)> = Vec::new();
        f.blocks[b.index()].insts.pop();
        for (k, (c, target)) in cases.iter().enumerate() {
            let cmp = f.push_inst(
                at,
                Op::ICmp { pred: ICmpPred::Eq, samesign: false, lhs: value, rhs: Value::Const(*c) },
                Some((None, i1)),
            );
            let next = if k + 1 == cases.len() {
                default
            } else {
                let nb = f.add_block(None);
                f.layout.insert(pos, nb);
                pos += 1;
                nb
            };
            f.push_inst(at, Op::CondBr { cond: f.result(cmp), then_dest: *target, else_dest: next }, None);
            edges.push((at, *target));
            if k + 1 == cases.len() {
                edges.push((at, default));
            }
            at = next;
        }
        if cases.is_empty() {
            f.push_inst(b, Op::Br(default), None);
            continue;
        }
        let _ = ty;
        // Phis: one entry for each new edge, in place of `b`'s.
        let mut targets: Vec<BlockId> = edges.iter().map(|e| e.1).collect();
        targets.sort();
        targets.dedup();
        for target in targets {
            let phis: Vec<InstId> = f.blocks[target.index()]
                .insts
                .iter()
                .copied()
                .take_while(|&i| f.insts[i.index()].op.is_phi())
                .collect();
            for phi in phis {
                let Some(v) = phi_value(f, target, phi) else { continue };
                if let Op::Phi { incoming, .. } = &mut f.insts[phi.index()].op {
                    incoming.retain(|(_, p)| *p != b);
                    for &(from, to) in &edges {
                        if to == target {
                            incoming.push((v, from));
                        }
                    }
                }
            }
        }
    }
}

fn lower_geps(cx: &mut Ctx, f: &mut Function) -> Result<(), String> {
    let i64t = cx.i64t();
    let i8t = cx.i8t();
    let blocks: Vec<BlockId> = f.layout.clone();
    for b in blocks {
        let mut k = 0;
        while k < f.blocks[b.index()].insts.len() {
            let i = f.blocks[b.index()].insts[k];
            let Op::Gep { ptr, indices, source_ty, .. } = f.insts[i.index()].op.clone() else {
                k += 1;
                continue;
            };
            if indices.len() == 1
                && matches!(cx.m.types.get(source_ty), Type::Int(8))
                && cx.value_ty(f, indices[0]) == i64t
            {
                k += 1;
                continue;
            }
            // Constant part, and (index, scale) for the rest.
            let mut constant: i64 = 0;
            let mut terms: Vec<(Value, i64)> = Vec::new();
            let mut ty = source_ty;
            for (n, &idx) in indices.iter().enumerate() {
                let scale;
                if n == 0 {
                    scale = cx.size_of(ty)? as i64;
                } else {
                    match cx.m.types.get(ty).clone() {
                        Type::Struct { .. } | Type::Named(_) => {
                            let field = cx.const_int(idx).ok_or("a struct index that is not constant")? as u64;
                            let (fields, packed) = struct_fields(cx, ty)?;
                            let layout = cx.dl.struct_layout(&cx.m.types, &fields, packed).ok_or("struct layout")?;
                            constant += layout.offsets[field as usize] as i64;
                            ty = fields[field as usize];
                            continue;
                        }
                        Type::Array { elem, .. } | Type::Vector { elem, .. } => {
                            ty = elem;
                            scale = cx.size_of(elem)? as i64;
                        }
                        other => return Err(format!("getelementptr into {other:?}")),
                    }
                }
                match cx.const_int(idx) {
                    Some(c) => constant = constant.wrapping_add(c.wrapping_mul(scale)),
                    None => terms.push((idx, scale)),
                }
            }
            // Build the offset before the gep.
            let mut new: Vec<InstId> = Vec::new();
            let mut total: Option<Value> = None;
            for (idx, scale) in terms {
                let ity = cx.value_ty(f, idx);
                let mut v = idx;
                if ity != i64t {
                    let c = f.add_inst(
                        Op::Cast { op: CastOp::SExt, flags: IntFlags::NONE, fmf: FastMath::default(), value: v },
                        Some((None, i64t)),
                    );
                    new.push(c);
                    v = f.result(c);
                }
                if scale != 1 {
                    let op = if scale > 0 && (scale & (scale - 1)) == 0 {
                        let sh = cx.int(i64t, scale.trailing_zeros() as i64);
                        Op::Binary { op: BinOp::Shl, flags: IntFlags::NONE, fmf: FastMath::default(), lhs: v, rhs: sh }
                    } else {
                        let s = cx.int(i64t, scale);
                        Op::Binary { op: BinOp::Mul, flags: IntFlags::NONE, fmf: FastMath::default(), lhs: v, rhs: s }
                    };
                    let c = f.add_inst(op, Some((None, i64t)));
                    new.push(c);
                    v = f.result(c);
                }
                total = Some(match total {
                    None => v,
                    Some(t) => {
                        let c = f.add_inst(
                            Op::Binary {
                                op: BinOp::Add,
                                flags: IntFlags::NONE,
                                fmf: FastMath::default(),
                                lhs: t,
                                rhs: v,
                            },
                            Some((None, i64t)),
                        );
                        new.push(c);
                        f.result(c)
                    }
                });
            }
            // A constant offset goes on its own gep, so it can become an
            // addressing-mode offset.
            let mut base = ptr;
            if let Some(t) = total {
                if constant == 0 {
                    f.insts[i.index()].op = gep8(i8t, ptr, t);
                } else {
                    let ptr_ty = f.locals[f.insts[i.index()].result.unwrap().index()].ty;
                    let g = f.add_inst(gep8(i8t, ptr, t), Some((None, ptr_ty)));
                    new.push(g);
                    base = f.result(g);
                    let c = cx.int(i64t, constant);
                    f.insts[i.index()].op = gep8(i8t, base, c);
                }
            } else {
                let c = cx.int(i64t, constant);
                f.insts[i.index()].op = gep8(i8t, base, c);
            }
            let n = new.len();
            f.blocks[b.index()].insts.splice(k..k, new);
            k += n + 1;
        }
    }
    Ok(())
}

/// The register width an odd-sized integer lives in.
fn container(bits: u32) -> Option<u32> {
    match bits {
        1 | 8 | 16 | 32 | 64 => None,
        b if b < 32 => Some(32),
        b if b < 64 => Some(64),
        _ => None,
    }
}

fn promote_odd(cx: &mut Ctx, f: &mut Function) -> Result<(), String> {
    // The original width of each value that moves to a wider type.
    let mut orig: std::collections::HashMap<LocalId, u32> = std::collections::HashMap::new();
    for (k, l) in f.locals.iter_mut().enumerate() {
        if let Type::Int(b) = *cx.m.types.get(l.ty)
            && let Some(c) = container(b)
        {
            orig.insert(LocalId(k as u32), b);
            l.ty = cx.m.types.int(c);
        }
    }
    // (Or constants of them: a store of an `i24` constant.)
    let odd_const = || {
        f.insts_in_order().any(|i| {
            let mut odd = false;
            f.insts[i.index()].op.for_each_value(|v| {
                odd |= matches!(*v, Value::Const(c)
                    if matches!(*cx.m.types.get(cx.m.constant(c).ty), Type::Int(b) if container(b).is_some()));
            });
            odd
        })
    };
    if orig.is_empty() && !odd_const() {
        return Ok(());
    }
    let bits_of = |cx: &Ctx, f: &Function, orig: &std::collections::HashMap<LocalId, u32>, v: Value| -> u32 {
        match v {
            Value::Local(x) => orig.get(&x).copied().unwrap_or_else(|| match cx.m.types.get(f.locals[x.index()].ty) {
                Type::Int(b) => *b,
                _ => 64,
            }),
            Value::Const(c) => match cx.m.types.get(cx.m.constant(c).ty) {
                Type::Int(b) => *b,
                _ => 64,
            },
            _ => 64,
        }
    };
    let blocks: Vec<BlockId> = f.layout.clone();
    for b in blocks {
        let mut k = 0;
        while k < f.blocks[b.index()].insts.len() {
            let i = f.blocks[b.index()].insts[k];
            let mut new: Vec<InstId> = Vec::new();
            // What a store stores, before its constant is widened below:
            // a store of an `i24` constant writes three bytes, not four.
            let stored_bits = match &f.insts[i.index()].op {
                Op::Store { value, .. } => Some(bits_of(cx, f, &orig, *value)),
                _ => None,
            };
            // Constants of odd widths become constants of the wider type.
            let mut op = f.insts[i.index()].op.clone();
            op.for_each_value_mut(|v| {
                if let Value::Const(c) = *v
                    && let Type::Int(bits) = *cx.m.types.get(cx.m.constant(c).ty)
                    && let Some(w) = container(bits)
                    && let Some(n) = cx.const_int(*v)
                {
                    let t = cx.m.types.int(w);
                    *v = cx.int(t, n);
                }
            });
            // Operations that read the top bits get their operands made
            // right: masked for unsigned readings, sign-extended for signed.
            let mut fix = |cx: &mut Ctx, f: &mut Function, v: Value, bits: u32, signed: bool| -> Value {
                let Some(w) = container(bits) else { return v };
                let t = cx.m.types.int(w);
                let nf = IntFlags::NONE;
                let fm = FastMath::default();
                if signed {
                    let sh = cx.int(t, (w - bits) as i64);
                    let a =
                        f.add_inst(Op::Binary { op: BinOp::Shl, flags: nf, fmf: fm, lhs: v, rhs: sh }, Some((None, t)));
                    let r = f.add_inst(
                        Op::Binary { op: BinOp::AShr, flags: nf, fmf: fm, lhs: f.result(a), rhs: sh },
                        Some((None, t)),
                    );
                    new.push(a);
                    new.push(r);
                    f.result(r)
                } else {
                    let mask = cx.int(t, ((1u64 << bits) - 1) as i64);
                    let a = f.add_inst(
                        Op::Binary { op: BinOp::And, flags: nf, fmf: fm, lhs: v, rhs: mask },
                        Some((None, t)),
                    );
                    new.push(a);
                    f.result(a)
                }
            };
            let res = f.insts[i.index()].result;
            let res_odd = res.and_then(|r| orig.get(&r).copied());
            if matches!(op, Op::Load { .. } | Op::Store { .. }) {
                let mut odd = res_odd.is_some() || stored_bits.and_then(container).is_some();
                op.for_each_value(|v| odd |= container(bits_of(cx, f, &orig, *v)).is_some());
                // A whole number of bytes: in pieces of 4, 2 and 1 bytes,
                // the lowest first (little-endian).
                let bits = match stored_bits {
                    Some(b) => b,
                    None => res_odd.unwrap_or(0),
                };
                let plain = matches!(
                    &op,
                    Op::Store { volatile: false, atomic: None, .. } | Op::Load { volatile: false, atomic: None, .. }
                );
                if odd && !(plain && bits % 8 == 0) {
                    return Err("loads and stores of odd-sized integers are not supported yet".into());
                }
                if odd {
                    let w = cx.m.types.int(container(bits).unwrap());
                    let (i8t, i64t, ptr_ty) = (cx.m.types.int(8), cx.m.types.int(64), cx.m.types.ptr(0));
                    let mut pieces = Vec::new();
                    let mut off = 0;
                    while off < bits / 8 {
                        let size = [4, 2, 1].into_iter().find(|&n| off + n <= bits / 8).unwrap();
                        pieces.push((off, size));
                        off += size;
                    }
                    let nf = IntFlags::NONE;
                    let fm = FastMath::default();
                    let mut add = |f: &mut Function, op: Op, ty: Option<TypeId>| -> Value {
                        let x = f.add_inst(op, ty.map(|t| (None, t)));
                        new.push(x);
                        if ty.is_some() { f.result(x) } else { Value::Const(ConstId(0)) }
                    };
                    let mut last = None;
                    match op.clone() {
                        Op::Store { value, ptr, align, .. } => {
                            for (n, &(off, size)) in pieces.iter().enumerate() {
                                let pt = cx.m.types.int(8 * size as u32);
                                let sh = cx.int(w, 8 * off as i64);
                                let v = if off == 0 {
                                    value
                                } else {
                                    add(
                                        f,
                                        Op::Binary { op: BinOp::LShr, flags: nf, fmf: fm, lhs: value, rhs: sh },
                                        Some(w),
                                    )
                                };
                                let v = add(f, Op::Cast { op: CastOp::Trunc, flags: nf, fmf: fm, value: v }, Some(pt));
                                let o = cx.int(i64t, off as i64);
                                let p = add(f, gep8(i8t, ptr, o), Some(ptr_ty));
                                let st = Op::Store {
                                    volatile: false,
                                    atomic: None,
                                    value: v,
                                    ptr: p,
                                    align: align.map(|a| a.min(size as u64)),
                                };
                                if n + 1 == pieces.len() {
                                    last = Some(st);
                                } else {
                                    add(f, st, None);
                                }
                            }
                        }
                        Op::Load { ptr, align, .. } => {
                            let mut acc = None;
                            for (n, &(off, size)) in pieces.iter().enumerate() {
                                let pt = cx.m.types.int(8 * size as u32);
                                let o = cx.int(i64t, off as i64);
                                let p = add(f, gep8(i8t, ptr, o), Some(ptr_ty));
                                let v = add(
                                    f,
                                    Op::Load {
                                        volatile: false,
                                        atomic: None,
                                        ptr: p,
                                        align: align.map(|a| a.min(size as u64)),
                                    },
                                    Some(pt),
                                );
                                let v = add(f, Op::Cast { op: CastOp::ZExt, flags: nf, fmf: fm, value: v }, Some(w));
                                let sh = cx.int(w, 8 * off as i64);
                                let v = if off == 0 {
                                    v
                                } else {
                                    add(f, Op::Binary { op: BinOp::Shl, flags: nf, fmf: fm, lhs: v, rhs: sh }, Some(w))
                                };
                                acc = Some(match acc {
                                    None => v,
                                    Some(a) if n + 1 == pieces.len() => {
                                        last = Some(Op::Binary { op: BinOp::Or, flags: nf, fmf: fm, lhs: a, rhs: v });
                                        break;
                                    }
                                    Some(a) => add(
                                        f,
                                        Op::Binary { op: BinOp::Or, flags: nf, fmf: fm, lhs: a, rhs: v },
                                        Some(w),
                                    ),
                                });
                            }
                        }
                        _ => unreachable!(),
                    }
                    f.insts[i.index()].op = last.unwrap();
                    let n = new.len();
                    f.blocks[b.index()].insts.splice(k..k, new);
                    k += n + 1;
                    continue;
                }
            }
            match &mut op {
                Op::Binary { op: bop, flags, lhs, rhs, .. } => {
                    let bits = bits_of(cx, f, &orig, *lhs);
                    if container(bits).is_some() {
                        *flags = IntFlags::NONE;
                        match bop {
                            BinOp::LShr | BinOp::UDiv | BinOp::URem => {
                                *lhs = fix(cx, f, *lhs, bits, false);
                                *rhs = fix(cx, f, *rhs, bits, false);
                            }
                            BinOp::AShr => {
                                *lhs = fix(cx, f, *lhs, bits, true);
                                *rhs = fix(cx, f, *rhs, bits, false);
                            }
                            BinOp::SDiv | BinOp::SRem => {
                                *lhs = fix(cx, f, *lhs, bits, true);
                                *rhs = fix(cx, f, *rhs, bits, true);
                            }
                            _ => {}
                        }
                    }
                }
                Op::ICmp { pred, lhs, rhs, .. } => {
                    let bits = bits_of(cx, f, &orig, *lhs);
                    let signed = matches!(pred, ICmpPred::Sgt | ICmpPred::Sge | ICmpPred::Slt | ICmpPred::Sle);
                    *lhs = fix(cx, f, *lhs, bits, signed);
                    *rhs = fix(cx, f, *rhs, bits, signed);
                }
                Op::Cast { op: cop, flags, value, .. } => {
                    let from = bits_of(cx, f, &orig, *value);
                    let to_ty = f.locals[res.unwrap().index()].ty;
                    let to = match cx.m.types.get(to_ty) {
                        Type::Int(b) => *b,
                        _ => 64,
                    };
                    let from_odd = container(from).is_some();
                    if from_odd || res_odd.is_some() {
                        *flags = IntFlags::NONE;
                        if from_odd && matches!(cop, CastOp::ZExt | CastOp::SExt) {
                            *value = fix(cx, f, *value, from, *cop == CastOp::SExt);
                        }
                        // Between equal register widths, the cast is free; from
                        // a wider container (an i3 held in 32 bits, made right
                        // above, extended to i8) it takes the low bits.
                        let from_w = container(from).unwrap_or(from);
                        if from_w == to {
                            *cop = CastOp::BitCast;
                        } else if from_w > to && matches!(cop, CastOp::ZExt | CastOp::SExt) {
                            *cop = CastOp::Trunc;
                        }
                    }
                }
                _ => {}
            }
            // A bitcast between integers is the identity; use freeze, which
            // is a plain copy, as the selector treats bitcasts of pointers.
            // (Not one to or from a float or a vector: those move bits
            // between register files.)
            if let Op::Cast { op: CastOp::BitCast, value, .. } = op
                && let Some(r) = res
                && matches!(cx.m.types.get(f.locals[r.index()].ty), Type::Int(_))
                && matches!(cx.m.types.get(cx.value_ty(f, value)), Type::Int(_))
            {
                op = Op::Freeze(value);
            }
            f.insts[i.index()].op = op;
            let n = new.len();
            f.blocks[b.index()].insts.splice(k..k, new);
            k += n + 1;
        }
    }
    Ok(())
}

fn split_aggregate_memory(cx: &mut Ctx, f: &mut Function) {
    let i64t = cx.m.types.int(64);
    let i8t = cx.m.types.int(8);
    let parts_of = |cx: &Ctx, ty: TypeId| -> Option<u32> {
        match cx.m.types.get(ty) {
            Type::Array { len, elem } if *len <= 2 && matches!(cx.m.types.get(*elem), Type::Int(64)) => {
                Some(*len as u32)
            }
            Type::Struct { fields, .. }
                if fields.len() <= 2 && fields.iter().all(|t| matches!(cx.m.types.get(*t), Type::Int(64))) =>
            {
                Some(fields.len() as u32)
            }
            _ => None,
        }
    };
    let blocks: Vec<BlockId> = f.layout.clone();
    for b in blocks {
        let mut k = 0;
        while k < f.blocks[b.index()].insts.len() {
            let i = f.blocks[b.index()].insts[k];
            let mut s = Seq { f, new: Vec::new() };
            let done = match s.f.insts[i.index()].op.clone() {
                Op::Store { value, ptr, volatile: false, atomic: None, .. } => {
                    let ty = cx.value_ty(s.f, value);
                    match parts_of(cx, ty) {
                        Some(n) => {
                            let ptr_ty = cx.m.types.ptr(0);
                            for part in 0..n {
                                let e = s.op(Op::ExtractValue { aggregate: value, indices: vec![part] }, i64t);
                                let off = cx.int(i64t, 8 * part as i64);
                                let p = s.op(gep8(i8t, ptr, off), ptr_ty);
                                let st = s.f.add_inst(
                                    Op::Store { volatile: false, atomic: None, value: e, ptr: p, align: Some(8) },
                                    None,
                                );
                                s.new.push(st);
                            }
                            true
                        }
                        None => false,
                    }
                }
                Op::Load { ptr, volatile: false, atomic: None, .. } => {
                    let r = s.f.insts[i.index()].result.unwrap();
                    let ty = s.f.locals[r.index()].ty;
                    match parts_of(cx, ty) {
                        Some(n) => {
                            let ptr_ty = cx.m.types.ptr(0);
                            let mut agg = Value::Const(cx.m.consts.intern(Constant { ty, kind: ConstKind::Poison }));
                            for part in 0..n {
                                let off = cx.int(i64t, 8 * part as i64);
                                let p = s.op(gep8(i8t, ptr, off), ptr_ty);
                                let v = s.op(Op::Load { volatile: false, atomic: None, ptr: p, align: Some(8) }, i64t);
                                agg = s.op(Op::InsertValue { aggregate: agg, element: v, indices: vec![part] }, ty);
                            }
                            s.f.replace_uses(Value::Local(r), agg);
                            true
                        }
                        None => false,
                    }
                }
                _ => false,
            };
            let new = std::mem::take(&mut s.new);
            if done {
                let n = new.len();
                f.blocks[b.index()].insts.splice(k..=k, new);
                k += n;
            } else {
                k += 1;
            }
        }
    }
}

/// Arithmetic with overflow (`llvm.sadd.with.overflow.i32`, as Rust's
/// overflow checks call it): the result and whether it overflowed, as a
/// struct the selector keeps as its parts. It runs before wide integers
/// are split, so `i128` sums are, and a 64-bit product's high half is the
/// shape `wide.rs` keeps for instructions such as `umulh`.
///
/// - unsigned sums overflow if the result is below an operand, differences
///   if the first operand is below the second;
/// - signed ones if the result's sign differs from both operands' (sums),
///   or from the first's while the operands' differ (differences);
/// - products narrower than 64 bits are made at twice the width and
///   overflow if they do not fit back; 64-bit ones overflow if the high
///   half is not zero (unsigned) or not the low half's sign (signed: the
///   unsigned high half less each operand where the other is negative).
fn expand_overflow(cx: &mut Ctx, f: &mut Function) -> Result<(), String> {
    let blocks: Vec<BlockId> = f.layout.clone();
    for b in blocks {
        let mut k = 0;
        while k < f.blocks[b.index()].insts.len() {
            let i = f.blocks[b.index()].insts[k];
            let Op::Call(call) = &f.insts[i.index()].op else {
                k += 1;
                continue;
            };
            let name = callee_name(cx.m, call).unwrap_or_default();
            let Some(kind) = name.strip_prefix("llvm.").and_then(|n| n.split_once(".with.overflow")).map(|x| x.0)
            else {
                k += 1;
                continue;
            };
            let kind = kind.to_string();
            let (a, b2) = (call.args[0].value, call.args[1].value);
            let r = f.insts[i.index()].result.ok_or("an overflow intrinsic without a result")?;
            let sty = f.locals[r.index()].ty;
            let ty = cx.value_ty(f, a);
            let Type::Int(bits) = *cx.m.types.get(ty) else {
                return Err(format!("{name} of vectors is not supported yet"));
            };
            let i1 = cx.m.types.int(1);
            let mut s = Seq { f, new: Vec::new() };
            let zero = cx.int(ty, 0);
            let cmp = |s: &mut Seq, pred, l, r| s.op(Op::ICmp { pred, samesign: false, lhs: l, rhs: r }, i1);
            let (value, ov) = match kind.as_str() {
                "uadd" | "sadd" | "usub" | "ssub" => {
                    let op = if kind.ends_with("add") { BinOp::Add } else { BinOp::Sub };
                    let v = s.bin(op, a, b2, ty);
                    let ov = match kind.as_str() {
                        "uadd" => cmp(&mut s, ICmpPred::Ult, v, a),
                        "usub" => cmp(&mut s, ICmpPred::Ult, a, b2),
                        _ => {
                            let (x, y) = if kind == "sadd" { (a, b2) } else { (a, a) };
                            let p = s.bin(BinOp::Xor, x, v, ty);
                            let q = if kind == "sadd" {
                                s.bin(BinOp::Xor, b2, v, ty)
                            } else {
                                s.bin(BinOp::Xor, y, b2, ty)
                            };
                            let both = s.bin(BinOp::And, p, q, ty);
                            cmp(&mut s, ICmpPred::Slt, both, zero)
                        }
                    };
                    (v, ov)
                }
                "umul" | "smul" if bits <= 32 => {
                    let wide = cx.m.types.int(2 * bits);
                    let ext = if kind == "umul" { CastOp::ZExt } else { CastOp::SExt };
                    let (wa, wb) = (s.cast(ext, a, wide), s.cast(ext, b2, wide));
                    let p = s.bin(BinOp::Mul, wa, wb, wide);
                    let v = s.cast(CastOp::Trunc, p, ty);
                    let back = s.cast(ext, v, wide);
                    (v, cmp(&mut s, ICmpPred::Ne, back, p))
                }
                "umul" | "smul" if bits == 64 => {
                    let i128t = cx.m.types.int(128);
                    let v = s.bin(BinOp::Mul, a, b2, ty);
                    let (wa, wb) = (s.cast(CastOp::ZExt, a, i128t), s.cast(CastOp::ZExt, b2, i128t));
                    let p = s.bin(BinOp::Mul, wa, wb, i128t);
                    let sh = cx.int(i128t, 64);
                    let h = s.bin(BinOp::LShr, p, sh, i128t);
                    let mut hi = s.cast(CastOp::Trunc, h, ty);
                    if kind == "umul" {
                        (v, cmp(&mut s, ICmpPred::Ne, hi, zero))
                    } else {
                        let c63 = cx.int(ty, 63);
                        for (x, y) in [(a, b2), (b2, a)] {
                            let sign = s.bin(BinOp::AShr, x, c63, ty);
                            let take = s.bin(BinOp::And, sign, y, ty);
                            hi = s.bin(BinOp::Sub, hi, take, ty);
                        }
                        let sign = s.bin(BinOp::AShr, v, c63, ty);
                        (v, cmp(&mut s, ICmpPred::Ne, hi, sign))
                    }
                }
                // 128 bits, from the 64-bit halves (a = ah:al, b = bh:bl):
                // it overflows if both high halves are nonzero, if either
                // cross product (ah*bl, al*bh) needs more than 64 bits, or
                // if the middle column (their low halves, plus the carry
                // from al*bl) carries out.
                "umul" if bits == 128 => umul128_overflow(cx, &mut s, a, b2, ty),
                // Signed, by the magnitudes: the unsigned product must not
                // overflow, and must fit the sign: up to 2^127 - 1, or
                // 2^127 when negative.
                "smul" if bits == 128 => {
                    let zero = cx.int(ty, 0);
                    let mag = |s: &mut Seq, x: Value| {
                        let neg = s.op(Op::ICmp { pred: ICmpPred::Slt, samesign: false, lhs: x, rhs: zero }, i1);
                        let minus = s.bin(BinOp::Sub, zero, x, ty);
                        let m = s.op(
                            Op::Select { fmf: FastMath::default(), cond: neg, then_value: minus, else_value: x },
                            ty,
                        );
                        (neg, m)
                    };
                    let (na, ma) = mag(&mut s, a);
                    let (nb, mb) = mag(&mut s, b2);
                    let (p, uov) = umul128_overflow(cx, &mut s, ma, mb, ty);
                    let neg = s.bin(BinOp::Xor, na, nb, i1);
                    let max = Value::Const(cx.m.consts.intern(Constant { ty, kind: ConstKind::Int(signed_max(128)) }));
                    let extra = s.cast(CastOp::ZExt, neg, ty);
                    let limit = s.bin(BinOp::Add, max, extra, ty);
                    let past = cmp(&mut s, ICmpPred::Ugt, p, limit);
                    let ov = s.bin(BinOp::Or, uov, past, i1);
                    (s.bin(BinOp::Mul, a, b2, ty), ov)
                }
                _ => return Err(format!("{name} is not supported yet")),
            };
            replace_pair(cx, &mut s, r, sty, value, ov);
            let new = std::mem::take(&mut s.new);
            // (Extractvalues before it in its block were removed.)
            let k0 = f.blocks[b.index()].insts.iter().position(|&j| j == i).unwrap();
            k = k0;
            let n = new.len();
            f.blocks[b.index()].insts.splice(k..=k, new);
            k += n;
        }
    }
    Ok(())
}

/// The uses of `r`, a pair (`{ i64, i1 }`) now made as `a` and `b`: its
/// extractvalues take them; anything else, a struct made of them (at the
/// end of `s`). The extractvalues are removed from their blocks.
pub(crate) fn replace_pair(cx: &mut Ctx, s: &mut Seq, r: LocalId, sty: TypeId, a: Value, b: Value) {
    let mut gone = Vec::new();
    let mut others = false;
    let order: Vec<InstId> = s.f.insts_in_order().collect();
    for j in order {
        match &s.f.insts[j.index()].op {
            Op::ExtractValue { aggregate: Value::Local(x), indices } if *x == r && indices.len() == 1 => {
                let part = if indices[0] == 0 { a } else { b };
                if let Some(e) = s.f.insts[j.index()].result {
                    s.f.replace_uses(Value::Local(e), part);
                }
                gone.push(j);
            }
            op => op.for_each_value(|v| others |= *v == Value::Local(r)),
        }
    }
    for blk in s.f.blocks.iter_mut() {
        blk.insts.retain(|j| !gone.contains(j));
    }
    if others {
        let poison = Value::Const(cx.m.consts.intern(Constant { ty: sty, kind: ConstKind::Poison }));
        let x = s.op(Op::InsertValue { aggregate: poison, element: a, indices: vec![0] }, sty);
        let y = s.op(Op::InsertValue { aggregate: x, element: b, indices: vec![1] }, sty);
        s.f.replace_uses(Value::Local(r), y);
    }
}

fn scalar_float(cx: &Ctx, ty: TypeId) -> bool {
    matches!(cx.m.types.get(ty), Type::Float | Type::Double)
}

/// The C library function an intrinsic (`llvm.log2`) is, if it is one.
fn libm_base(base: &str) -> Option<&'static str> {
    Some(match base.strip_prefix("llvm.")? {
        "sin" => "sin",
        "cos" => "cos",
        "tan" => "tan",
        "asin" => "asin",
        "acos" => "acos",
        "atan" => "atan",
        "atan2" => "atan2",
        "sinh" => "sinh",
        "cosh" => "cosh",
        "tanh" => "tanh",
        "exp" => "exp",
        "exp2" => "exp2",
        "exp10" => "exp10",
        "log" => "log",
        "log2" => "log2",
        "log10" => "log10",
        "pow" => "pow",
        "fma" => "fma",
        "powi" => "powi",
        "ldexp" => "ldexp",
        _ => return None,
    })
}

/// The C library's name for function `c` (`log2`) at floating-point type
/// `ty` (or its lanes'): `log2` for double, `log2f` for float. `powi` is
/// the runtime's (`__powidf2`, `__powisf2`).
fn libm_name(cx: &Ctx, c: &str, ty: TypeId) -> Option<String> {
    let elem = match cx.m.types.get(ty) {
        Type::Vector { elem, .. } => *elem,
        _ => ty,
    };
    let float = match cx.m.types.get(elem) {
        Type::Double => false,
        Type::Float => true,
        _ => return None,
    };
    Some(match (c, float) {
        ("powi", false) => "__powidf2".into(),
        ("powi", true) => "__powisf2".into(),
        (c, false) => c.into(),
        (c, true) => format!("{c}f"),
    })
}

/// A call of `name` with `args`, of result type `ty`; of a vector type,
/// one for each lane (vector arguments taken lane by lane, the others as
/// they are).
fn lanewise_call(cx: &mut Ctx, s: &mut Seq, name: &str, args: Vec<Value>, ty: TypeId) -> Value {
    let Type::Vector { len, elem, .. } = *cx.m.types.get(ty) else {
        return call_intrinsic(cx, s, name, args, ty);
    };
    let i64t = cx.m.types.int(64);
    let mut v = Value::Const(cx.m.consts.intern(Constant { ty, kind: ConstKind::Poison }));
    for lane in 0..len {
        let idx = cx.int(i64t, lane as i64);
        let mut a = Vec::new();
        for &x in &args {
            match *cx.m.types.get(cx.value_ty(s.f, x)) {
                Type::Vector { elem: e, .. } => a.push(s.op(Op::ExtractElement { vector: x, index: idx }, e)),
                _ => a.push(x),
            }
        }
        let y = call_intrinsic(cx, s, name, a, elem);
        v = s.op(Op::InsertElement { vector: v, element: y, index: idx }, ty);
    }
    v
}

/// The largest signed value of `bits` bits, 2^(bits - 1) - 1.
fn signed_max(bits: u32) -> ApInt {
    let ones = bits - 1;
    let lead = ones % 4;
    let mut hex = String::new();
    if lead > 0 {
        hex.push(char::from_digit((1 << lead) - 1, 16).unwrap());
    }
    hex.push_str(&"f".repeat((ones / 4) as usize));
    ApInt::parse_hex(bits, &hex, false).unwrap()
}

/// The product of two `i128`s, and whether it overflows unsigned: from the
/// 64-bit halves (a = ah:al, b = bh:bl), it does if both high halves are
/// nonzero, if either cross product (ah*bl, al*bh) needs more than 64
/// bits, or if the middle column (their low halves, plus the carry from
/// al*bl) carries out.
fn umul128_overflow(cx: &mut Ctx, s: &mut Seq, a: Value, b2: Value, ty: TypeId) -> (Value, Value) {
    let i1 = cx.m.types.int(1);
    let cmp = |s: &mut Seq, pred, l, r| s.op(Op::ICmp { pred, samesign: false, lhs: l, rhs: r }, i1);
    let i64t = cx.m.types.int(64);
    let c64 = cx.int(ty, 64);
    let lo64 = |s: &mut Seq, x: Value| s.cast(CastOp::Trunc, x, i64t);
    let hi64 = |s: &mut Seq, x: Value| {
        let h = s.bin(BinOp::LShr, x, c64, ty);
        s.cast(CastOp::Trunc, h, i64t)
    };
    let (al, ah, bl, bh) = (lo64(s, a), hi64(s, a), lo64(s, b2), hi64(s, b2));
    let wide = |s: &mut Seq, x: Value, y: Value| {
        let (wx, wy) = (s.cast(CastOp::ZExt, x, ty), s.cast(CastOp::ZExt, y, ty));
        s.bin(BinOp::Mul, wx, wy, ty)
    };
    let (p0, p1, p2) = (wide(s, al, bl), wide(s, ah, bl), wide(s, al, bh));
    let z64 = cx.int(i64t, 0);
    let ah_nz = cmp(s, ICmpPred::Ne, ah, z64);
    let bh_nz = cmp(s, ICmpPred::Ne, bh, z64);
    let mut ov = s.bin(BinOp::And, ah_nz, bh_nz, i1);
    let (h1, h2) = (hi64(s, p1), hi64(s, p2));
    for h in [h1, h2] {
        let nz = cmp(s, ICmpPred::Ne, h, z64);
        ov = s.bin(BinOp::Or, ov, nz, i1);
    }
    let (l1, l2) = (lo64(s, p1), lo64(s, p2));
    let (w1, w2) = (s.cast(CastOp::ZExt, l1, ty), s.cast(CastOp::ZExt, l2, ty));
    let carry = s.bin(BinOp::LShr, p0, c64, ty);
    let mid = s.bin(BinOp::Add, w1, w2, ty);
    let mid = s.bin(BinOp::Add, mid, carry, ty);
    let out = hi64(s, mid);
    let nz = cmp(s, ICmpPred::Ne, out, z64);
    ov = s.bin(BinOp::Or, ov, nz, i1);
    (s.bin(BinOp::Mul, a, b2, ty), ov)
}

/// Intrinsics of 128-bit integers that `wide.rs` has no halves for,
/// written as `i128` operations it does: three-way comparisons, and
/// saturating additions and subtractions.
fn wide_intrinsics(cx: &mut Ctx, f: &mut Function) {
    let i1 = cx.m.types.int(1);
    let blocks: Vec<BlockId> = f.layout.clone();
    for b in blocks {
        let mut k = 0;
        while k < f.blocks[b.index()].insts.len() {
            let i = f.blocks[b.index()].insts[k];
            let Op::Call(call) = &f.insts[i.index()].op else {
                k += 1;
                continue;
            };
            let name = callee_name(cx.m, call).unwrap_or_default();
            let args: Vec<Value> = call.args.iter().map(|a| a.value).collect();
            let (Some(r), Some(&a0)) = (f.insts[i.index()].result, args.first()) else {
                k += 1;
                continue;
            };
            let aty = cx.value_ty(f, a0);
            if !matches!(cx.m.types.get(aty), Type::Int(b) if *b > 64) {
                k += 1;
                continue;
            }
            let rty = f.locals[r.index()].ty;
            // `llvm.scmp`, `llvm.usub.sat`: the name without its types.
            let is_type =
                |p: &&str| p.strip_prefix('i').is_some_and(|d| !d.is_empty() && d.bytes().all(|c| c.is_ascii_digit()));
            let base = name.split('.').take_while(|p| !is_type(p)).collect::<Vec<_>>().join(".");
            let mut s = Seq { f, new: Vec::new() };
            let cmp = |s: &mut Seq, pred, l, r| s.op(Op::ICmp { pred, samesign: false, lhs: l, rhs: r }, i1);
            let sel = |s: &mut Seq, c, t, e, ty| {
                s.op(Op::Select { fmf: FastMath::default(), cond: c, then_value: t, else_value: e }, ty)
            };
            let (a, bv) = (a0, args.get(1).copied().unwrap_or(a0));
            let v = match base.as_str() {
                // (a > b) - (a < b)
                "llvm.scmp" | "llvm.ucmp" => {
                    let (gt, lt) = if base == "llvm.scmp" {
                        (ICmpPred::Sgt, ICmpPred::Slt)
                    } else {
                        (ICmpPred::Ugt, ICmpPred::Ult)
                    };
                    let g = cmp(&mut s, gt, a, bv);
                    let l = cmp(&mut s, lt, a, bv);
                    let g = s.cast(CastOp::ZExt, g, rty);
                    let l = s.cast(CastOp::ZExt, l, rty);
                    s.bin(BinOp::Sub, g, l, rty)
                }
                "llvm.usub.sat" => {
                    let d = s.bin(BinOp::Sub, a, bv, aty);
                    let ok = cmp(&mut s, ICmpPred::Uge, a, bv);
                    let zero = cx.int(aty, 0);
                    sel(&mut s, ok, d, zero, aty)
                }
                "llvm.uadd.sat" => {
                    let t = s.bin(BinOp::Add, a, bv, aty);
                    let wrapped = cmp(&mut s, ICmpPred::Ult, t, a);
                    let ones = cx.int(aty, -1);
                    sel(&mut s, wrapped, ones, t, aty)
                }
                // Overflowed if the result's sign is not what the operands
                // say; then the limit on the side of a's sign.
                "llvm.sadd.sat" | "llvm.ssub.sat" => {
                    let add = base == "llvm.sadd.sat";
                    let t = s.bin(if add { BinOp::Add } else { BinOp::Sub }, a, bv, aty);
                    let x = s.bin(BinOp::Xor, a, t, aty);
                    let y = if add { s.bin(BinOp::Xor, bv, t, aty) } else { s.bin(BinOp::Xor, a, bv, aty) };
                    let both = s.bin(BinOp::And, x, y, aty);
                    let zero = cx.int(aty, 0);
                    let ov = cmp(&mut s, ICmpPred::Slt, both, zero);
                    let bits = match cx.m.types.get(aty) {
                        Type::Int(b) => *b,
                        _ => 128,
                    };
                    let max =
                        Value::Const(cx.m.consts.intern(Constant { ty: aty, kind: ConstKind::Int(signed_max(bits)) }));
                    let neg = cmp(&mut s, ICmpPred::Slt, a, zero);
                    let min = s.bin(BinOp::Xor, max, cx.int(aty, -1), aty);
                    let limit = sel(&mut s, neg, min, max, aty);
                    sel(&mut s, ov, limit, t, aty)
                }
                _ => {
                    k += 1;
                    continue;
                }
            };
            s.f.replace_uses(Value::Local(r), v);
            let new = std::mem::take(&mut s.new);
            let n = new.len();
            f.blocks[b.index()].insts.splice(k..=k, new);
            k += n;
        }
    }
}

fn expand_intrinsics(cx: &mut Ctx, f: &mut Function) {
    let blocks: Vec<BlockId> = f.layout.clone();
    for b in blocks {
        let mut k = 0;
        while k < f.blocks[b.index()].insts.len() {
            let i = f.blocks[b.index()].insts[k];
            let Op::Call(call) = &f.insts[i.index()].op else {
                k += 1;
                continue;
            };
            let Some(name) = callee_name(cx.m, call) else {
                k += 1;
                continue;
            };
            let args: Vec<Value> = call.args.iter().map(|a| a.value).collect();
            let Some(r) = f.insts[i.index()].result else {
                k += 1;
                continue;
            };
            let ty = f.locals[r.index()].ty;
            // Scalars only: vector intrinsics have instructions.
            let bits = match cx.m.types.get(ty) {
                Type::Int(b) => *b,
                _ => 64,
            };
            let scalar = matches!(cx.m.types.get(ty), Type::Int(_));
            let i1 = cx.m.types.int(1);
            let mut s = Seq { f, new: Vec::new() };
            let base = name.split('.').take(2).collect::<Vec<_>>().join(".");
            let minmax = match base.as_str() {
                "llvm.smax" => Some(ICmpPred::Sgt),
                "llvm.smin" => Some(ICmpPred::Slt),
                "llvm.umax" => Some(ICmpPred::Ugt),
                "llvm.umin" => Some(ICmpPred::Ult),
                _ => None,
            };
            // An ordered floating-point reduction: the start value, then
            // each lane added (or multiplied) in order, as written.
            if (name.starts_with("llvm.vector.reduce.fadd.") || name.starts_with("llvm.vector.reduce.fmul."))
                && let Type::Vector { len, elem, .. } = cx.m.types.get(cx.value_ty(s.f, args[1])).clone()
            {
                let i64t = cx.m.types.int(64);
                let op = if name.contains(".fadd.") { BinOp::FAdd } else { BinOp::FMul };
                let mut acc = args[0];
                for lane in 0..len {
                    let idx = cx.int(i64t, lane as i64);
                    let e = s.op(Op::ExtractElement { vector: args[1], index: idx }, elem);
                    acc =
                        s.op(Op::Binary { op, flags: IntFlags::NONE, fmf: FastMath::default(), lhs: acc, rhs: e }, ty);
                }
                let new = std::mem::take(&mut s.new);
                f.replace_uses(Value::Local(r), acc);
                let n = new.len();
                f.blocks[b.index()].insts.splice(k..=k, new);
                k += n;
                continue;
            }
            // A pointer with some bits cleared: of its integer.
            if name.starts_with("llvm.ptrmask.") && matches!(cx.m.types.get(ty), Type::Ptr(_)) {
                let mty = cx.value_ty(s.f, args[1]);
                let p = s.cast(CastOp::PtrToInt, args[0], mty);
                let masked = s.bin(BinOp::And, p, args[1], mty);
                let v = s.cast(CastOp::IntToPtr, masked, ty);
                let new = std::mem::take(&mut s.new);
                f.replace_uses(Value::Local(r), v);
                let n = new.len();
                f.blocks[b.index()].insts.splice(k..=k, new);
                k += n;
                continue;
            }
            // A funnel shift by a constant, of vectors or (where the
            // description has no instruction for it) of scalars: two shifts
            // and an or. By a variable amount, which no instruction takes,
            // the same with the amount masked, and the other shift done in
            // two steps so that it is never by the full width.
            let vector = matches!(cx.m.types.get(ty), Type::Vector { .. });
            if base == "llvm.fshl" || base == "llvm.fshr" {
                let elem = match cx.m.types.get(ty).clone() {
                    Type::Vector { elem, .. } => elem,
                    _ => ty,
                };
                let eb = match cx.m.types.get(elem) {
                    Type::Int(b) => *b as i64,
                    _ => 64,
                };
                let amount = |cx: &mut Ctx, v: i64| -> Value {
                    let e = cx.int(elem, v);
                    if !vector {
                        return e;
                    }
                    let Value::Const(e) = e else { unreachable!() };
                    Value::Const(cx.m.consts.intern(Constant { ty, kind: ConstKind::Splat(e) }))
                };
                let constant = match args[2] {
                    Value::Const(c) => crate::target::lit_of(cx.m, c),
                    _ => None,
                };
                // A rotation by a variable amount, where the description
                // has one (the role "rotr.iN"): right as it is, left as
                // right by the negated amount.
                let rotate =
                    !vector && constant.is_none() && args[0] == args[1] && cx.t.role(&format!("rotr.i{eb}")).is_some();
                if rotate && base == "llvm.fshl" {
                    let zero = cx.int(ty, 0);
                    let neg = s.bin(BinOp::Sub, zero, args[2], ty);
                    let v = call_intrinsic(cx, &mut s, &format!("llvm.fshr.i{eb}"), vec![args[0], args[0], neg], ty);
                    let new = std::mem::take(&mut s.new);
                    f.replace_uses(Value::Local(r), v);
                    let n = new.len();
                    f.blocks[b.index()].insts.splice(k..=k, new);
                    k += n;
                    continue;
                }
                let value = match constant {
                    _ if rotate => None,
                    Some(_) if !vector && cx.selects_intrinsic(&name) => None,
                    Some(c) => {
                        // fshl(a, b, c) is (a << c) | (b >> (w - c)); fshr(a, b, c)
                        // is fshl(a, b, w - c).
                        let amt = c.0.rem_euclid(eb);
                        let amt = if base == "llvm.fshr" { (eb - amt) % eb } else { amt };
                        Some(if amt == 0 {
                            if base == "llvm.fshr" { args[1] } else { args[0] }
                        } else {
                            let (a, b) = (amount(cx, amt), amount(cx, eb - amt));
                            let hi = s.bin(BinOp::Shl, args[0], a, ty);
                            let lo = s.bin(BinOp::LShr, args[1], b, ty);
                            s.bin(BinOp::Or, hi, lo, ty)
                        })
                    }
                    None => {
                        // fshl: (a << c) | ((b >> 1) >> (w - 1 - c));
                        // fshr: ((a << 1) << (w - 1 - c)) | (b >> c); c mod w.
                        let mask = amount(cx, eb - 1);
                        let one = amount(cx, 1);
                        let c = s.bin(BinOp::And, args[2], mask, ty);
                        let rest = s.bin(BinOp::Xor, c, mask, ty);
                        Some(if base == "llvm.fshl" {
                            let hi = s.bin(BinOp::Shl, args[0], c, ty);
                            let lo = s.bin(BinOp::LShr, args[1], one, ty);
                            let lo = s.bin(BinOp::LShr, lo, rest, ty);
                            s.bin(BinOp::Or, hi, lo, ty)
                        } else {
                            let hi = s.bin(BinOp::Shl, args[0], one, ty);
                            let hi = s.bin(BinOp::Shl, hi, rest, ty);
                            let lo = s.bin(BinOp::LShr, args[1], c, ty);
                            s.bin(BinOp::Or, hi, lo, ty)
                        })
                    }
                };
                if let Some(value) = value {
                    let new = std::mem::take(&mut s.new);
                    f.replace_uses(Value::Local(r), value);
                    let n = new.len();
                    f.blocks[b.index()].insts.splice(k..=k, new);
                    k += n;
                    continue;
                }
            }
            // ctlz and cttz may say a zero input gives poison; giving the
            // full width instead is always allowed, and is what clz does.
            if (base == "llvm.ctlz" || base == "llvm.cttz") && args.len() == 2 {
                let no = cx.int(i1, 0);
                if let Op::Call(c) = &mut s.f.insts[i.index()].op {
                    c.args[1].value = no;
                }
            }
            // The classes of a float (`llvm.is.fpclass`), from its bits: the
            // magnitude against the exponent's limits, the quiet bit, the
            // sign. Mask bits 0-9: signalling NaN, quiet NaN, -inf,
            // -normal, -subnormal, -0, +0, +subnormal, +normal, +inf.
            if name.starts_with("llvm.is.fpclass.") && scalar_float(cx, cx.value_ty(s.f, args[0])) {
                let fty = cx.value_ty(s.f, args[0]);
                let double = matches!(cx.m.types.get(fty), Type::Double);
                let (bits, exp, quiet, min_normal): (u32, i64, i64, i64) = if double {
                    (64, 0x7ff0_0000_0000_0000, 0x0008_0000_0000_0000, 0x0010_0000_0000_0000)
                } else {
                    (32, 0x7f80_0000, 0x0040_0000, 0x0080_0000)
                };
                let it = cx.m.types.int(bits);
                let mask = cx.const_int(args[1]).unwrap_or(0);
                let x = s.cast(CastOp::BitCast, args[0], it);
                let c = |cx: &mut Ctx, v: i64| cx.int(it, v);
                let all = c(cx, if double { i64::MAX } else { 0x7fff_ffff });
                let abs = s.bin(BinOp::And, x, all, it);
                let cmp = |s: &mut Seq, p, l, r| s.op(Op::ICmp { pred: p, samesign: false, lhs: l, rhs: r }, i1);
                let and1 = |s: &mut Seq, a, b| s.bin(BinOp::And, a, b, i1);
                let zero = c(cx, 0);
                let neg = cmp(&mut s, ICmpPred::Slt, x, zero);
                let t = cx.int(i1, 1);
                let pos = s.bin(BinOp::Xor, neg, t, i1);
                let e = c(cx, exp);
                let q = c(cx, quiet);
                let mn = c(cx, min_normal);
                let nan = cmp(&mut s, ICmpPred::Ugt, abs, e);
                let qbit = s.bin(BinOp::And, abs, q, it);
                let is_q = cmp(&mut s, ICmpPred::Ne, qbit, zero);
                let inf = cmp(&mut s, ICmpPred::Eq, abs, e);
                let z = cmp(&mut s, ICmpPred::Eq, abs, zero);
                let below = cmp(&mut s, ICmpPred::Ult, abs, mn);
                let nz = s.bin(BinOp::Xor, z, t, i1);
                let sub = and1(&mut s, below, nz);
                let from = cmp(&mut s, ICmpPred::Uge, abs, mn);
                let under = cmp(&mut s, ICmpPred::Ult, abs, e);
                let normal = and1(&mut s, from, under);
                let not_q = s.bin(BinOp::Xor, is_q, t, i1);
                let classes: [Value; 10] = [
                    and1(&mut s, nan, not_q),
                    and1(&mut s, nan, is_q),
                    and1(&mut s, inf, neg),
                    and1(&mut s, normal, neg),
                    and1(&mut s, sub, neg),
                    and1(&mut s, z, neg),
                    and1(&mut s, z, pos),
                    and1(&mut s, sub, pos),
                    and1(&mut s, normal, pos),
                    and1(&mut s, inf, pos),
                ];
                let mut v = cx.int(i1, 0);
                for (k, &cl) in classes.iter().enumerate() {
                    if mask & (1 << k) != 0 {
                        v = s.bin(BinOp::Or, v, cl, i1);
                    }
                }
                let new = std::mem::take(&mut s.new);
                f.replace_uses(Value::Local(r), v);
                let n = new.len();
                f.blocks[b.index()].insts.splice(k..=k, new);
                k += n;
                continue;
            }
            // Floating-point maximum and minimum across lanes, without an
            // instruction: the scalar ones, lane by lane.
            if let Some(op) = ["fmax", "fmin", "fmaximum", "fminimum"]
                .into_iter()
                .find(|o| name.starts_with(&format!("llvm.vector.reduce.{o}.")))
                && !cx.selects_intrinsic(&name)
                && let Type::Vector { len, elem, scalable: false } = *cx.m.types.get(cx.value_ty(s.f, args[0]))
            {
                let scalar = match op {
                    "fmax" => "maxnum",
                    "fmin" => "minnum",
                    "fmaximum" => "maximum",
                    _ => "minimum",
                };
                let suf = if matches!(cx.m.types.get(elem), Type::Float) { "f32" } else { "f64" };
                let i64t = cx.m.types.int(64);
                let lane = |cx: &mut Ctx, s: &mut Seq, l: u32| {
                    let idx = cx.int(i64t, i64::from(l));
                    s.op(Op::ExtractElement { vector: args[0], index: idx }, elem)
                };
                let mut acc = lane(cx, &mut s, 0);
                for l in 1..len {
                    let x = lane(cx, &mut s, l);
                    acc = call_intrinsic(cx, &mut s, &format!("llvm.{scalar}.{suf}"), vec![acc, x], elem);
                }
                let new = std::mem::take(&mut s.new);
                f.replace_uses(Value::Local(r), acc);
                let n = new.len();
                f.blocks[b.index()].insts.splice(k..=k, new);
                k += n;
                continue;
            }
            // Whether any (or every) lane of a mask is set: the unsigned
            // maximum (minimum) of its lanes as integers, all ones or zeros.
            if (name.starts_with("llvm.vector.reduce.or.") || name.starts_with("llvm.vector.reduce.and."))
                && let Type::Vector { len, elem, scalable: false } = *cx.m.types.get(cx.value_ty(s.f, args[0]))
                && elem == i1
                && len.is_power_of_two()
                && len > 1
            {
                let w = (128 / len).clamp(8, 64);
                let e = cx.m.types.int(w);
                let it = cx.m.types.intern(Type::Vector { len, elem: e, scalable: false });
                let wide = s.cast(CastOp::SExt, args[0], it);
                let red = if name.contains(".or.") { "umax" } else { "umin" };
                let x = call_intrinsic(cx, &mut s, &format!("llvm.vector.reduce.{red}.v{len}i{w}"), vec![wide], e);
                let zero = cx.int(e, 0);
                let v = s.op(Op::ICmp { pred: ICmpPred::Ne, samesign: false, lhs: x, rhs: zero }, i1);
                let new = std::mem::take(&mut s.new);
                f.replace_uses(Value::Local(r), v);
                let n = new.len();
                f.blocks[b.index()].insts.splice(k..=k, new);
                k += n;
                continue;
            }
            // The first set lane of a mask: of the mask as an integer, its
            // trailing zeros (all the lanes, if none is set).
            if name.starts_with("llvm.experimental.cttz.elts.")
                && let Type::Vector { len, .. } = *cx.m.types.get(cx.value_ty(s.f, args[0]))
            {
                let it = cx.m.types.int(len);
                let bits = s.cast(CastOp::BitCast, args[0], it);
                let no = cx.int(i1, 0);
                let n = call_intrinsic(cx, &mut s, &format!("llvm.cttz.i{len}"), vec![bits, no], it);
                let rb = match cx.m.types.get(ty) {
                    Type::Int(b) => *b,
                    _ => 64,
                };
                let v = match rb.cmp(&len) {
                    std::cmp::Ordering::Greater => s.cast(CastOp::ZExt, n, ty),
                    std::cmp::Ordering::Less => s.cast(CastOp::Trunc, n, ty),
                    std::cmp::Ordering::Equal => n,
                };
                let new = std::mem::take(&mut s.new);
                f.replace_uses(Value::Local(r), v);
                let n = new.len();
                f.blocks[b.index()].insts.splice(k..=k, new);
                k += n;
                continue;
            }
            // Mathematical functions without an instruction: the C
            // library's (lane by lane, for vectors), as LLVM calls them.
            if let Some(c) = libm_base(&base)
                && !cx.selects_intrinsic(&name)
                && let Some(lib) = libm_name(cx, c, ty)
            {
                let v = lanewise_call(cx, &mut s, &lib, args.clone(), ty);
                let new = std::mem::take(&mut s.new);
                f.replace_uses(Value::Local(r), v);
                let n = new.len();
                f.blocks[b.index()].insts.splice(k..=k, new);
                k += n;
                continue;
            }
            // The sign of one, the rest of the other: as integers.
            if base == "llvm.copysign" && !cx.selects_intrinsic(&name) {
                let (ity, bits) = match cx.m.types.get(ty).clone() {
                    Type::Vector { len, elem, scalable: false } => {
                        let b = cx.size_of(elem).unwrap_or(8) as u32 * 8;
                        let e = cx.m.types.int(b);
                        (cx.m.types.intern(Type::Vector { len, elem: e, scalable: false }), b)
                    }
                    _ => {
                        let b = cx.size_of(ty).unwrap_or(8) as u32 * 8;
                        (cx.m.types.int(b), b)
                    }
                };
                let elem_int = match cx.m.types.get(ity) {
                    Type::Vector { elem, .. } => *elem,
                    _ => ity,
                };
                let sign_c = cx
                    .m
                    .consts
                    .intern(Constant { ty: elem_int, kind: ConstKind::Int(ApInt::from_u64(bits, 1u64 << (bits - 1))) });
                let rest_c = cx.m.consts.intern(Constant {
                    ty: elem_int,
                    kind: ConstKind::Int(ApInt::from_u64(bits, (1u64 << (bits - 1)) - 1)),
                });
                let splat = |cx: &mut Ctx, c: ConstId| {
                    if ity == elem_int {
                        Value::Const(c)
                    } else {
                        Value::Const(cx.m.consts.intern(Constant { ty: ity, kind: ConstKind::Splat(c) }))
                    }
                };
                let (sign, rest) = (splat(cx, sign_c), splat(cx, rest_c));
                let a = s.cast(CastOp::BitCast, args[0], ity);
                let b2 = s.cast(CastOp::BitCast, args[1], ity);
                let a = s.bin(BinOp::And, a, rest, ity);
                let b2 = s.bin(BinOp::And, b2, sign, ity);
                let v = s.bin(BinOp::Or, a, b2, ity);
                let v = s.cast(CastOp::BitCast, v, ty);
                let new = std::mem::take(&mut s.new);
                f.replace_uses(Value::Local(r), v);
                let n = new.len();
                f.blocks[b.index()].insts.splice(k..=k, new);
                k += n;
                continue;
            }
            // Saturating conversions of vectors: lane by lane, by the
            // scalar one (`llvm.fptosi.sat.v2i32.v2f64` by `.i32.f64`).
            if (base == "llvm.fptosi" || base == "llvm.fptoui")
                && name.contains(".sat.")
                && !scalar
                && matches!(cx.m.types.get(ty), Type::Vector { .. })
                && !cx.selects_intrinsic(&name)
            {
                let lane_name: String = name
                    .split('.')
                    .map(|p| match p.strip_prefix('v') {
                        Some(rest) if rest.starts_with(|c: char| c.is_ascii_digit()) => {
                            rest.trim_start_matches(|c: char| c.is_ascii_digit()).to_string()
                        }
                        _ => p.to_string(),
                    })
                    .collect::<Vec<_>>()
                    .join(".");
                let v = lanewise_call(cx, &mut s, &lane_name, args.clone(), ty);
                let new = std::mem::take(&mut s.new);
                f.replace_uses(Value::Local(r), v);
                let n = new.len();
                f.blocks[b.index()].insts.splice(k..=k, new);
                k += n;
                continue;
            }
            // Saturating conversions without an instruction: the limits,
            // NaN as 0, else the plain conversion (defined there).
            if (base == "llvm.fptosi" || base == "llvm.fptoui")
                && name.contains(".sat.")
                && scalar
                && !cx.selects_intrinsic(&name)
            {
                let signed = base == "llvm.fptosi";
                let x = args[0];
                let fty = cx.value_ty(s.f, x);
                let fc = |cx: &mut Ctx, v: f64| {
                    let b = match cx.m.types.get(fty) {
                        Type::Float => u128::from((v as f32).to_bits()),
                        _ => u128::from(v.to_bits()),
                    };
                    Value::Const(cx.m.consts.intern(Constant { ty: fty, kind: ConstKind::Float(b) }))
                };
                let fcmp =
                    |s: &mut Seq, pred, l, r| s.op(Op::FCmp { pred, fmf: FastMath::default(), lhs: l, rhs: r }, i1);
                let sel = |s: &mut Seq, c, t, e| {
                    s.op(Op::Select { fmf: FastMath::default(), cond: c, then_value: t, else_value: e }, ty)
                };
                let (min, max, lo_bound, hi_bound) = if signed {
                    let h = 2f64.powi(bits as i32 - 1);
                    (cx.int(ty, i64::MIN >> (64 - bits)), cx.int(ty, i64::MAX >> (64 - bits)), -h, h)
                } else {
                    (cx.int(ty, 0), cx.int(ty, -1), -1.0, 2f64.powi(bits as i32))
                };
                let (lo_c, hi_c) = (fc(cx, lo_bound), fc(cx, hi_bound));
                let plain = s.cast(if signed { CastOp::FPToSI } else { CastOp::FPToUI }, x, ty);
                // Signed: below -2^(w-1) the minimum; unsigned: at -1 or
                // below, 0 (between -1 and 0 the conversion gives 0).
                let below = fcmp(&mut s, if signed { FCmpPred::Olt } else { FCmpPred::Ole }, x, lo_c);
                let v = sel(&mut s, below, min, plain);
                let above = fcmp(&mut s, FCmpPred::Oge, x, hi_c);
                let v = sel(&mut s, above, max, v);
                let nan = fcmp(&mut s, FCmpPred::Uno, x, x);
                let zero = cx.int(ty, 0);
                let v = sel(&mut s, nan, zero, v);
                let new = std::mem::take(&mut s.new);
                f.replace_uses(Value::Local(r), v);
                let n = new.len();
                f.blocks[b.index()].insts.splice(k..=k, new);
                k += n;
                continue;
            }
            // Bit counts and byte swaps of vectors without an instruction
            // (NEON counts only bytes' bits): lane by lane.
            if !scalar
                && matches!(base.as_str(), "llvm.ctpop" | "llvm.ctlz" | "llvm.cttz" | "llvm.bswap")
                && !cx.selects_intrinsic(&name)
                && let Type::Vector { len, elem, scalable: false } = *cx.m.types.get(ty)
                && let Type::Int(eb) = *cx.m.types.get(elem)
            {
                let i64t = cx.m.types.int(64);
                let mut v = Value::Const(cx.m.consts.intern(Constant { ty, kind: ConstKind::Poison }));
                for lane in 0..len {
                    let idx = cx.int(i64t, lane as i64);
                    let x = s.op(Op::ExtractElement { vector: args[0], index: idx }, elem);
                    let mut a = vec![x];
                    a.extend(args.iter().skip(1).copied());
                    let y = call_intrinsic(cx, &mut s, &format!("{base}.i{eb}"), a, elem);
                    v = s.op(Op::InsertElement { vector: v, element: y, index: idx }, ty);
                }
                let new = std::mem::take(&mut s.new);
                f.replace_uses(Value::Local(r), v);
                let n = new.len();
                f.blocks[b.index()].insts.splice(k..=k, new);
                k += n;
                continue;
            }
            // Bit counts and byte swaps without an instruction: widened to
            // a width that has one, or done with shifts and masks.
            if scalar
                && matches!(base.as_str(), "llvm.ctpop" | "llvm.ctlz" | "llvm.cttz" | "llvm.bswap")
                && !cx.selects_intrinsic(&name)
            {
                let value = bit_intrinsic(cx, &mut s, &base, args[0], bits, ty);
                let new = std::mem::take(&mut s.new);
                f.replace_uses(Value::Local(r), value);
                let n = new.len();
                f.blocks[b.index()].insts.splice(k..=k, new);
                k += n;
                continue;
            }
            let value = match (minmax, base.as_str()) {
                // Narrow minimum and maximum: compare and select.
                (Some(pred), _) if scalar && bits < 32 => {
                    let c = s.op(Op::ICmp { pred, samesign: false, lhs: args[0], rhs: args[1] }, i1);
                    Some(s.op(
                        Op::Select { fmf: FastMath::default(), cond: c, then_value: args[0], else_value: args[1] },
                        ty,
                    ))
                }
                // Vector minimum and maximum without an instruction (NEON's
                // of 64-bit lanes): compare and select, lane by lane.
                (Some(pred), _) if !scalar && !cx.selects_intrinsic(&name) => {
                    let Type::Vector { len, scalable: false, .. } = *cx.m.types.get(ty) else { unreachable!() };
                    let mask = cx.m.types.intern(Type::Vector { len, elem: i1, scalable: false });
                    let c = s.op(Op::ICmp { pred, samesign: false, lhs: args[0], rhs: args[1] }, mask);
                    Some(s.op(
                        Op::Select { fmf: FastMath::default(), cond: c, then_value: args[0], else_value: args[1] },
                        ty,
                    ))
                }
                // The size of the object a pointer points into, when it is
                // not known here: "unknown" is -1, or 0 if a lower bound
                // is asked for. (An optimiser folds the known cases.)
                (_, "llvm.objectsize") => {
                    let min = cx.const_int(args[1]).unwrap_or(0) != 0;
                    Some(cx.int(ty, if min { 0 } else { -1 }))
                }
                // Three-way comparison (Rust's `Ord::cmp`): 1, 0 or -1, as
                // (a > b) - (a < b).
                (_, "llvm.ucmp" | "llvm.scmp") if scalar => {
                    let signed = base == "llvm.scmp";
                    let (gt, lt) = if signed { (ICmpPred::Sgt, ICmpPred::Slt) } else { (ICmpPred::Ugt, ICmpPred::Ult) };
                    let g = s.op(Op::ICmp { pred: gt, samesign: false, lhs: args[0], rhs: args[1] }, i1);
                    let l = s.op(Op::ICmp { pred: lt, samesign: false, lhs: args[0], rhs: args[1] }, i1);
                    let (g, l) = (s.cast(CastOp::ZExt, g, ty), s.cast(CastOp::ZExt, l, ty));
                    Some(s.bin(BinOp::Sub, g, l, ty))
                }
                // Whether a value is known to be constant here: "no" is
                // always an allowed answer. (An optimiser folds the cases
                // it can see.)
                (_, "llvm.is") if name.starts_with("llvm.is.constant") => Some(cx.int(ty, 0)),
                // Saturating subtraction: a > b ? a - b : 0.
                (_, "llvm.usub") if scalar && name.starts_with("llvm.usub.sat") => {
                    let zero = cx.int(ty, 0);
                    let diff = s.bin(BinOp::Sub, args[0], args[1], ty);
                    let c = s.op(Op::ICmp { pred: ICmpPred::Ugt, samesign: false, lhs: args[0], rhs: args[1] }, i1);
                    Some(s.op(Op::Select { fmf: FastMath::default(), cond: c, then_value: diff, else_value: zero }, ty))
                }
                // Saturating addition: the sum, or all ones if it wrapped
                // (came out below an operand).
                (_, "llvm.uadd") if scalar && name.starts_with("llvm.uadd.sat") => {
                    let ones = cx.int(ty, -1);
                    let sum = s.bin(BinOp::Add, args[0], args[1], ty);
                    let c = s.op(Op::ICmp { pred: ICmpPred::Ult, samesign: false, lhs: sum, rhs: args[0] }, i1);
                    Some(s.op(Op::Select { fmf: FastMath::default(), cond: c, then_value: ones, else_value: sum }, ty))
                }
                // Signed saturation: on overflow, the most negative value if
                // a is negative, else the most positive (a's sign bit
                // spread, xor the most positive). Addition overflows when
                // the result's sign differs from both operands'; subtraction
                // when the operands' signs differ and the result's differs
                // from a's.
                (_, "llvm.sadd" | "llvm.ssub")
                    if scalar
                        && bits <= 64
                        && (name.starts_with("llvm.sadd.sat") || name.starts_with("llvm.ssub.sat")) =>
                {
                    let add = base == "llvm.sadd";
                    let (a, b) = (args[0], args[1]);
                    let r = s.bin(if add { BinOp::Add } else { BinOp::Sub }, a, b, ty);
                    let ar = s.bin(BinOp::Xor, a, r, ty);
                    let other = if add { s.bin(BinOp::Xor, b, r, ty) } else { s.bin(BinOp::Xor, a, b, ty) };
                    let both = s.bin(BinOp::And, ar, other, ty);
                    let zero = cx.int(ty, 0);
                    let over = s.op(Op::ICmp { pred: ICmpPred::Slt, samesign: false, lhs: both, rhs: zero }, i1);
                    let top = cx.int(ty, bits as i64 - 1);
                    let sign = s.bin(BinOp::AShr, a, top, ty);
                    let max = cx.int(ty, if bits >= 64 { i64::MAX } else { (1i64 << (bits - 1)) - 1 });
                    let sat = s.bin(BinOp::Xor, sign, max, ty);
                    Some(s.op(Op::Select { fmf: FastMath::default(), cond: over, then_value: sat, else_value: r }, ty))
                }
                // Vector abs keeps its call, for the abs instruction; its
                // flag (poison for the most negative value) may be dropped.
                (_, "llvm.abs")
                    if cx.value_ty(s.f, args[0]) != ty || matches!(cx.m.types.get(ty), Type::Vector { .. }) =>
                {
                    let no = cx.int(i1, 0);
                    if let Op::Call(c) = &mut s.f.insts[i.index()].op {
                        c.args[1].value = no;
                    }
                    None
                }
                (_, "llvm.abs") => {
                    let zero = cx.int(ty, 0);
                    let neg = s.bin(BinOp::Sub, zero, args[0], ty);
                    let c = s.op(Op::ICmp { pred: ICmpPred::Slt, samesign: false, lhs: args[0], rhs: zero }, i1);
                    Some(
                        s.op(
                            Op::Select { fmf: FastMath::default(), cond: c, then_value: neg, else_value: args[0] },
                            ty,
                        ),
                    )
                }
                _ => None,
            };
            let new = std::mem::take(&mut s.new);
            match value {
                Some(v) => {
                    f.replace_uses(Value::Local(r), v);
                    let n = new.len();
                    f.blocks[b.index()].insts.splice(k..=k, new);
                    k += n;
                }
                None => k += 1,
            }
        }
    }
}

/// `base` (`llvm.ctpop`, `llvm.ctlz`, `llvm.cttz` or `llvm.bswap`) of `x`,
/// an integer of `bits` bits, of type `ty`, where the description has no
/// instruction for it: by the same at a wider width it has one for, or
/// with shifts and masks. Zero gives the full width.
/// A call of intrinsic `name`, declared if new, returning `ret`.
pub(crate) fn call_intrinsic(cx: &mut Ctx, s: &mut Seq, name: &str, args: Vec<Value>, ret: TypeId) -> Value {
    let params: Vec<TypeId> = args.iter().map(|&a| cx.value_ty(s.f, a)).collect();
    let callee = crate::legalize::declare(cx, name, ret, &params);
    let fn_ty = cx.m.types.intern(Type::Function { ret, params, varargs: false });
    s.op(
        Op::Call(Box::new(Call {
            tail: TailKind::None,
            fmf: FastMath::default(),
            cconv: CallConv::default(),
            ret_attrs: vec![],
            addrspace: None,
            fn_ty,
            callee,
            args: args.into_iter().map(|value| CallArg { value, attrs: vec![] }).collect(),
            fn_attrs: vec![],
            bundles: vec![],
        })),
        ret,
    )
}

fn bit_intrinsic(cx: &mut Ctx, s: &mut Seq, base: &str, x: Value, bits: u32, ty: TypeId) -> Value {
    let i1 = cx.m.types.int(1);
    let wide = [16, 32, 64].into_iter().find(|&w| w > bits && cx.selects_intrinsic(&format!("{base}.i{w}")));
    let w = wide.unwrap_or(if bits <= 32 { 32 } else { 64 });
    let wt = cx.m.types.int(w);
    let c = |cx: &mut Ctx, v: i64| cx.int(wt, v);
    let mut x = if bits < w { s.cast(CastOp::ZExt, x, wt) } else { x };
    let narrow = |s: &mut Seq, v: Value| if bits < w { s.cast(CastOp::Trunc, v, ty) } else { v };
    // A zero input counts as having its lowest bit just above the value.
    if base == "llvm.cttz" && bits < w {
        let top = c(cx, 1i64 << bits);
        x = s.bin(BinOp::Or, x, top, wt);
    }
    // Trailing zeros as leading zeros of the bits reversed (rbit, clz),
    // when the description has both at this width.
    if base == "llvm.cttz"
        && cx.selects_intrinsic(&format!("llvm.bitreverse.i{w}"))
        && cx.selects_intrinsic(&format!("llvm.ctlz.i{w}"))
    {
        let rev = call_intrinsic(cx, s, &format!("llvm.bitreverse.i{w}"), vec![x], wt);
        let no = cx.int(i1, 0);
        let v = call_intrinsic(cx, s, &format!("llvm.ctlz.i{w}"), vec![rev, no], wt);
        return narrow(s, v);
    }
    if wide.is_some() {
        let name = format!("{base}.i{w}");
        let no = cx.int(i1, 0);
        let args = if base == "llvm.ctlz" || base == "llvm.cttz" { vec![x, no] } else { vec![x] };
        let params: Vec<TypeId> = args.iter().map(|a| if *a == no { i1 } else { wt }).collect();
        let callee = crate::legalize::declare(cx, &name, wt, &params);
        let fn_ty = cx.m.types.intern(Type::Function { ret: wt, params, varargs: false });
        let mut v = s.op(
            Op::Call(Box::new(Call {
                tail: TailKind::None,
                fmf: FastMath::default(),
                cconv: CallConv::default(),
                ret_attrs: vec![],
                addrspace: None,
                fn_ty,
                callee,
                args: args.into_iter().map(|value| CallArg { value, attrs: vec![] }).collect(),
                fn_attrs: vec![],
                bundles: vec![],
            })),
            wt,
        );
        if base == "llvm.ctlz" && bits < w {
            let d = c(cx, (w - bits) as i64);
            v = s.bin(BinOp::Sub, v, d, wt);
        }
        if base == "llvm.bswap" && bits < w {
            let d = c(cx, (w - bits) as i64);
            v = s.bin(BinOp::LShr, v, d, wt);
        }
        return narrow(s, v);
    }
    let rep =
        |pattern: u64, every: u32| -> i64 { (0..w / every).fold(0u64, |acc, k| acc | (pattern << (every * k))) as i64 };
    let v = match base {
        "llvm.bswap" => {
            // Swap bytes, then pairs of them, then halves.
            let mut step = 8;
            while step < w {
                let m = c(cx, rep((1u64 << step) - 1, 2 * step));
                let sh = c(cx, step as i64);
                let lo = s.bin(BinOp::And, x, m, wt);
                let lo = s.bin(BinOp::Shl, lo, sh, wt);
                let hi = s.bin(BinOp::LShr, x, sh, wt);
                let hi = s.bin(BinOp::And, hi, m, wt);
                x = s.bin(BinOp::Or, hi, lo, wt);
                step *= 2;
            }
            if bits < w {
                let d = c(cx, (w - bits) as i64);
                x = s.bin(BinOp::LShr, x, d, wt);
            }
            x
        }
        "llvm.ctlz" => {
            // Every bit below the highest set, counted, from the width.
            let mut step = 1;
            while step < w {
                let sh = c(cx, step as i64);
                let y = s.bin(BinOp::LShr, x, sh, wt);
                x = s.bin(BinOp::Or, x, y, wt);
                step *= 2;
            }
            let n = popcount(cx, s, x, w);
            let full = c(cx, bits as i64);
            s.bin(BinOp::Sub, full, n, wt)
        }
        "llvm.cttz" => {
            // The bits below the lowest set: !x & (x - 1).
            let one = c(cx, 1);
            let all = c(cx, -1);
            let below = s.bin(BinOp::Sub, x, one, wt);
            let not = s.bin(BinOp::Xor, x, all, wt);
            let y = s.bin(BinOp::And, not, below, wt);
            popcount(cx, s, y, w)
        }
        _ => popcount(cx, s, x, w),
    };
    narrow(s, v)
}

/// The number of bits set in `x`, an integer of `w` (32 or 64) bits: sums
/// of bits in pairs, nibbles and bytes, then the bytes added up, with a
/// multiply if the machine has one.
fn popcount(cx: &mut Ctx, s: &mut Seq, x: Value, w: u32) -> Value {
    let wt = cx.m.types.int(w);
    let rep = |byte: u64| -> i64 { (0..w / 8).fold(0u64, |acc, k| acc | (byte << (8 * k))) as i64 };
    let c = |cx: &mut Ctx, v: i64| cx.int(wt, v);
    let one = c(cx, 1);
    let half = s.bin(BinOp::LShr, x, one, wt);
    let m1 = c(cx, rep(0x55));
    let half = s.bin(BinOp::And, half, m1, wt);
    let mut x = s.bin(BinOp::Sub, x, half, wt);
    let m2 = c(cx, rep(0x33));
    let lo = s.bin(BinOp::And, x, m2, wt);
    let two = c(cx, 2);
    let hi = s.bin(BinOp::LShr, x, two, wt);
    let hi = s.bin(BinOp::And, hi, m2, wt);
    x = s.bin(BinOp::Add, lo, hi, wt);
    let four = c(cx, 4);
    let sh = s.bin(BinOp::LShr, x, four, wt);
    x = s.bin(BinOp::Add, x, sh, wt);
    let m4 = c(cx, rep(0x0f));
    x = s.bin(BinOp::And, x, m4, wt);
    if cx.selects(|h| *h == Head::Bin(BinOp::Mul, w)) {
        let ones = c(cx, rep(0x01));
        x = s.bin(BinOp::Mul, x, ones, wt);
        let top = c(cx, w as i64 - 8);
        return s.bin(BinOp::LShr, x, top, wt);
    }
    let mut step = 8;
    while step < w {
        let sh = c(cx, step as i64);
        let y = s.bin(BinOp::LShr, x, sh, wt);
        x = s.bin(BinOp::Add, x, y, wt);
        step *= 2;
    }
    let m = c(cx, 0x7f);
    s.bin(BinOp::And, x, m, wt)
}

/// `p + off` as a pointer: `p` itself for 0.
fn offset_ptr(cx: &mut Ctx, s: &mut Seq, p: Value, off: u64, i8t: TypeId, i64t: TypeId, ptr: TypeId) -> Value {
    if off == 0 {
        p
    } else {
        let o = cx.int(i64t, off as i64);
        s.op(gep8(i8t, p, o), ptr)
    }
}

/// Bit casts between a vector of booleans and an integer of as many bits
/// (`bitcast <16 x i1> %m to i16`, a vector comparison's lanes as a mask),
/// lane by lane: the lanes extended to bytes, each extracted, extended and
/// shifted to its bit, and
/// the bits or'ed; or the other way, each bit shifted down, truncated and
/// inserted. Lane k is bit k. Run after `legalize::fix_masks`, which
/// makes the common `icmp eq (bitcast mask), 0` a reduction; casts left
/// unused by that are skipped.
pub(crate) fn bool_vector_casts(cx: &mut Ctx, f: &mut Function) {
    let i1 = cx.m.types.int(1);
    let i64t = cx.m.types.int(64);
    let mut used = std::collections::HashSet::new();
    for &b in &f.layout {
        for &i in &f.blocks[b.index()].insts {
            f.insts[i.index()].op.for_each_value(|v| {
                if let Value::Local(l) = v {
                    used.insert(*l);
                }
            });
        }
    }
    for b in f.layout.clone() {
        let mut k = 0;
        while k < f.blocks[b.index()].insts.len() {
            let i = f.blocks[b.index()].insts[k];
            let (Op::Cast { op: CastOp::BitCast, value, .. }, Some(r)) =
                (&f.insts[i.index()].op, f.insts[i.index()].result)
            else {
                k += 1;
                continue;
            };
            let value = *value;
            if !used.contains(&r) {
                k += 1;
                continue;
            }
            let (from, to) = (cx.value_ty(f, value), f.locals[r.index()].ty);
            let lanes_of = |cx: &Ctx, t: TypeId| match cx.m.types.get(t) {
                Type::Vector { len, elem, scalable: false } if *elem == i1 => Some(*len as u32),
                _ => None,
            };
            let bits_of = |cx: &Ctx, t: TypeId| match cx.m.types.get(t) {
                Type::Int(w) if *w <= 64 => Some(*w),
                _ => None,
            };
            let mut s = Seq { f, new: Vec::new() };
            let out = match (lanes_of(cx, from), bits_of(cx, to), bits_of(cx, from), lanes_of(cx, to)) {
                (Some(n), Some(w), _, _) if n == w => {
                    // The lanes as bytes of 0 or 1 first: masks have
                    // instructions for that, and bytes can be extracted.
                    let i8t = cx.m.types.int(8);
                    let bytes_ty = cx.m.types.intern(Type::Vector { scalable: false, len: n, elem: i8t });
                    let bytes = s.cast(CastOp::ZExt, value, bytes_ty);
                    let mut acc = cx.int(to, 0);
                    for lane in 0..n {
                        let idx = cx.int(i64t, lane as i64);
                        let e = s.op(Op::ExtractElement { vector: bytes, index: idx }, i8t);
                        let z = s.cast(CastOp::ZExt, e, to);
                        let sh = cx.int(to, lane as i64);
                        let bit = if lane == 0 { z } else { s.bin(BinOp::Shl, z, sh, to) };
                        acc = if lane == 0 { bit } else { s.bin(BinOp::Or, acc, bit, to) };
                    }
                    acc
                }
                (_, _, Some(w), Some(n)) if n == w => {
                    // Bytes of 0 or 1, then compared with zero.
                    let i8t = cx.m.types.int(8);
                    let bytes_ty = cx.m.types.intern(Type::Vector { scalable: false, len: n, elem: i8t });
                    let one = cx.int(from, 1);
                    let mut acc = Value::Const(cx.m.consts.intern(Constant { ty: bytes_ty, kind: ConstKind::Poison }));
                    for lane in 0..n {
                        let sh = cx.int(from, lane as i64);
                        let down = if lane == 0 { value } else { s.bin(BinOp::LShr, value, sh, from) };
                        let bit = s.bin(BinOp::And, down, one, from);
                        let byte = s.cast(CastOp::Trunc, bit, i8t);
                        let idx = cx.int(i64t, lane as i64);
                        acc = s.op(Op::InsertElement { vector: acc, element: byte, index: idx }, bytes_ty);
                    }
                    let zero = Value::Const(cx.m.consts.intern(Constant { ty: bytes_ty, kind: ConstKind::Zero }));
                    s.op(Op::ICmp { pred: ICmpPred::Ne, samesign: false, lhs: acc, rhs: zero }, to)
                }
                _ => {
                    k += 1;
                    continue;
                }
            };
            let new = std::mem::take(&mut s.new);
            f.replace_uses(Value::Local(r), out);
            let n = new.len();
            f.blocks[b.index()].insts.splice(k..=k, new);
            k += n;
        }
    }
}

/// Constant lane indices as `i64`, whatever type they were written with
/// (rustc writes `i32 0`): the description's patterns name them so, and a
/// lane's number does not depend on its type.
fn lane_indices(cx: &mut Ctx, f: &mut Function) {
    let i64t = cx.m.types.int(64);
    for b in f.layout.clone() {
        for k in 0..f.blocks[b.index()].insts.len() {
            let i = f.blocks[b.index()].insts[k];
            let index = match &f.insts[i.index()].op {
                Op::ExtractElement { index, .. } | Op::InsertElement { index, .. } => *index,
                _ => continue,
            };
            if cx.value_ty(f, index) == i64t {
                continue;
            }
            let Some(v) = cx.const_int(index) else { continue };
            let new = cx.int(i64t, v);
            match &mut f.insts[i.index()].op {
                Op::ExtractElement { index, .. } | Op::InsertElement { index, .. } => *index = new,
                _ => {}
            }
        }
    }
}

/// Builds instructions to go before another, of one integer type.
pub(crate) struct Seq<'f> {
    pub f: &'f mut Function,
    pub new: Vec<InstId>,
}

impl Seq<'_> {
    pub fn op(&mut self, op: Op, ty: TypeId) -> Value {
        let i = self.f.add_inst(op, Some((None, ty)));
        self.new.push(i);
        self.f.result(i)
    }

    pub fn op_void(&mut self, op: Op) {
        let i = self.f.add_inst(op, None);
        self.new.push(i);
    }

    pub fn bin(&mut self, op: BinOp, lhs: Value, rhs: Value, ty: TypeId) -> Value {
        self.op(Op::Binary { op, flags: IntFlags::NONE, fmf: FastMath::default(), lhs, rhs }, ty)
    }

    pub fn cast(&mut self, op: CastOp, value: Value, ty: TypeId) -> Value {
        self.op(Op::Cast { op, flags: IntFlags::NONE, fmf: FastMath::default(), value }, ty)
    }
}

/// The high half of `x * m` at `w` bits, then shifted right by `extra`:
/// the product of the operands extended to `2w` bits.
fn mul_high(cx: &mut Ctx, s: &mut Seq, x: Value, m: i64, w: u32, signed: bool, extra: u32) -> Value {
    let ty = cx.m.types.int(w);
    let wide = cx.m.types.int(2 * w);
    let ext = if signed { CastOp::SExt } else { CastOp::ZExt };
    let mc = cx.int(ty, m);
    let a = s.cast(ext, x, wide);
    let b = s.cast(ext, mc, wide);
    let p = s.bin(BinOp::Mul, a, b, wide);
    // At 32 bits, any further shift joins this one; at 64, smulh and
    // umulh take the high half as it is.
    let (shift, rest) = if w == 32 { (32 + extra, 0) } else { (64, extra) };
    let sh = cx.int(wide, shift as i64);
    let op = if signed && w == 32 { BinOp::AShr } else { BinOp::LShr };
    let h = s.bin(op, p, sh, wide);
    let hi = s.cast(CastOp::Trunc, h, ty);
    if rest > 0 {
        let k = cx.int(ty, rest as i64);
        return s.bin(if signed { BinOp::AShr } else { BinOp::LShr }, hi, k, ty);
    }
    hi
}

fn lower_const_divs(cx: &mut Ctx, f: &mut Function) {
    let blocks: Vec<BlockId> = f.layout.clone();
    for b in blocks {
        let mut k = 0;
        while k < f.blocks[b.index()].insts.len() {
            let i = f.blocks[b.index()].insts[k];
            let Op::Binary { op, lhs: x, rhs, .. } = f.insts[i.index()].op else {
                k += 1;
                continue;
            };
            let signed = matches!(op, BinOp::SDiv | BinOp::SRem);
            let rem = matches!(op, BinOp::SRem | BinOp::URem);
            let (Some(d), Type::Int(w)) = (cx.const_int(rhs), cx.m.types.get(cx.value_ty(f, x)).clone()) else {
                k += 1;
                continue;
            };
            if !matches!(op, BinOp::SDiv | BinOp::SRem | BinOp::UDiv | BinOp::URem) || !(w == 32 || w == 64) || d == 0 {
                k += 1;
                continue;
            }
            // Elective (autochop): the division instruction does it too.
            if !epitome_ir::chop::allow(|| {
                format!("divide by {d} with a multiply at {}", epitome_ir::printer::inst_name(f, i))
            }) {
                k += 1;
                continue;
            }
            let ty = cx.m.types.int(w);
            let mask: u64 = if w == 64 { u64::MAX } else { (1u64 << w) - 1 };
            let mut s = Seq { f, new: Vec::new() };
            let zero = cx.int(ty, 0);
            let c = |cx: &mut Ctx, v: i64| cx.int(ty, v);
            let result = if signed {
                let ad = d.unsigned_abs() & mask;
                if d == 1 || d == -1 {
                    let q = if d == 1 { x } else { s.bin(BinOp::Sub, zero, x, ty) };
                    if rem { zero } else { q }
                } else if ad.is_power_of_two() {
                    // Round towards zero: add 2^k - 1 to negative values.
                    let kk = ad.trailing_zeros() as i64;
                    let sign = s.bin(BinOp::AShr, x, c(cx, w as i64 - 1), ty);
                    let bias = s.bin(BinOp::LShr, sign, c(cx, w as i64 - kk), ty);
                    let t = s.bin(BinOp::Add, x, bias, ty);
                    if rem {
                        let low = s.bin(BinOp::And, t, c(cx, -(ad as i64)), ty);
                        s.bin(BinOp::Sub, x, low, ty)
                    } else {
                        let q = s.bin(BinOp::AShr, t, c(cx, kk), ty);
                        if d < 0 { s.bin(BinOp::Sub, zero, q, ty) } else { q }
                    }
                } else {
                    let (m, sh) = crate::divconst::magic_signed(d, w);
                    let needs_fix = (d > 0 && m < 0) || (d < 0 && m > 0);
                    let mut q = mul_high(cx, &mut s, x, m, w, true, if needs_fix { 0 } else { sh });
                    if needs_fix {
                        q = s.bin(if d > 0 { BinOp::Add } else { BinOp::Sub }, q, x, ty);
                        if sh > 0 {
                            q = s.bin(BinOp::AShr, q, c(cx, sh as i64), ty);
                        }
                    }
                    let sign = s.bin(BinOp::LShr, q, c(cx, w as i64 - 1), ty);
                    let q = s.bin(BinOp::Add, q, sign, ty);
                    if rem {
                        let p = s.bin(BinOp::Mul, q, c(cx, d), ty);
                        s.bin(BinOp::Sub, x, p, ty)
                    } else {
                        q
                    }
                }
            } else {
                let du = (d as u64) & mask;
                if du == 1 {
                    if rem { zero } else { x }
                } else if du.is_power_of_two() {
                    if rem {
                        s.bin(BinOp::And, x, c(cx, (du - 1) as i64), ty)
                    } else {
                        s.bin(BinOp::LShr, x, c(cx, du.trailing_zeros() as i64), ty)
                    }
                } else {
                    let q = if du > mask / 2 {
                        // Only 0 or 1 fits.
                        let i1 = cx.m.types.int(1);
                        let ge = s.op(Op::ICmp { pred: ICmpPred::Uge, samesign: false, lhs: x, rhs: c(cx, d) }, i1);
                        s.cast(CastOp::ZExt, ge, ty)
                    } else {
                        let (m, add, sh) = crate::divconst::magic_unsigned(du, w);
                        if add {
                            let t = mul_high(cx, &mut s, x, m as i64, w, false, 0);
                            let diff = s.bin(BinOp::Sub, x, t, ty);
                            let half = s.bin(BinOp::LShr, diff, c(cx, 1), ty);
                            let sum = s.bin(BinOp::Add, half, t, ty);
                            s.bin(BinOp::LShr, sum, c(cx, sh as i64 - 1), ty)
                        } else {
                            mul_high(cx, &mut s, x, m as i64, w, false, sh)
                        }
                    };
                    if rem {
                        let p = s.bin(BinOp::Mul, q, c(cx, d), ty);
                        s.bin(BinOp::Sub, x, p, ty)
                    } else {
                        q
                    }
                }
            };
            let new = std::mem::take(&mut s.new);
            let res = f.insts[i.index()].result.unwrap();
            f.replace_uses(Value::Local(res), result);
            let n = new.len();
            f.blocks[b.index()].insts.splice(k..=k, new);
            k += n;
        }
    }
}

fn legalize_fp(cx: &mut Ctx, f: &mut Function) -> Result<(), String> {
    let i32t = cx.m.types.int(32);
    let i1 = cx.m.types.int(1);
    let blocks: Vec<BlockId> = f.layout.clone();
    for b in blocks {
        let mut k = 0;
        while k < f.blocks[b.index()].insts.len() {
            let i = f.blocks[b.index()].insts[k];
            let res = f.insts[i.index()].result;
            let mut s = Seq { f, new: Vec::new() };
            // Scalars only: vectors have their own conversions.
            let bits_of = |cx: &Ctx, ty: TypeId| match cx.m.types.get(ty) {
                Type::Int(b) => *b,
                _ => 64,
            };
            let mut replace: Option<Value> = None;
            match s.f.insts[i.index()].op.clone() {
                Op::Cast { op: op @ (CastOp::SIToFP | CastOp::UIToFP), value, .. } => {
                    let from = bits_of(cx, cx.value_ty(s.f, value));
                    if from < 32 {
                        let ext = if op == CastOp::SIToFP { CastOp::SExt } else { CastOp::ZExt };
                        let w = s.cast(ext, value, i32t);
                        if let Op::Cast { value, .. } = &mut s.f.insts[i.index()].op {
                            *value = w;
                        }
                    }
                }
                Op::Cast { op: op @ (CastOp::FPToSI | CastOp::FPToUI), value, .. } => {
                    let r = res.unwrap();
                    let to_ty = s.f.locals[r.index()].ty;
                    if bits_of(cx, to_ty) < 32 {
                        // Convert to 32 bits, then take the low bits.
                        let w = s.op(Op::Cast { op, flags: IntFlags::NONE, fmf: FastMath::default(), value }, i32t);
                        replace = Some(s.cast(CastOp::Trunc, w, to_ty));
                    }
                }
                Op::FCmp {
                    pred: pred @ (FCmpPred::One | FCmpPred::Ueq | FCmpPred::True | FCmpPred::False),
                    lhs,
                    rhs,
                    fmf,
                } => {
                    replace = Some(match pred {
                        FCmpPred::True => cx.int(i1, 1),
                        FCmpPred::False => cx.int(i1, 0),
                        _ => {
                            // one: ordered and not equal; ueq: unordered or equal.
                            let (a, b, op) = if pred == FCmpPred::One {
                                (FCmpPred::Ord, FCmpPred::Une, BinOp::And)
                            } else {
                                (FCmpPred::Uno, FCmpPred::Oeq, BinOp::Or)
                            };
                            let x = s.op(Op::FCmp { pred: a, fmf, lhs, rhs }, i1);
                            let y = s.op(Op::FCmp { pred: b, fmf, lhs, rhs }, i1);
                            s.bin(op, x, y, i1)
                        }
                    });
                }
                Op::Store { value: Value::Const(c), ptr, volatile, atomic, align } => {
                    let k = cx.m.constant(c);
                    if let ConstKind::Float(raw) = k.kind {
                        let bits = match cx.m.types.get(k.ty) {
                            Type::Double => 64,
                            Type::Float => 32,
                            _ => 0,
                        };
                        if bits > 0 {
                            let ity = cx.m.types.int(bits);
                            let v = cx.int(ity, crate::target::sext(raw as u64, bits));
                            s.f.insts[i.index()].op = Op::Store { value: v, ptr, volatile, atomic, align };
                        }
                    }
                }
                // The C library's remainder, which is frem's.
                Op::Binary { op: BinOp::FRem, lhs, rhs, .. } => {
                    let ty = s.f.locals[res.unwrap().index()].ty;
                    let name = libm_name(cx, "fmod", ty).ok_or("frem of this type is not supported")?;
                    replace = Some(lanewise_call(cx, &mut s, &name, vec![lhs, rhs], ty));
                }
                _ => {}
            }
            let new = std::mem::take(&mut s.new);
            let n = new.len();
            match replace {
                Some(v) => {
                    f.replace_uses(Value::Local(res.unwrap()), v);
                    f.blocks[b.index()].insts.splice(k..=k, new);
                    k += n;
                }
                None => {
                    f.blocks[b.index()].insts.splice(k..k, new);
                    k += n + 1;
                }
            }
        }
    }
    Ok(())
}

fn widen_narrow(cx: &mut Ctx, f: &mut Function) {
    let i32t = cx.m.types.int(32);
    let blocks: Vec<BlockId> = f.layout.clone();
    for b in blocks {
        let mut k = 0;
        while k < f.blocks[b.index()].insts.len() {
            let i = f.blocks[b.index()].insts[k];
            let (signed, lhs, rhs) = match f.insts[i.index()].op {
                Op::ICmp { pred, lhs, rhs, .. } => {
                    (matches!(pred, ICmpPred::Sgt | ICmpPred::Sge | ICmpPred::Slt | ICmpPred::Sle), lhs, rhs)
                }
                Op::Binary { op: BinOp::SDiv | BinOp::SRem | BinOp::AShr, lhs, rhs, .. } => (true, lhs, rhs),
                Op::Binary { op: BinOp::UDiv | BinOp::URem | BinOp::LShr, lhs, rhs, .. } => (false, lhs, rhs),
                _ => {
                    k += 1;
                    continue;
                }
            };
            let bits = match cx.m.types.get(cx.value_ty(f, lhs)) {
                Type::Int(b) if *b < 32 => *b,
                _ => {
                    k += 1;
                    continue;
                }
            };
            let mut new = Vec::new();
            let mut widen = |cx: &mut Ctx, f: &mut Function, v: Value| -> Value {
                if let Some(c) = cx.const_int(v) {
                    let raw = c as u64 & ((1u64 << bits) - 1);
                    return cx.int(i32t, if signed { sext(raw, bits) } else { raw as i64 });
                }
                let op = if signed { CastOp::SExt } else { CastOp::ZExt };
                let c = f.add_inst(
                    Op::Cast { op, flags: IntFlags::NONE, fmf: FastMath::default(), value: v },
                    Some((None, i32t)),
                );
                new.push(c);
                f.result(c)
            };
            let (l, r) = (widen(cx, f, lhs), widen(cx, f, rhs));
            let narrow_result = !matches!(f.insts[i.index()].op, Op::ICmp { .. });
            match &mut f.insts[i.index()].op {
                Op::ICmp { lhs, rhs, .. } | Op::Binary { lhs, rhs, .. } => {
                    *lhs = l;
                    *rhs = r;
                }
                _ => unreachable!(),
            }
            let n = new.len();
            f.blocks[b.index()].insts.splice(k..k, new);
            k += n;
            if narrow_result {
                // The operation is now 32 bits wide; its users still see
                // the narrow type through a truncation.
                let res = f.insts[i.index()].result.unwrap();
                let narrow_ty = f.locals[res.index()].ty;
                f.locals[res.index()].ty = i32t;
                let t = f.add_inst(
                    Op::Cast {
                        op: CastOp::Trunc,
                        flags: IntFlags::NONE,
                        fmf: FastMath::default(),
                        value: Value::Local(res),
                    },
                    Some((None, narrow_ty)),
                );
                let tv = f.result(t);
                f.replace_uses(Value::Local(res), tv);
                // Undo the replacement in the truncation itself.
                f.insts[t.index()].op = Op::Cast {
                    op: CastOp::Trunc,
                    flags: IntFlags::NONE,
                    fmf: FastMath::default(),
                    value: Value::Local(res),
                };
                f.blocks[b.index()].insts.insert(k + 1, t);
                k += 1;
            }
            k += 1;
        }
    }
}

fn gep8(i8t: TypeId, ptr: Value, off: Value) -> Op {
    Op::Gep { flags: GepFlags::default(), inrange: None, source_ty: i8t, ptr, indices: vec![off] }
}

pub fn struct_fields(cx: &Ctx, ty: TypeId) -> Result<(Vec<TypeId>, bool), String> {
    match cx.m.types.get(ty) {
        Type::Struct { packed, fields } => Ok((fields.clone(), *packed)),
        Type::Named(n) => {
            let body = cx.m.types.structs[*n as usize].body.as_ref().ok_or("an opaque struct")?;
            Ok((body.fields.clone(), body.packed))
        }
        _ => Err("not a struct".into()),
    }
}

/// For machines whose branches compare whole registers: a branch on a
/// boolean that is not an integer comparison in the same block (whose
/// branch can compare its operands) becomes a branch on the boolean,
/// zero-extended, compared with zero. A boolean's bits above the lowest are
/// undefined, so the extension is needed.
fn compare_boolean_branches(cx: &mut Ctx, f: &mut Function) {
    let i64t = cx.m.types.int(64);
    let i1 = cx.m.types.int(1);
    let zero = cx.int(i64t, 0);
    for b in f.layout.clone() {
        let Some(t) = f.terminator(b) else { continue };
        let Op::CondBr { cond: Value::Local(c), then_dest, else_dest } = f.insts[t.index()].op.clone() else {
            continue;
        };
        let compared_here = match f.locals[c.index()].def {
            LocalDef::Inst(d) if matches!(f.insts[d.index()].op, Op::ICmp { .. }) => {
                f.blocks[b.index()].insts.contains(&d).then_some(d)
            }
            _ => None,
        };
        if let Some(d) = compared_here {
            // Used elsewhere too, the comparison is a value selection
            // does not take into the branch: the branch gets its own.
            let mut uses = 0;
            for i in f.insts_in_order() {
                f.insts[i.index()].op.for_each_value(|v| uses += usize::from(*v == Value::Local(c)));
            }
            if uses > 1 {
                let again = f.add_inst(f.insts[d.index()].op.clone(), Some((None, i1)));
                let at = f.blocks[b.index()].insts.len() - 1;
                f.blocks[b.index()].insts.insert(at, again);
                f.insts[t.index()].op = Op::CondBr { cond: f.result(again), then_dest, else_dest };
            }
            continue;
        }
        let z = f.add_inst(
            Op::Cast { op: CastOp::ZExt, flags: IntFlags::NONE, fmf: FastMath::default(), value: Value::Local(c) },
            Some((None, i64t)),
        );
        let cmp =
            f.add_inst(Op::ICmp { pred: ICmpPred::Ne, samesign: false, lhs: f.result(z), rhs: zero }, Some((None, i1)));
        let at = f.blocks[b.index()].insts.len() - 1;
        f.blocks[b.index()].insts.splice(at..at, [z, cmp]);
        f.insts[t.index()].op = Op::CondBr { cond: f.result(cmp), then_dest, else_dest };
    }
}

/// Splits each edge from a block with several successors into a block
/// with phis.
fn split_phi_edges(f: &mut Function) {
    let blocks: Vec<BlockId> = f.layout.clone();
    for p in blocks {
        let Some(t) = f.terminator(p) else { continue };
        let succs = f.insts[t.index()].op.successors();
        if succs.len() < 2 {
            continue;
        }
        let has_phis = |f: &Function, s: BlockId| {
            f.blocks[s.index()].insts.first().is_some_and(|&i| f.insts[i.index()].op.is_phi())
        };
        let mut edge = 0;
        let mut new_targets: Vec<BlockId> = Vec::new();
        // An invoke's landing pad is reached only by unwinding: that edge
        // is never split (its phis' copies go before the call).
        let unwind = match &f.insts[t.index()].op {
            Op::Invoke { unwind, .. } => Some(*unwind),
            _ => None,
        };
        for s in succs {
            if !has_phis(f, s) || Some(s) == unwind {
                new_targets.push(s);
                continue;
            }
            let e = f.add_block(None);
            let at = f.layout.iter().position(|&x| x == p).unwrap() + 1 + edge;
            edge += 1;
            f.layout.insert(at, e);
            f.push_inst(e, Op::Br(s), None);
            // One of `p`'s entries in the phis moves to `e`.
            let phis: Vec<InstId> =
                f.blocks[s.index()].insts.iter().copied().take_while(|&i| f.insts[i.index()].op.is_phi()).collect();
            for phi in phis {
                if let Op::Phi { incoming, .. } = &mut f.insts[phi.index()].op
                    && let Some(entry) = incoming.iter_mut().find(|(_, from)| *from == p)
                {
                    entry.1 = e;
                }
            }
            new_targets.push(e);
        }
        let mut it = new_targets.into_iter();
        f.insts[t.index()].op.for_each_successor_mut(|s| *s = it.next().unwrap());
    }
}

/// A global and a byte offset, for a constant address.
pub fn const_address(cx: &Ctx, c: ConstId) -> Option<(GlobalId, i64)> {
    let k = cx.m.constant(c);
    match &k.kind {
        ConstKind::Global(g) => Some((*g, 0)),
        ConstKind::Expr(e) => match e {
            ConstExpr::Cast { value, .. } => const_address(cx, *value),
            // `getelementptr (i8, ptr null, i64 ptrtoint (ptr @g))`: @g's
            // address, as an offset from null.
            ConstExpr::Gep { ptr: base, indices, source_ty, .. }
                if matches!(cx.m.constant(*base).kind, ConstKind::Null | ConstKind::Zero)
                    && indices.len() == 1
                    && cx.size_of(*source_ty).ok() == Some(1) =>
            {
                match &cx.m.constant(indices[0]).kind {
                    ConstKind::Expr(ConstExpr::Cast { op: CastOp::PtrToInt, value, .. }) => const_address(cx, *value),
                    _ => None,
                }
            }
            ConstExpr::Gep { ptr: base, indices, source_ty, .. } => {
                let (g, mut off) = const_address(cx, *base)?;
                let mut ty = *source_ty;
                for (n, &idx) in indices.iter().enumerate() {
                    let i = {
                        let ik = cx.m.constant(idx);
                        match (&ik.kind, cx.m.types.get(ik.ty)) {
                            (ConstKind::Int(a), Type::Int(b)) => sext(a.low_u64(), *b),
                            (ConstKind::Zero | ConstKind::Null, _) => 0,
                            _ => return None,
                        }
                    };
                    if n == 0 {
                        off += i * cx.size_of(ty).ok()? as i64;
                        continue;
                    }
                    match cx.m.types.get(ty).clone() {
                        Type::Struct { .. } | Type::Named(_) => {
                            let (fields, packed) = struct_fields(cx, ty).ok()?;
                            let layout = cx.dl.struct_layout(&cx.m.types, &fields, packed)?;
                            off += layout.offsets[i as usize] as i64;
                            ty = fields[i as usize];
                        }
                        Type::Array { elem, .. } | Type::Vector { elem, .. } => {
                            off += i * cx.size_of(elem).ok()? as i64;
                            ty = elem;
                        }
                        _ => return None,
                    }
                }
                Some((g, off))
            }
            _ => None,
        },
        _ => None,
    }
}
