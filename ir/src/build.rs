//! Building IR in code: constructors for the key structs, and a
//! `FunctionBuilder` that adds instructions at a block's end, working out
//! each result's type and checking its operands as it goes.
//!
//! ```
//! use epitome_ir::module::{ICmpPred, Module};
//!
//! let mut m = Module::default();
//! let i64t = m.types.int(64);
//! // define i64 @max(i64 %a, i64 %b)
//! let mut b = m.function("max", i64t, &[("a", i64t), ("b", i64t)]);
//! let (x, y) = (b.param(0), b.param(1));
//! b.block("entry");
//! let gt = b.name("gt").icmp(ICmpPred::Sgt, x, y);
//! let r = b.name("r").select(gt, x, y);
//! b.ret(r);
//! b.finish().unwrap();
//! assert!(m.to_string().contains("%r = select i1 %gt, i64 %a, i64 %b"));
//! ```
//!
//! An operand of the wrong type is a mistake in the caller, as in LLVM's
//! IRBuilder, so it panics, saying what was expected; `finish` checks that
//! every block ends in exactly one terminator and returns an error if not.

use crate::apint::ApInt;
use crate::float::{self, FloatKind};
use crate::module::*;
use crate::types::{Type, TypeId, Types};

// ---------------------------------------------------------------------------
// Types

impl Types {
    pub fn half(&mut self) -> TypeId {
        self.intern(Type::Half)
    }
    pub fn float(&mut self) -> TypeId {
        self.intern(Type::Float)
    }
    pub fn double(&mut self) -> TypeId {
        self.intern(Type::Double)
    }
    /// `<len x elem>`
    pub fn vector(&mut self, len: u32, elem: TypeId) -> TypeId {
        self.intern(Type::Vector { scalable: false, len, elem })
    }
    /// `[len x elem]`
    pub fn array(&mut self, len: u64, elem: TypeId) -> TypeId {
        self.intern(Type::Array { len, elem })
    }
    /// The literal struct `{ fields... }`.
    pub fn struct_of(&mut self, fields: &[TypeId]) -> TypeId {
        self.intern(Type::Struct { packed: false, fields: fields.to_vec() })
    }
    /// `ret (params...)`, with `...` if `varargs`.
    pub fn function(&mut self, ret: TypeId, params: &[TypeId], varargs: bool) -> TypeId {
        self.intern(Type::Function { ret, params: params.to_vec(), varargs })
    }
}

// ---------------------------------------------------------------------------
// Constants, globals, calls and instructions

impl Constant {
    /// An integer of type `ty` (`iN`), truncated to its width.
    pub fn int(types: &Types, ty: TypeId, value: i64) -> Constant {
        let Type::Int(bits) = *types.get(ty) else { panic!("Constant::int of a type that is not an integer") };
        Constant { ty, kind: ConstKind::Int(ApInt::from_i64(bits, value)) }
    }

    /// A floating-point number of type `ty` (`half`, `float`, `double`...),
    /// rounded to it.
    pub fn float(types: &Types, ty: TypeId, value: f64) -> Constant {
        let kind = FloatKind::of(types.get(ty)).expect("Constant::float of a type that is not floating point");
        let bits = float::from_f64(kind, value).expect("a floating-point value the type can hold");
        Constant { ty, kind: ConstKind::Float(bits) }
    }
}

impl Call {
    /// A plain call: no attributes, tail marker, bundles or fast-math
    /// flags, the C calling convention.
    pub fn new(fn_ty: TypeId, callee: Value, args: &[Value]) -> Call {
        Call {
            tail: TailKind::None,
            fmf: FastMath::default(),
            cconv: CallConv::default(),
            ret_attrs: vec![],
            addrspace: None,
            fn_ty,
            callee,
            args: args.iter().map(|&value| CallArg { value, attrs: vec![] }).collect(),
            fn_attrs: vec![],
            bundles: vec![],
        }
    }
}

impl Inst {
    /// An instruction with no result, attachments or debug records.
    pub fn new(op: Op) -> Inst {
        Inst { result: None, op, attachments: vec![], debug_records: vec![] }
    }
}

impl Function {
    /// A declaration of type `ty` (a function type), with a parameter of
    /// each of its parameter types.
    pub fn declaration(types: &Types, ty: TypeId) -> Function {
        let Type::Function { params, .. } = types.get(ty).clone() else {
            panic!("Function::declaration of a type that is not a function type")
        };
        let mut f = Function { ty, ..Default::default() };
        for (k, p) in params.into_iter().enumerate() {
            let local = f.add_local(None, p, LocalDef::Param(k as u32));
            f.params.push(Param { local, attrs: vec![] });
        }
        f
    }

    /// The first block of a function with none yet, placed in its layout.
    /// (`add_block` takes the label type from the first block.)
    pub fn add_entry_block(&mut self, name: Option<String>, label_ty: TypeId) -> BlockId {
        assert!(self.blocks.is_empty(), "the function already has blocks");
        let id = BlockId(0);
        let local = self.add_local(name, label_ty, LocalDef::Block(id));
        self.blocks.push(Block { local, insts: Vec::new() });
        self.layout.push(id);
        id
    }
}

impl Global {
    /// A function with external linkage.
    pub fn function(name: &str, f: Function) -> Global {
        Global {
            name: Some(name.to_string()),
            props: GlobalProps::default(),
            attachments: vec![],
            kind: GlobalKind::Function(Box::new(f)),
        }
    }

    /// A global variable of type `ty`, with external linkage.
    pub fn variable(name: &str, ty: TypeId, init: Option<ConstId>, constant: bool) -> Global {
        Global {
            name: Some(name.to_string()),
            props: GlobalProps::default(),
            attachments: vec![],
            kind: GlobalKind::Variable(GlobalVar {
                constant,
                externally_initialized: false,
                ty,
                init,
                section: None,
                comdat: None,
                align: None,
                code_model: None,
                sanitizer: vec![],
                attrs: vec![],
            }),
        }
    }
}

impl Module {
    /// Adds a global, in order, and returns its id.
    pub fn add_global(&mut self, g: Global) -> GlobalId {
        let id = GlobalId(self.globals.len() as u32);
        self.globals.push(g);
        self.global_order.push(id);
        id
    }

    /// The global named `name`, if there is one.
    pub fn find_global(&self, name: &str) -> Option<GlobalId> {
        self.global_order.iter().copied().find(|&g| self.global(g).name.as_deref() == Some(name))
    }

    /// Declares function `name` (or finds it, if the module has it).
    pub fn declare(&mut self, name: &str, ret: TypeId, params: &[TypeId], varargs: bool) -> GlobalId {
        if let Some(g) = self.find_global(name) {
            return g;
        }
        let ty = self.types.function(ret, params, varargs);
        let f = Function::declaration(&self.types, ty);
        self.add_global(Global::function(name, f))
    }

    /// A global's address, as a value (`ptr @name`).
    pub fn global_value(&mut self, g: GlobalId) -> Value {
        let ptr = self.types.ptr(0);
        Value::Const(self.consts.intern(Constant { ty: ptr, kind: ConstKind::Global(g) }))
    }

    /// An integer constant of type `ty`: `iN`, or a vector of them (a
    /// splat).
    pub fn const_int(&mut self, ty: TypeId, value: i64) -> Value {
        self.scalar_or_splat(ty, |m, elem| Constant::int(&m.types, elem, value))
    }

    /// A floating-point constant of type `ty`, or a splat of one.
    pub fn const_float(&mut self, ty: TypeId, value: f64) -> Value {
        self.scalar_or_splat(ty, |m, elem| Constant::float(&m.types, elem, value))
    }

    /// `zeroinitializer` of type `ty` (`null` for a pointer).
    pub fn const_zero(&mut self, ty: TypeId) -> Value {
        let kind = if matches!(self.types.get(ty), Type::Ptr(_)) { ConstKind::Null } else { ConstKind::Zero };
        Value::Const(self.consts.intern(Constant { ty, kind }))
    }

    pub fn poison(&mut self, ty: TypeId) -> Value {
        Value::Const(self.consts.intern(Constant { ty, kind: ConstKind::Poison }))
    }

    pub fn undef(&mut self, ty: TypeId) -> Value {
        Value::Const(self.consts.intern(Constant { ty, kind: ConstKind::Undef }))
    }

    fn scalar_or_splat(&mut self, ty: TypeId, make: impl Fn(&mut Module, TypeId) -> Constant) -> Value {
        match *self.types.get(ty) {
            Type::Vector { elem, .. } => {
                let c = make(self, elem);
                let e = self.consts.intern(c);
                Value::Const(self.consts.intern(Constant { ty, kind: ConstKind::Splat(e) }))
            }
            _ => {
                let c = make(self, ty);
                Value::Const(self.consts.intern(c))
            }
        }
    }

    /// Starts defining function `name`: `ret name(params...)`, the
    /// parameters named as given. `finish` adds it to the module, in place
    /// of a declaration of the same name if there is one.
    pub fn function(&mut self, name: &str, ret: TypeId, params: &[(&str, TypeId)]) -> FunctionBuilder<'_> {
        let tys: Vec<TypeId> = params.iter().map(|p| p.1).collect();
        let ty = self.types.function(ret, &tys, false);
        let mut f = Function { ty, has_body: true, ..Default::default() };
        for (k, (pname, pty)) in params.iter().enumerate() {
            let name = (!pname.is_empty()).then(|| pname.to_string());
            let local = f.add_local(name, *pty, LocalDef::Param(k as u32));
            f.params.push(Param { local, attrs: vec![] });
        }
        FunctionBuilder { m: self, f, name: name.to_string(), cur: None, next_name: None }
    }
}

// ---------------------------------------------------------------------------
// FunctionBuilder

/// Builds one function's body: blocks, and instructions added at the end of
/// the current block (see the module documentation).
pub struct FunctionBuilder<'m> {
    m: &'m mut Module,
    f: Function,
    name: String,
    cur: Option<BlockId>,
    next_name: Option<String>,
}

impl<'m> FunctionBuilder<'m> {
    /// The module, for types and constants.
    pub fn module(&mut self) -> &mut Module {
        self.m
    }

    /// The function as built so far.
    pub fn function(&self) -> &Function {
        &self.f
    }

    /// Parameter `k`.
    pub fn param(&self, k: usize) -> Value {
        Value::Local(self.f.params[k].local)
    }

    /// A new block at the end of the function, which instructions now go
    /// into.
    pub fn block(&mut self, name: &str) -> BlockId {
        let name = (!name.is_empty()).then(|| name.to_string());
        let b = if self.f.blocks.is_empty() {
            let label = self.m.types.label();
            self.f.add_entry_block(name, label)
        } else {
            let b = self.f.add_block(name);
            self.f.layout.push(b);
            b
        };
        self.cur = Some(b);
        b
    }

    /// A new block, not yet where instructions go (for a branch forward).
    pub fn new_block(&mut self, name: &str) -> BlockId {
        let here = self.cur;
        let b = self.block(name);
        self.cur = here;
        b
    }

    /// Instructions now go at the end of block `b`.
    pub fn at(&mut self, b: BlockId) -> &mut Self {
        self.cur = Some(b);
        self
    }

    pub fn current_block(&self) -> Option<BlockId> {
        self.cur
    }

    /// Names the next instruction's result (`%name`).
    pub fn name(&mut self, name: &str) -> &mut Self {
        self.next_name = Some(name.to_string());
        self
    }

    /// The type of value `v`.
    pub fn type_of(&mut self, v: Value) -> TypeId {
        self.m.value_type(Some(&self.f), v)
    }

    pub fn const_int(&mut self, ty: TypeId, value: i64) -> Value {
        self.m.const_int(ty, value)
    }

    pub fn const_float(&mut self, ty: TypeId, value: f64) -> Value {
        self.m.const_float(ty, value)
    }

    /// Adds `op` at the end of the current block, with a result of type `ty`
    /// if it has one; returns the result (or `None`).
    pub fn push(&mut self, op: Op, ty: Option<TypeId>) -> Option<Value> {
        let b = self.cur.expect("no current block: call block() first");
        if let Some(&last) = self.f.blocks[b.index()].insts.last() {
            assert!(!self.f.insts[last.index()].op.is_terminator(), "block {b:?} already ends in a terminator");
        }
        let name = self.next_name.take();
        let i = self.f.push_inst(b, op, ty.map(|t| (name, t)));
        ty.map(|_| self.f.result(i))
    }

    fn value(&mut self, op: Op, ty: TypeId) -> Value {
        self.push(op, Some(ty)).unwrap()
    }

    fn is_int(&mut self, ty: TypeId) -> bool {
        let s = self.m.types.scalar(ty);
        matches!(self.m.types.get(s), Type::Int(_))
    }

    fn is_float(&mut self, ty: TypeId) -> bool {
        let s = self.m.types.scalar(ty);
        FloatKind::of(self.m.types.get(s)).is_some()
    }

    fn same(&mut self, what: &str, a: Value, b: Value) -> TypeId {
        let (ta, tb) = (self.type_of(a), self.type_of(b));
        assert!(
            ta == tb,
            "{what}: operands of different types, {:?} and {:?}",
            self.m.types.get(ta),
            self.m.types.get(tb)
        );
        ta
    }

    // Arithmetic -------------------------------------------------------------

    /// A binary operation, with flags (`nuw`, `nsw`, `exact`, `disjoint`).
    pub fn binary_with(&mut self, op: BinOp, flags: IntFlags, a: Value, b: Value) -> Value {
        let ty = self.same(op.keyword(), a, b);
        if op.is_float() {
            assert!(self.is_float(ty), "{}: needs floating-point operands", op.keyword());
        } else {
            assert!(self.is_int(ty), "{}: needs integer operands", op.keyword());
        }
        self.value(Op::Binary { op, flags, fmf: FastMath::default(), lhs: a, rhs: b }, ty)
    }

    pub fn binary(&mut self, op: BinOp, a: Value, b: Value) -> Value {
        self.binary_with(op, IntFlags::NONE, a, b)
    }

    pub fn add(&mut self, a: Value, b: Value) -> Value {
        self.binary(BinOp::Add, a, b)
    }
    pub fn sub(&mut self, a: Value, b: Value) -> Value {
        self.binary(BinOp::Sub, a, b)
    }
    pub fn mul(&mut self, a: Value, b: Value) -> Value {
        self.binary(BinOp::Mul, a, b)
    }
    pub fn sdiv(&mut self, a: Value, b: Value) -> Value {
        self.binary(BinOp::SDiv, a, b)
    }
    pub fn udiv(&mut self, a: Value, b: Value) -> Value {
        self.binary(BinOp::UDiv, a, b)
    }
    pub fn srem(&mut self, a: Value, b: Value) -> Value {
        self.binary(BinOp::SRem, a, b)
    }
    pub fn urem(&mut self, a: Value, b: Value) -> Value {
        self.binary(BinOp::URem, a, b)
    }
    pub fn shl(&mut self, a: Value, b: Value) -> Value {
        self.binary(BinOp::Shl, a, b)
    }
    pub fn lshr(&mut self, a: Value, b: Value) -> Value {
        self.binary(BinOp::LShr, a, b)
    }
    pub fn ashr(&mut self, a: Value, b: Value) -> Value {
        self.binary(BinOp::AShr, a, b)
    }
    pub fn and(&mut self, a: Value, b: Value) -> Value {
        self.binary(BinOp::And, a, b)
    }
    pub fn or(&mut self, a: Value, b: Value) -> Value {
        self.binary(BinOp::Or, a, b)
    }
    pub fn xor(&mut self, a: Value, b: Value) -> Value {
        self.binary(BinOp::Xor, a, b)
    }
    pub fn fadd(&mut self, a: Value, b: Value) -> Value {
        self.binary(BinOp::FAdd, a, b)
    }
    pub fn fsub(&mut self, a: Value, b: Value) -> Value {
        self.binary(BinOp::FSub, a, b)
    }
    pub fn fmul(&mut self, a: Value, b: Value) -> Value {
        self.binary(BinOp::FMul, a, b)
    }
    pub fn fdiv(&mut self, a: Value, b: Value) -> Value {
        self.binary(BinOp::FDiv, a, b)
    }
    pub fn fneg(&mut self, a: Value) -> Value {
        let ty = self.type_of(a);
        assert!(self.is_float(ty), "fneg: needs a floating-point operand");
        self.value(Op::FNeg { fmf: FastMath::default(), value: a }, ty)
    }

    // Comparisons and selects ------------------------------------------------

    /// The type of a comparison's result: `i1`, or `<N x i1>` for vectors.
    fn bool_like(&mut self, ty: TypeId) -> TypeId {
        let i1 = self.m.types.int(1);
        self.m.types.with_elem(ty, i1)
    }

    pub fn icmp(&mut self, pred: ICmpPred, a: Value, b: Value) -> Value {
        let ty = self.same("icmp", a, b);
        let s = self.m.types.scalar(ty);
        assert!(
            matches!(self.m.types.get(s), Type::Int(_) | Type::Ptr(_)),
            "icmp: needs integer or pointer operands"
        );
        let r = self.bool_like(ty);
        self.value(Op::ICmp { pred, samesign: false, lhs: a, rhs: b }, r)
    }

    pub fn fcmp(&mut self, pred: FCmpPred, a: Value, b: Value) -> Value {
        let ty = self.same("fcmp", a, b);
        assert!(self.is_float(ty), "fcmp: needs floating-point operands");
        let r = self.bool_like(ty);
        self.value(Op::FCmp { pred, fmf: FastMath::default(), lhs: a, rhs: b }, r)
    }

    pub fn select(&mut self, cond: Value, a: Value, b: Value) -> Value {
        let ty = self.same("select", a, b);
        let ct = self.type_of(cond);
        let cs = self.m.types.scalar(ct);
        assert!(matches!(self.m.types.get(cs), Type::Int(1)), "select: the condition must be i1 (or <N x i1>)");
        self.value(Op::Select { fmf: FastMath::default(), cond, then_value: a, else_value: b }, ty)
    }

    // Casts --------------------------------------------------------------------

    pub fn cast(&mut self, op: CastOp, v: Value, to: TypeId) -> Value {
        self.value(Op::Cast { op, flags: IntFlags::NONE, fmf: FastMath::default(), value: v }, to)
    }
    pub fn zext(&mut self, v: Value, to: TypeId) -> Value {
        self.cast(CastOp::ZExt, v, to)
    }
    pub fn sext(&mut self, v: Value, to: TypeId) -> Value {
        self.cast(CastOp::SExt, v, to)
    }
    pub fn trunc(&mut self, v: Value, to: TypeId) -> Value {
        self.cast(CastOp::Trunc, v, to)
    }
    pub fn bitcast(&mut self, v: Value, to: TypeId) -> Value {
        self.cast(CastOp::BitCast, v, to)
    }

    // Memory -------------------------------------------------------------------

    /// `alloca ty`: a pointer to a new stack slot.
    pub fn alloca(&mut self, ty: TypeId) -> Value {
        let ptr = self.m.types.ptr(0);
        self.value(Op::Alloca { inalloca: false, ty, count: None, align: None, addrspace: None }, ptr)
    }

    /// `load ty, ptr p`
    pub fn load(&mut self, ty: TypeId, p: Value) -> Value {
        self.value(Op::Load { volatile: false, atomic: None, ptr: p, align: None }, ty)
    }

    /// `store v, ptr p`
    pub fn store(&mut self, v: Value, p: Value) {
        self.push(Op::Store { volatile: false, atomic: None, value: v, ptr: p, align: None }, None);
    }

    /// `getelementptr source_ty, ptr p, indices...`
    pub fn gep(&mut self, source_ty: TypeId, p: Value, indices: &[Value]) -> Value {
        let ptr = self.m.types.ptr(0);
        self.value(
            Op::Gep { flags: GepFlags::default(), inrange: None, source_ty, ptr: p, indices: indices.to_vec() },
            ptr,
        )
    }

    // Aggregates and vectors ---------------------------------------------------

    pub fn extract_value(&mut self, agg: Value, indices: &[u32]) -> Value {
        let mut ty = self.type_of(agg);
        for &k in indices {
            ty = self.m.types.member(ty, k as u64).expect("extractvalue: an index past the aggregate's members");
        }
        self.value(Op::ExtractValue { aggregate: agg, indices: indices.to_vec() }, ty)
    }

    pub fn insert_value(&mut self, agg: Value, element: Value, indices: &[u32]) -> Value {
        let ty = self.type_of(agg);
        self.value(Op::InsertValue { aggregate: agg, element, indices: indices.to_vec() }, ty)
    }

    pub fn extract_element(&mut self, vector: Value, index: Value) -> Value {
        let ty = self.type_of(vector);
        let Type::Vector { elem, .. } = *self.m.types.get(ty) else { panic!("extractelement: not a vector") };
        self.value(Op::ExtractElement { vector, index }, elem)
    }

    pub fn insert_element(&mut self, vector: Value, element: Value, index: Value) -> Value {
        let ty = self.type_of(vector);
        self.value(Op::InsertElement { vector, element, index }, ty)
    }

    // Calls --------------------------------------------------------------------

    /// A call of function `callee` (a function of the module); its value,
    /// unless it returns `void`.
    pub fn call(&mut self, callee: GlobalId, args: &[Value]) -> Option<Value> {
        let GlobalKind::Function(f) = &self.m.global(callee).kind else { panic!("call: not a function") };
        let fn_ty = f.ty;
        let target = self.m.global_value(callee);
        self.call_indirect(fn_ty, target, args)
    }

    /// A call through pointer `target`, of function type `fn_ty`.
    pub fn call_indirect(&mut self, fn_ty: TypeId, target: Value, args: &[Value]) -> Option<Value> {
        let Type::Function { ret, params, varargs } = self.m.types.get(fn_ty).clone() else {
            panic!("call: not a function type")
        };
        assert!(
            args.len() == params.len() || (varargs && args.len() > params.len()),
            "call: {} arguments for {} parameters",
            args.len(),
            params.len()
        );
        for (k, (&a, &p)) in args.iter().zip(&params).enumerate() {
            let t = self.type_of(a);
            assert!(t == p, "call: argument {k} is {:?}, the parameter {:?}", self.m.types.get(t), self.m.types.get(p));
        }
        let void = matches!(self.m.types.get(ret), Type::Void);
        self.push(Op::Call(Box::new(Call::new(fn_ty, target, args))), (!void).then_some(ret))
    }

    // Phis and control flow ----------------------------------------------------

    /// A phi of type `ty` at the start of the current block (after its other
    /// phis), with these entries; more can be added with `add_incoming`.
    pub fn phi(&mut self, ty: TypeId, incoming: &[(Value, BlockId)]) -> Value {
        let b = self.cur.expect("no current block: call block() first");
        let name = self.next_name.take();
        let i = self.f.add_inst(Op::Phi { fmf: FastMath::default(), incoming: incoming.to_vec() }, Some((name, ty)));
        let insts = &self.f.blocks[b.index()].insts;
        let at = insts.iter().take_while(|&&x| self.f.insts[x.index()].op.is_phi()).count();
        self.f.blocks[b.index()].insts.insert(at, i);
        self.f.result(i)
    }

    /// Adds an entry to phi `phi`, made by `phi`.
    pub fn add_incoming(&mut self, phi: Value, v: Value, from: BlockId) {
        let Value::Local(l) = phi else { panic!("add_incoming: not a phi") };
        let LocalDef::Inst(i) = self.f.locals[l.index()].def else { panic!("add_incoming: not a phi") };
        let Op::Phi { incoming, .. } = &mut self.f.insts[i.index()].op else { panic!("add_incoming: not a phi") };
        incoming.push((v, from));
    }

    pub fn br(&mut self, dest: BlockId) {
        self.push(Op::Br(dest), None);
    }

    pub fn cond_br(&mut self, cond: Value, then_dest: BlockId, else_dest: BlockId) {
        self.push(Op::CondBr { cond, then_dest, else_dest }, None);
    }

    /// `switch v, default [cases]`, each case a constant of `v`'s type.
    pub fn switch(&mut self, v: Value, default: BlockId, cases: &[(i64, BlockId)]) {
        let ty = self.type_of(v);
        let cases = cases
            .iter()
            .map(|&(k, b)| {
                let c = Constant::int(&self.m.types, ty, k);
                (self.m.consts.intern(c), b)
            })
            .collect();
        self.push(Op::Switch { value: v, default, cases }, None);
    }

    pub fn ret(&mut self, v: Value) {
        let want = match self.m.types.get(self.f.ty) {
            Type::Function { ret, .. } => *ret,
            _ => unreachable!(),
        };
        let got = self.type_of(v);
        assert!(got == want, "ret: a {:?} from a function returning {:?}", self.m.types.get(got), self.m.types.get(want));
        self.push(Op::Ret(Some(v)), None);
    }

    pub fn ret_void(&mut self) {
        self.push(Op::Ret(None), None);
    }

    pub fn unreachable(&mut self) {
        self.push(Op::Unreachable, None);
    }

    /// Checks that every block ends in a terminator and has no other, then
    /// adds the function to the module, in place of a declaration of the
    /// same name if there is one.
    pub fn finish(self) -> Result<GlobalId, String> {
        let f = self.f;
        if f.layout.is_empty() {
            return Err(format!("@{}: no blocks", self.name));
        }
        for &b in &f.layout {
            let insts = &f.blocks[b.index()].insts;
            let ends = insts.last().is_some_and(|i| f.insts[i.index()].op.is_terminator());
            if !ends {
                let name = f.block_name(b).unwrap_or("?").to_string();
                return Err(format!("@{}: block %{name} does not end in a terminator", self.name));
            }
        }
        match self.m.find_global(&self.name) {
            Some(g) => {
                let GlobalKind::Function(old) = &mut self.m.globals[g.index()].kind else {
                    return Err(format!("@{}: already a global that is not a function", self.name));
                };
                if old.has_body {
                    return Err(format!("@{}: already defined", self.name));
                }
                **old = f;
                Ok(g)
            }
            None => Ok(self.m.add_global(Global::function(&self.name, f))),
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    /// A loop with a phi, a call to a declared function and a store: the
    /// built module prints as the IR it stands for, and parses back the same.
    #[test]
    fn a_loop_prints_and_parses_back() {
        let mut m = Module::default();
        let i32t = m.types.int(32);
        let ptr = m.types.ptr(0);
        let void = m.types.void();
        let report = m.declare("report", void, &[i32t], false);
        let mut b = m.function("sum_to", i32t, &[("n", i32t), ("out", ptr)]);
        let (n, out) = (b.param(0), b.param(1));
        let entry = b.block("entry");
        let lp = b.new_block("loop");
        let done = b.new_block("done");
        b.br(lp);
        b.at(lp);
        let zero = b.const_int(i32t, 0);
        let i = b.name("i").phi(i32t, &[(zero, entry)]);
        let s = b.name("s").phi(i32t, &[(zero, entry)]);
        let one = b.const_int(i32t, 1);
        let i1 = b.name("i1").add(i, one);
        let s1 = b.name("s1").add(s, i1);
        b.add_incoming(i, i1, lp);
        b.add_incoming(s, s1, lp);
        let more = b.name("more").icmp(ICmpPred::Slt, i1, n);
        b.cond_br(more, lp, done);
        b.at(done);
        b.store(s1, out);
        b.call(report, &[s1]);
        b.ret(s1);
        b.finish().unwrap();
        let text = m.to_string();
        let want = "define i32 @sum_to(i32 %n, ptr %out) {\n\
                    entry:\n  br label %loop\n\n\
                    loop:                                             ; preds = %loop, %entry\n\
                    \x20 %i = phi i32 [ 0, %entry ], [ %i1, %loop ]\n\
                    \x20 %s = phi i32 [ 0, %entry ], [ %s1, %loop ]\n\
                    \x20 %i1 = add i32 %i, 1\n  %s1 = add i32 %s, %i1\n\
                    \x20 %more = icmp slt i32 %i1, %n\n  br i1 %more, label %loop, label %done\n\n\
                    done:                                             ; preds = %loop\n\
                    \x20 store i32 %s1, ptr %out\n  call void @report(i32 %s1)\n  ret i32 %s1\n}";
        assert!(text.contains(want), "{text}");
        let back = crate::parse_module(&text).unwrap();
        assert_eq!(back.to_string(), text);
    }

    #[test]
    #[should_panic(expected = "operands of different types")]
    fn mismatched_operands_panic() {
        let mut m = Module::default();
        let (i32t, i64t) = (m.types.int(32), m.types.int(64));
        let mut b = m.function("f", i32t, &[("a", i32t), ("b", i64t)]);
        b.block("entry");
        let (x, y) = (b.param(0), b.param(1));
        b.add(x, y);
    }

    #[test]
    fn a_block_without_a_terminator_is_an_error() {
        let mut m = Module::default();
        let i32t = m.types.int(32);
        let mut b = m.function("f", i32t, &[("a", i32t)]);
        b.block("entry");
        let x = b.param(0);
        b.add(x, x);
        assert!(b.finish().unwrap_err().contains("does not end in a terminator"));
    }

    #[test]
    fn a_declaration_is_replaced_by_its_definition() {
        let mut m = Module::default();
        let i64t = m.types.int(64);
        let g = m.declare("twice", i64t, &[i64t], false);
        let mut b = m.function("twice", i64t, &[("x", i64t)]);
        b.block("entry");
        let x = b.param(0);
        let r = b.add(x, x);
        b.ret(r);
        assert_eq!(b.finish().unwrap(), g);
        assert!(m.to_string().contains("define i64 @twice(i64 %x)"));
    }
}
