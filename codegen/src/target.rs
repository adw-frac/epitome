//! Reading a machine description and building its selection patterns.
//!
//! See `docs/design/isel.md`. A description is an LLVM IR module; functions
//! with an `"enc"` attribute are instructions, functions with `"cond"` are
//! condition forms, and functions with `"recipe"` are recipes. Their bodies
//! become pattern trees, by evaluating each body with its parameters as
//! leaves: condition forms and flag-setting instructions are put in for
//! `"cond"` operands, and the trees are simplified as they are built.

use std::collections::HashMap;

use smaugian_ir::module::*;
use smaugian_ir::types::{Type, TypeId};

use crate::enc::{self, Encoding, Env};

/// A register class: which register names to print, and what number 31
/// means.
#[derive(Clone, Copy, PartialEq, Eq, Debug, Hash)]
pub enum Class {
    W,
    X,
    /// Like `W`, but 31 is the stack pointer.
    Wsp,
    Xsp,
}

impl Class {
    pub fn parse(s: &str) -> Option<Class> {
        Some(match s {
            "w" => Class::W,
            "x" => Class::X,
            "wsp" => Class::Wsp,
            "xsp" => Class::Xsp,
            _ => return None,
        })
    }

    pub fn is_64(self) -> bool {
        matches!(self, Class::X | Class::Xsp)
    }

    /// The register name for number `r`.
    pub fn name(self, r: u8) -> String {
        match (self, r) {
            (Class::W, 31) => "wzr".into(),
            (Class::X, 31) => "xzr".into(),
            (Class::Wsp, 31) => "wsp".into(),
            (Class::Xsp, 31) => "sp".into(),
            (c, r) if c.is_64() => format!("x{r}"),
            (_, r) => format!("w{r}"),
        }
    }

    /// The same class, but 32 or 64 bits wide.
    pub fn with_width(self, wide: bool) -> Class {
        match (self, wide) {
            (Class::W | Class::X, false) => Class::W,
            (Class::W | Class::X, true) => Class::X,
            (Class::Wsp | Class::Xsp, false) => Class::Wsp,
            (Class::Wsp | Class::Xsp, true) => Class::Xsp,
        }
    }
}

#[derive(Clone, Copy, PartialEq, Eq, Debug)]
pub enum Kind {
    Reg(Class),
    Imm,
    Label,
    Sym,
    Cond,
}

#[derive(Clone, Debug)]
pub struct Operand {
    pub name: String,
    pub kind: Kind,
    /// Bits of the value's IR type: immediates are compared at this width.
    pub bits: u32,
    pub tied: bool,
    /// Read and written: the base register of a post-increment access.
    pub writeback: bool,
}

#[derive(Clone, Debug)]
pub struct Instr {
    pub name: String,
    /// The result first, called `d`, if there is one; then the parameters.
    pub operands: Vec<Operand>,
    pub has_result: bool,
    pub enc: Encoding,
    pub asm: String,
    pub decode: bool,
    /// The result is zero above this many bits (64: nothing known).
    pub zext: u32,
    pub copy: Option<Class>,
    pub role: Option<String>,
    /// Which flags it sets, if it is a comparison.
    pub sets: Option<String>,
    pub matchable: bool,
    /// For a conditional branch: the branch taken when this one is not.
    pub inverse: Option<String>,
    pub func: GlobalId,
}

impl Instr {
    /// The operands with fields of their own: a tied operand is held in
    /// the result's field.
    pub fn operand_names(&self) -> Vec<String> {
        self.operands.iter().filter(|o| !o.tied).map(|o| o.name.clone()).collect()
    }

    /// Decodes `word` as this instruction, tied operands included.
    pub fn decode(&self, word: u32) -> Option<Env> {
        let mut env = self.enc.decode(word, &self.operand_names())?;
        let d = env.get("d").copied();
        for o in self.operands.iter().filter(|o| o.tied) {
            env.insert(o.name.clone(), d?);
        }
        Some(env)
    }

    /// Whether these operand values can be encoded: each immediate must
    /// survive an encode and decode. `None` values are registers, labels or
    /// symbols, and are given placeholders.
    pub fn fits(&self, values: &[Option<i64>]) -> bool {
        let mut env = Env::new();
        for (o, v) in self.operands.iter().zip(values) {
            env.insert(o.name.clone(), v.unwrap_or(0));
        }
        let Some(word) = self.enc.encode(&env) else { return false };
        let Some(back) = self.decode(word) else { return false };
        self.operands.iter().zip(values).all(|(o, v)| match (o.kind, v) {
            (Kind::Imm, Some(v)) => {
                let m = if o.bits >= 64 { u64::MAX } else { (1u64 << o.bits) - 1 };
                (back[&o.name] as u64) & m == (*v as u64) & m
            }
            _ => true,
        })
    }
}

#[derive(Clone, Debug)]
pub struct CondForm {
    pub name: String,
    pub value: i64,
    pub asm: String,
    pub reads: String,
    pub func: GlobalId,
}

/// The operation at a pattern node or IR instruction, with the bit widths
/// that matter for it.
#[derive(Clone, Copy, PartialEq, Eq, Hash, Debug)]
pub enum Head {
    Bin(BinOp, u32),
    ICmp(ICmpPred, u32),
    Select(u32),
    Cast(CastOp, u32, u32),
    Load(u32),
    Store(u32),
    /// `getelementptr i8, ptr, i64`.
    Gep,
    CondBr,
    Br,
    Ret,
    Unreachable,
    /// A call to an intrinsic, by its index in `Target::intrinsics`.
    Intrinsic(u16, u32),
}

impl Head {
    pub fn commutative(self) -> bool {
        matches!(
            self,
            Head::Bin(BinOp::Add | BinOp::Mul | BinOp::And | BinOp::Or | BinOp::Xor, _)
                | Head::ICmp(ICmpPred::Eq | ICmpPred::Ne, _)
        )
    }
}

/// Width class of a binary operation: operations whose low bits depend only
/// on their operands' low bits work on any value narrower than 32 bits in
/// a W register, whatever is above it.
pub fn bin_bits(op: BinOp, bits: u32) -> u32 {
    match op {
        BinOp::Add | BinOp::Sub | BinOp::Mul | BinOp::And | BinOp::Or | BinOp::Xor | BinOp::Shl if bits <= 32 => 32,
        _ => bits,
    }
}

pub fn wide_bits(bits: u32) -> u32 {
    if bits <= 32 { 32 } else { bits }
}

#[derive(Clone, Debug, PartialEq)]
pub enum Tree {
    Op(Head, Vec<Tree>),
    /// A pattern parameter.
    Leaf(usize),
    /// A constant, sign-extended, and its width.
    Lit(i64, u32),
    /// The block reached by falling through.
    Next,
    // Only while building:
    Flags(Box<Tree>, Box<Tree>),
    Poison,
}

impl Tree {
    fn nodes(&self) -> usize {
        match self {
            Tree::Op(_, kids) => 1 + kids.iter().map(Tree::nodes).sum::<usize>(),
            _ => 0,
        }
    }

    fn substitute(&self, p: usize, with: &Tree) -> Tree {
        match self {
            Tree::Leaf(q) if *q == p => with.clone(),
            Tree::Op(h, kids) => mk(*h, kids.iter().map(|k| k.substitute(p, with)).collect()),
            t => t.clone(),
        }
    }

    fn leaves(&self, out: &mut Vec<usize>) {
        match self {
            Tree::Leaf(p) => out.push(*p),
            Tree::Op(_, kids) => kids.iter().for_each(|k| k.leaves(out)),
            _ => {}
        }
    }
}

/// Builds a node, simplifying as it goes.
fn mk(h: Head, kids: Vec<Tree>) -> Tree {
    match (h, kids.as_slice()) {
        // A comparison of two values sign-extended from the same width is
        // a comparison of the values.
        (
            Head::ICmp(p, _),
            [Tree::Op(Head::Cast(CastOp::SExt, a, _), x), Tree::Op(Head::Cast(CastOp::SExt, b, _), y)],
        ) if a == b => mk(Head::ICmp(p, *a), vec![x[0].clone(), y[0].clone()]),
        (Head::ICmp(p, _), [Tree::Op(Head::Cast(CastOp::SExt, a, _), x), Tree::Lit(k, _)]) if fits_signed(*k, *a) => {
            mk(Head::ICmp(p, *a), vec![x[0].clone(), Tree::Lit(*k, *a)])
        }
        (Head::Cast(CastOp::SExt, _, to), [Tree::Lit(k, _)]) => Tree::Lit(*k, to),
        // Identities left by putting 0 in for an operand.
        (Head::Gep, [p, Tree::Lit(0, _)]) => p.clone(),
        (Head::Bin(BinOp::Add | BinOp::Shl | BinOp::Or | BinOp::Xor, _), [x, Tree::Lit(0, _)]) => x.clone(),
        _ => Tree::Op(h, kids),
    }
}

fn fits_signed(k: i64, bits: u32) -> bool {
    bits >= 64 || (-(1i64 << (bits - 1))..(1i64 << (bits - 1))).contains(&k)
}

pub fn sext(v: u64, bits: u32) -> i64 {
    if bits >= 64 { v as i64 } else { ((v << (64 - bits)) as i64) >> (64 - bits) }
}

/// Where an emitted instruction's operand comes from.
#[derive(Clone, Copy, PartialEq, Debug)]
pub enum Src {
    /// The pattern's result.
    Result,
    Param(usize),
    /// The result of an earlier emitted instruction (by index).
    Temp(usize),
    Imm(i64),
}

#[derive(Clone, Debug)]
pub struct Emit {
    pub instr: usize,
    /// One per operand of the instruction.
    pub args: Vec<Src>,
}

#[derive(Clone, Debug)]
pub struct PParam {
    pub kind: Kind,
    pub bits: u32,
}

#[derive(Clone, Debug)]
pub struct Pattern {
    pub name: String,
    pub tree: Tree,
    pub params: Vec<PParam>,
    pub emit: Vec<Emit>,
    pub nodes: usize,
    /// The wildcards in preorder: a parameter, or `None` for the
    /// fall-through block.
    pub wild: Vec<Option<usize>>,
    /// Further results, for instructions that write back their base: a
    /// tree another IR instruction in the block must match, with the
    /// parameters shared, and the operand of `emit[0]` that receives it.
    pub extra: Vec<(Tree, usize)>,
}

pub struct Target {
    pub module: Module,
    pub instrs: Vec<Instr>,
    pub by_name: HashMap<String, usize>,
    pub conds: Vec<CondForm>,
    pub patterns: Vec<Pattern>,
    /// Instructions whose body is `ret %imm`: ways to make a constant.
    pub constants: Vec<usize>,
    pub copies: HashMap<Class, usize>,
    pub trie: Trie,
    /// Intrinsics the description's bodies call, such as `llvm.smax.i32`.
    pub intrinsics: Vec<String>,
    fits_cache: std::sync::Mutex<HashMap<FitsKey, bool>>,
}

fn attr<'a>(attrs: &'a [Attr], key: &str) -> Option<Option<&'a str>> {
    attrs.iter().find_map(|a| match a {
        Attr::Str { key: k, value } if k == key.as_bytes() => {
            Some(value.as_deref().map(|v| std::str::from_utf8(v).unwrap_or("")))
        }
        _ => None,
    })
}

fn type_bits(m: &Module, ty: TypeId) -> u32 {
    match m.types.get(ty) {
        Type::Int(b) => *b,
        Type::Ptr(_) => 64,
        _ => 0,
    }
}

impl Target {
    pub fn aarch64() -> Target {
        Target::load(include_str!("../targets/aarch64.ll")).expect("the built-in AArch64 description is valid")
    }

    pub fn load(src: &str) -> Result<Target, String> {
        let module = smaugian_ir::parse_module(src).map_err(|e| format!("{e:?}"))?;
        let mut t = Target {
            module,
            instrs: Vec::new(),
            by_name: HashMap::new(),
            conds: Vec::new(),
            patterns: Vec::new(),
            constants: Vec::new(),
            copies: HashMap::new(),
            trie: Trie::default(),
            intrinsics: Vec::new(),
            fits_cache: Default::default(),
        };
        t.read()?;
        t.build_patterns()?;
        let mut trie = Trie::default();
        for (i, p) in t.patterns.iter().enumerate() {
            trie.insert(p, i);
        }
        t.trie = trie;
        Ok(t)
    }

    /// `Instr::fits`, remembered: the same few immediates come up again
    /// and again.
    pub fn fits_cached(&self, i: usize, vals: Vec<Option<i64>>) -> bool {
        let key = (i, vals);
        if let Some(&ok) = self.fits_cache.lock().unwrap().get(&key) {
            return ok;
        }
        let ok = self.instrs[i].fits(&key.1);
        self.fits_cache.lock().unwrap().insert(key, ok);
        ok
    }

    /// The condition that holds when condition `value` does not: the form
    /// whose comparison is the inverse of this one's.
    pub fn inverse_cond(&self, value: i64) -> Option<i64> {
        let pred_of = |form: &CondForm| -> Option<ICmpPred> {
            let f = self.func(form.func);
            f.insts.iter().find_map(|i| match i.op {
                Op::ICmp { pred, .. } => Some(pred),
                _ => None,
            })
        };
        let form = self.conds.iter().find(|c| c.value == value)?;
        let want = inverse(pred_of(form)?);
        self.conds.iter().find(|c| pred_of(c) == Some(want)).map(|c| c.value)
    }

    pub fn instr(&self, name: &str) -> &Instr {
        &self.instrs[self.by_name[name]]
    }

    pub fn func(&self, g: GlobalId) -> &Function {
        match &self.module.global(g).kind {
            GlobalKind::Function(f) => f,
            _ => unreachable!(),
        }
    }

    pub fn by_role(&self, role: &str) -> usize {
        self.instrs
            .iter()
            .position(|i| i.role.as_deref() == Some(role))
            .unwrap_or_else(|| panic!("no instruction has role {role}"))
    }

    fn read(&mut self) -> Result<(), String> {
        let m = &self.module;
        for (g, f) in m.functions() {
            if let Some(name) = &m.global(g).name
                && name.starts_with("llvm.")
                && !f.has_body
            {
                self.intrinsics.push(name.clone());
            }
        }
        let mut instrs = Vec::new();
        let mut conds = Vec::new();
        for (g, f) in m.functions() {
            let name = m.global(g).name.clone().unwrap_or_default();
            if let Some(Some(v)) = attr(&f.fn_attrs, "cond") {
                conds.push(CondForm {
                    name: name.clone(),
                    value: v.parse().map_err(|_| format!("@{name}: bad cond value"))?,
                    asm: attr(&f.fn_attrs, "asm").flatten().unwrap_or("").to_string(),
                    reads: attr(&f.fn_attrs, "reads").flatten().unwrap_or("nzcv").to_string(),
                    func: g,
                });
                continue;
            }
            let Some(Some(enc_text)) = attr(&f.fn_attrs, "enc") else { continue };
            let enc = enc::parse(enc_text).map_err(|e| format!("@{name}: {e}"))?;
            let fn_ty = m.types.get(f.ty).clone();
            let Type::Function { ret, .. } = fn_ty else { unreachable!() };
            // A struct result is the flags, for a comparison ("sets"), or
            // the value and the written-back base of a post-increment load.
            let aggregate = matches!(m.types.get(ret), Type::Named(_) | Type::Struct { .. });
            let flags = aggregate && attr(&f.fn_attrs, "sets").is_some();
            let ret_bits = if aggregate && !flags {
                let fields = match m.types.get(ret) {
                    Type::Struct { fields, .. } => fields.clone(),
                    Type::Named(n) => {
                        m.types.structs[*n as usize].body.as_ref().map(|b| b.fields.clone()).unwrap_or_default()
                    }
                    _ => vec![],
                };
                fields.first().map_or(0, |&t| type_bits(m, t))
            } else {
                type_bits(m, ret)
            };
            let writeback_ret = f.params.iter().any(|p| attr(&p.attrs, "writeback").is_some()) && !aggregate;
            let has_result = ret_bits > 0 && !flags && !writeback_ret;
            let mut operands = Vec::new();
            if has_result {
                let class = match attr(&f.fn_attrs, "dclass").flatten() {
                    Some(c) => Class::parse(c).ok_or_else(|| format!("@{name}: bad dclass"))?,
                    None if ret_bits <= 32 => Class::W,
                    None => Class::X,
                };
                operands.push(Operand {
                    name: "d".into(),
                    kind: Kind::Reg(class),
                    bits: ret_bits,
                    tied: false,
                    writeback: false,
                });
            }
            for p in &f.params {
                let local = &f.locals[p.local.index()];
                let pname = local.name.clone().unwrap_or_default();
                let kind = if let Some(Some(c)) = attr(&p.attrs, "reg") {
                    Kind::Reg(Class::parse(c).ok_or_else(|| format!("@{name}: bad register class {c}"))?)
                } else if attr(&p.attrs, "imm").is_some() {
                    Kind::Imm
                } else if attr(&p.attrs, "label").is_some() {
                    Kind::Label
                } else if attr(&p.attrs, "sym").is_some() {
                    Kind::Sym
                } else if attr(&p.attrs, "cond").is_some() {
                    Kind::Cond
                } else {
                    return Err(format!("@{name}: operand %{pname} has no kind"));
                };
                operands.push(Operand {
                    name: pname,
                    kind,
                    bits: type_bits(m, local.ty),
                    tied: attr(&p.attrs, "tied").is_some(),
                    writeback: attr(&p.attrs, "writeback").is_some(),
                });
            }
            let default_zext = if has_result && ret_bits <= 32 { 32 } else { 64 };
            instrs.push(Instr {
                name: name.clone(),
                operands,
                has_result,
                enc,
                asm: attr(&f.fn_attrs, "asm").flatten().unwrap_or("").to_string(),
                decode: attr(&f.fn_attrs, "nodecode").is_none(),
                zext: attr(&f.fn_attrs, "zext").flatten().and_then(|z| z.parse().ok()).unwrap_or(default_zext),
                copy: attr(&f.fn_attrs, "copy").flatten().and_then(Class::parse),
                role: attr(&f.fn_attrs, "role").flatten().map(str::to_string),
                sets: if flags {
                    Some(attr(&f.fn_attrs, "sets").flatten().unwrap_or("nzcv").to_string())
                } else {
                    None
                },
                matchable: attr(&f.fn_attrs, "nomatch").is_none(),
                inverse: attr(&f.fn_attrs, "inverse").flatten().map(str::to_string),
                func: g,
            });
        }
        for (i, ins) in instrs.iter().enumerate() {
            self.by_name.insert(ins.name.clone(), i);
            if let Some(c) = ins.copy {
                self.copies.insert(c, i);
            }
        }
        self.instrs = instrs;
        self.conds = conds;
        Ok(())
    }

    // -----------------------------------------------------------------------
    // Building trees from bodies

    /// Evaluates the body of `f` symbolically: `env` gives trees for some
    /// parameters, and the others become leaves numbered from `base`.
    fn eval_value(&self, f: &Function, v: Value, env: &HashMap<LocalId, Tree>, base: usize) -> Result<Tree, String> {
        match v {
            Value::Const(c) => {
                let k = self.module.constant(c);
                let bits = type_bits(&self.module, k.ty);
                Ok(match &k.kind {
                    ConstKind::Int(a) => Tree::Lit(sext(a.low_u64(), bits), bits),
                    ConstKind::Poison | ConstKind::Undef => Tree::Poison,
                    ConstKind::Zero | ConstKind::Null => Tree::Lit(0, bits),
                    other => return Err(format!("unsupported constant {other:?} in a body")),
                })
            }
            Value::Local(x) => {
                if let Some(t) = env.get(&x) {
                    return Ok(t.clone());
                }
                match f.locals[x.index()].def {
                    LocalDef::Param(i) => Ok(Tree::Leaf(base + i as usize)),
                    LocalDef::Inst(i) => self.eval_inst(f, i, env, base),
                    _ => Err("a block used as a value".into()),
                }
            }
            Value::Metadata(_) => Err("metadata in a body".into()),
        }
    }

    fn eval_inst(&self, f: &Function, i: InstId, env: &HashMap<LocalId, Tree>, base: usize) -> Result<Tree, String> {
        let m = &self.module;
        let ev = |v: Value| self.eval_value(f, v, env, base);
        let ty_bits = |v: Value| match v {
            Value::Local(x) => type_bits(m, f.locals[x.index()].ty),
            Value::Const(c) => type_bits(m, m.constant(c).ty),
            _ => 0,
        };
        let res_bits = f.insts[i.index()].result.map(|r| type_bits(m, f.locals[r.index()].ty)).unwrap_or(0);
        Ok(match &f.insts[i.index()].op {
            Op::Binary { op, lhs, rhs, .. } => mk(Head::Bin(*op, bin_bits(*op, res_bits)), vec![ev(*lhs)?, ev(*rhs)?]),
            Op::ICmp { pred, lhs, rhs, .. } => mk(Head::ICmp(*pred, ty_bits(*lhs)), vec![ev(*lhs)?, ev(*rhs)?]),
            Op::Select { cond, then_value, else_value, .. } => {
                mk(Head::Select(wide_bits(res_bits)), vec![ev(*cond)?, ev(*then_value)?, ev(*else_value)?])
            }
            Op::Cast { op, value, .. } => mk(Head::Cast(*op, ty_bits(*value), wide_bits(res_bits)), vec![ev(*value)?]),
            Op::Load { ptr, .. } => mk(Head::Load(res_bits), vec![ev(*ptr)?]),
            Op::Gep { ptr, indices, source_ty, .. }
                if indices.len() == 1 && matches!(m.types.get(*source_ty), Type::Int(8)) =>
            {
                mk(Head::Gep, vec![ev(*ptr)?, ev(indices[0])?])
            }
            Op::ExtractValue { aggregate, indices } => match (ev(*aggregate)?, indices.as_slice()) {
                (Tree::Flags(a, _), [0]) => *a,
                (Tree::Flags(_, b), [1]) => *b,
                (t, _) => return Err(format!("extractvalue from {t:?}")),
            },
            Op::InsertValue { aggregate, element, indices } => {
                let (a, b) = match ev(*aggregate)? {
                    Tree::Poison => (Tree::Poison, Tree::Poison),
                    Tree::Flags(a, b) => (*a, *b),
                    t => return Err(format!("insertvalue into {t:?}")),
                };
                let e = ev(*element)?;
                match indices.as_slice() {
                    [0] => Tree::Flags(Box::new(e), Box::new(b)),
                    [1] => Tree::Flags(Box::new(a), Box::new(e)),
                    _ => return Err("insertvalue index".into()),
                }
            }
            Op::Call(call) => {
                let Value::Const(c) = call.callee else { return Err("indirect call in a body".into()) };
                let ConstKind::Global(g) = self.module.constant(c).kind else { return Err("call".into()) };
                if let Some(id) =
                    self.module.global(g).name.as_ref().and_then(|n| self.intrinsics.iter().position(|x| x == n))
                {
                    let args = call.args.iter().map(|a| ev(a.value)).collect::<Result<Vec<_>, _>>()?;
                    return Ok(mk(Head::Intrinsic(id as u16, res_bits), args));
                }
                // An instruction, in an expansion: what its body says.
                if let Some(&idx) = self.module.global(g).name.as_ref().and_then(|n| self.by_name.get(n)) {
                    let callee = self.func(self.instrs[idx].func);
                    let mut inner = HashMap::new();
                    for (p, a) in callee.params.iter().zip(&call.args) {
                        inner.insert(p.local, ev(a.value)?);
                    }
                    let ret = self.ret_value(callee).ok_or("an instruction without a value")?;
                    return self.eval_value(callee, ret, &inner, 0);
                }
                // A condition form, applied to flags.
                let form =
                    self.conds.iter().find(|k| k.func == g).ok_or("call to something other than a condition form")?;
                let flags = ev(call.args[0].value)?;
                self.eval_cond(form, flags)?
            }
            op => return Err(format!("unsupported operation in a body: {op:?}")),
        })
    }

    fn eval_cond(&self, form: &CondForm, flags: Tree) -> Result<Tree, String> {
        let f = self.func(form.func);
        let mut env = HashMap::new();
        env.insert(f.params[0].local, flags);
        let ret = self.ret_value(f).ok_or("condition form without a value")?;
        self.eval_value(f, ret, &env, 0)
    }

    fn ret_value(&self, f: &Function) -> Option<Value> {
        let b = f.entry();
        let t = f.terminator(b)?;
        match f.insts[t.index()].op {
            Op::Ret(v) => v,
            _ => None,
        }
    }

    /// The pattern tree of a whole body.
    fn body_tree(&self, f: &Function, env: &HashMap<LocalId, Tree>, base: usize) -> Result<Option<Tree>, String> {
        let entry = f.entry();
        let t = f.terminator(entry).ok_or("body without a terminator")?;
        let label_of = |v: Value| -> Result<Tree, String> {
            match self.eval_value(f, v, env, base)? {
                Tree::Leaf(p) => Ok(Tree::Leaf(p)),
                t => Err(format!("jump to {t:?}")),
            }
        };
        // What one successor block of a conditional branch does.
        let arm = |b: BlockId| -> Result<Tree, String> {
            let insts = &f.blocks[b.index()].insts;
            match insts.as_slice() {
                [i] => match &f.insts[i.index()].op {
                    Op::IndirectBr { addr, .. } => label_of(*addr),
                    Op::Ret(None) => Ok(Tree::Next),
                    _ => Err("a branch arm must be indirectbr or ret void".into()),
                },
                _ => Err("a branch arm must be one instruction".into()),
            }
        };
        Ok(Some(match &f.insts[t.index()].op {
            Op::Ret(Some(v)) => self.eval_value(f, *v, env, base)?,
            Op::Ret(None) => {
                let store = f.blocks[entry.index()]
                    .insts
                    .iter()
                    .rev()
                    .find(|&&i| matches!(f.insts[i.index()].op, Op::Store { .. }));
                match store {
                    Some(&s) => {
                        let Op::Store { value, ptr, .. } = f.insts[s.index()].op else { unreachable!() };
                        let bits = match value {
                            Value::Local(x) => type_bits(&self.module, f.locals[x.index()].ty),
                            Value::Const(c) => type_bits(&self.module, self.module.constant(c).ty),
                            _ => 0,
                        };
                        mk(
                            Head::Store(bits),
                            vec![self.eval_value(f, value, env, base)?, self.eval_value(f, ptr, env, base)?],
                        )
                    }
                    None if f.blocks[entry.index()].insts.len() == 1 => Tree::Op(Head::Ret, vec![]),
                    None => return Ok(None),
                }
            }
            Op::Unreachable => Tree::Op(Head::Unreachable, vec![]),
            Op::IndirectBr { addr, .. } => Tree::Op(Head::Br, vec![label_of(*addr)?]),
            Op::CondBr { cond, then_dest, else_dest } => {
                Tree::Op(Head::CondBr, vec![self.eval_value(f, *cond, env, base)?, arm(*then_dest)?, arm(*else_dest)?])
            }
            op => return Err(format!("unsupported terminator in a body: {op:?}")),
        }))
    }

    // -----------------------------------------------------------------------
    // Patterns

    fn params_of(&self, ins: &Instr) -> Vec<PParam> {
        ins.operands
            .iter()
            .filter(|o| o.name != "d" || !ins.has_result)
            .map(|o| PParam { kind: o.kind, bits: o.bits })
            .collect()
    }

    /// The emitted instruction for `ins` with its parameters numbered from
    /// `base`, the condition operand given, and its result going to `res`.
    fn emit_of(&self, idx: usize, base: usize, cond: Option<i64>, res: Src) -> Emit {
        let ins = &self.instrs[idx];
        let mut args = Vec::new();
        let mut k = base;
        for o in &ins.operands {
            if o.name == "d" && ins.has_result {
                args.push(res);
            } else {
                args.push(match (o.kind, cond) {
                    (Kind::Cond, Some(v)) => Src::Imm(v),
                    _ => Src::Param(k),
                });
                k += 1;
            }
        }
        Emit { instr: idx, args }
    }

    fn build_patterns(&mut self) -> Result<(), String> {
        let mut out: Vec<Pattern> = Vec::new();
        let producers: Vec<usize> = (0..self.instrs.len()).filter(|&i| self.instrs[i].sets.is_some()).collect();
        for idx in 0..self.instrs.len() {
            let ins = &self.instrs[idx];
            if !ins.matchable || ins.copy.is_some() || ins.sets.is_some() {
                continue;
            }
            let f = self.func(ins.func);
            let params = self.params_of(ins);
            let cond_param = params.iter().position(|p| p.kind == Kind::Cond);
            match cond_param {
                None => {
                    let Some(tree) =
                        self.body_tree(f, &HashMap::new(), 0).map_err(|e| format!("@{}: {e}", ins.name))?
                    else {
                        continue;
                    };
                    match tree {
                        Tree::Leaf(p) if params[p].kind == Kind::Imm => {
                            self.constants.push(idx);
                            continue;
                        }
                        Tree::Leaf(_) => continue,
                        _ => {}
                    }
                    let emit = vec![self.emit_of(idx, 0, None, Src::Result)];
                    // A post-increment access: the access is the pattern,
                    // and the stepped base is a second root to find.
                    let mut extra = Vec::new();
                    let mut tree = tree;
                    if let Some(wb) = ins.operands.iter().position(|o| o.writeback) {
                        let entry = f.entry();
                        let store = f.blocks[entry.index()]
                            .insts
                            .iter()
                            .find(|&&i| matches!(f.insts[i.index()].op, Op::Store { .. }));
                        match (store, tree) {
                            (Some(&st), next) => {
                                let Op::Store { value, ptr, .. } = f.insts[st.index()].op else { unreachable!() };
                                let bits = match value {
                                    Value::Local(x) => type_bits(&self.module, f.locals[x.index()].ty),
                                    _ => 0,
                                };
                                let ev = |v| self.eval_value(f, v, &HashMap::new(), 0);
                                tree = mk(Head::Store(bits), vec![ev(value)?, ev(ptr)?]);
                                extra.push((next, wb));
                            }
                            (None, Tree::Flags(value, next)) => {
                                tree = *value;
                                extra.push((*next, wb));
                            }
                            (None, t) => {
                                return Err(format!(
                                    "@{}: a write-back instruction must return its base: {t:?}",
                                    ins.name
                                ));
                            }
                        }
                    }
                    out.push(Pattern { name: ins.name.clone(), tree, params, emit, nodes: 0, wild: vec![], extra });
                }
                Some(cp) => {
                    // Each condition form, on the flags of each comparison
                    // that sets the flags it reads.
                    for form in &self.conds {
                        for &pi in &producers {
                            let prod = &self.instrs[pi];
                            let sets = prod.sets.as_deref().unwrap_or("");
                            if !form.reads.chars().all(|c| sets.contains(c)) {
                                continue;
                            }
                            let base = params.len();
                            let pf = self.func(prod.func);
                            let ret = self.ret_value(pf).ok_or("comparison without a value")?;
                            let flags = self
                                .eval_value(pf, ret, &HashMap::new(), base)
                                .map_err(|e| format!("@{}: {e}", prod.name))?;
                            let cond = self.eval_cond(form, flags).map_err(|e| format!("@{}: {e}", form.name))?;
                            let mut env = HashMap::new();
                            env.insert(f.params[cp].local, cond);
                            let Some(tree) = self.body_tree(f, &env, 0).map_err(|e| format!("@{}: {e}", ins.name))?
                            else {
                                continue;
                            };
                            let mut all = params.clone();
                            all.extend(self.params_of(prod));
                            let emit = vec![
                                self.emit_of(pi, base, None, Src::Result),
                                self.emit_of(idx, 0, Some(form.value), Src::Result),
                            ];
                            out.push(Pattern {
                                name: format!("{}+{}.{}", prod.name, ins.name, form.asm),
                                tree,
                                params: all,
                                emit,
                                nodes: 0,
                                wild: vec![],
                                extra: vec![],
                            });
                        }
                    }
                }
            }
        }
        // Recipes.
        let m = &self.module;
        for (_, f) in m.functions() {
            let Some(Some(expand)) = attr(&f.fn_attrs, "recipe") else { continue };
            let tree = self.body_tree(f, &HashMap::new(), 0)?.ok_or("recipe without a value")?;
            let mut params = Vec::new();
            for p in &f.params {
                let kind = match attr(&p.attrs, "reg") {
                    Some(Some(c)) => Kind::Reg(Class::parse(c).ok_or("bad class")?),
                    _ => Kind::Imm,
                };
                params.push(PParam { kind, bits: type_bits(m, f.locals[p.local.index()].ty) });
            }
            let g = m
                .global_order
                .iter()
                .copied()
                .find(|&g| m.global(g).name.as_deref() == Some(expand))
                .ok_or_else(|| format!("no function @{expand}"))?;
            let emit = self.expansion(self.func(g)).map_err(|e| format!("@{expand}: {e}"))?;
            out.push(Pattern {
                name: expand.trim_end_matches(".expand").to_string(),
                tree,
                params,
                emit,
                nodes: 0,
                wild: vec![],
                extra: vec![],
            });
        }

        // Specialise immediates that can be zero, and give conditional
        // branches their inverted twin.
        let mut more = Vec::new();
        for p in &out {
            for (i, pp) in p.params.iter().enumerate() {
                if pp.kind != Kind::Imm {
                    continue;
                }
                let zero = Tree::Lit(0, pp.bits);
                let t = p.tree.substitute(i, &zero);
                let mut leaves = Vec::new();
                t.leaves(&mut leaves);
                // Only when an identity went: `gep p, 0` is `p`.
                if t.nodes() >= p.tree.nodes() || t.nodes() == 0 || leaves.contains(&i) {
                    continue;
                }
                let mut q = p.clone();
                q.tree = t;
                for e in &mut q.emit {
                    for a in &mut e.args {
                        if *a == Src::Param(i) {
                            *a = Src::Imm(0);
                        }
                    }
                }
                if self.pattern_fits(&q) {
                    q.name = format!("{} ({}=0)", q.name, i);
                    more.push(q);
                }
            }
        }
        out.extend(more);
        let mut more = Vec::new();
        for p in &out {
            if let Tree::Op(Head::CondBr, kids) = &p.tree
                && let Tree::Op(Head::ICmp(pred, bits), cmp) = &kids[0]
            {
                let mut q = p.clone();
                q.tree = Tree::Op(
                    Head::CondBr,
                    vec![Tree::Op(Head::ICmp(inverse(*pred), *bits), cmp.clone()), kids[2].clone(), kids[1].clone()],
                );
                q.name = format!("{} (inverted)", q.name);
                more.push(q);
            }
        }
        out.extend(more);
        for p in &mut out {
            p.nodes = p.tree.nodes() + p.extra.iter().map(|(t, _)| t.nodes()).sum::<usize>();
            let mut wild = Vec::new();
            preorder_wild(&p.tree, &mut wild);
            p.wild = wild;
            if let Some(t) = find_build_only(&p.tree) {
                return Err(format!("{}: pattern still has {t:?} in it", p.name));
            }
        }
        self.patterns = out;
        Ok(())
    }

    /// Whether a pattern with fixed immediates can be encoded.
    fn pattern_fits(&self, p: &Pattern) -> bool {
        p.emit.iter().all(|e| {
            let vals: Vec<Option<i64>> =
                e.args.iter().map(|a| if let Src::Imm(v) = a { Some(*v) } else { None }).collect();
            self.instrs[e.instr].fits(&vals)
        })
    }

    /// The instructions a recipe's expansion emits.
    fn expansion(&self, f: &Function) -> Result<Vec<Emit>, String> {
        let m = &self.module;
        // Each local of the expansion: a parameter, an earlier result, or a
        // condition form's value.
        #[derive(Clone, Copy)]
        enum Is {
            Src(Src),
            Cond(i64),
            Flags,
        }
        let mut is: HashMap<LocalId, Is> = HashMap::new();
        for (i, p) in f.params.iter().enumerate() {
            is.insert(p.local, Is::Src(Src::Param(i)));
        }
        let mut emit = Vec::new();
        let insts: Vec<InstId> = f.blocks[f.entry().index()].insts.clone();
        let src_of = |is: &HashMap<LocalId, Is>, v: Value| -> Result<Is, String> {
            match v {
                Value::Local(x) => is.get(&x).copied().ok_or_else(|| "unknown value".to_string()),
                Value::Const(c) => match &m.constant(c).kind {
                    ConstKind::Int(a) => Ok(Is::Src(Src::Imm(sext(a.low_u64(), type_bits(m, m.constant(c).ty))))),
                    _ => Err("unsupported constant".into()),
                },
                _ => Err("metadata".into()),
            }
        };
        let mut result = None;
        for i in insts {
            let inst = &f.insts[i.index()];
            match &inst.op {
                // Casts between types in the same register are free.
                Op::Cast { value, .. } => {
                    let s = src_of(&is, *value)?;
                    is.insert(inst.result.unwrap(), s);
                }
                Op::Call(call) => {
                    let Value::Const(c) = call.callee else { return Err("indirect call".into()) };
                    let ConstKind::Global(g) = m.constant(c).kind else { return Err("call".into()) };
                    if let Some(form) = self.conds.iter().find(|k| k.func == g) {
                        is.insert(inst.result.unwrap(), Is::Cond(form.value));
                        continue;
                    }
                    let name = m.global(g).name.clone().unwrap_or_default();
                    let idx = *self.by_name.get(&name).ok_or_else(|| format!("no instruction @{name}"))?;
                    let ins = &self.instrs[idx];
                    let mut args = Vec::new();
                    let mut k = 0;
                    for o in &ins.operands {
                        if o.name == "d" && ins.has_result {
                            args.push(Src::Temp(emit.len()));
                            continue;
                        }
                        args.push(match src_of(&is, call.args[k].value)? {
                            Is::Src(s) => s,
                            Is::Cond(v) => Src::Imm(v),
                            Is::Flags => return Err("flags as an operand".into()),
                        });
                        k += 1;
                    }
                    if let Some(r) = inst.result {
                        is.insert(r, if ins.sets.is_some() { Is::Flags } else { Is::Src(Src::Temp(emit.len())) });
                    }
                    emit.push(Emit { instr: idx, args });
                }
                Op::Ret(Some(v)) => {
                    let Is::Src(Src::Temp(k)) = src_of(&is, *v)? else {
                        return Err("must return an instruction's result".into());
                    };
                    result = Some(k);
                }
                op => return Err(format!("unsupported in an expansion: {op:?}")),
            }
        }
        // The returned temporary is the pattern's result.
        let r = result.ok_or("expansion without a result")?;
        for e in &mut emit {
            for a in &mut e.args {
                if *a == Src::Temp(r) {
                    *a = Src::Result;
                }
            }
        }
        Ok(emit)
    }
}

pub fn inverse(p: ICmpPred) -> ICmpPred {
    use ICmpPred::*;
    match p {
        Eq => Ne,
        Ne => Eq,
        Ugt => Ule,
        Uge => Ult,
        Ult => Uge,
        Ule => Ugt,
        Sgt => Sle,
        Sge => Slt,
        Slt => Sge,
        Sle => Sgt,
    }
}

fn find_build_only(t: &Tree) -> Option<Tree> {
    match t {
        Tree::Flags(..) | Tree::Poison => Some(t.clone()),
        Tree::Op(_, kids) => kids.iter().find_map(find_build_only),
        _ => None,
    }
}

fn preorder_wild(t: &Tree, out: &mut Vec<Option<usize>>) {
    match t {
        Tree::Leaf(p) => out.push(Some(*p)),
        Tree::Next => out.push(None),
        Tree::Op(_, kids) => kids.iter().for_each(|k| preorder_wild(k, out)),
        _ => {}
    }
}

// ---------------------------------------------------------------------------
// Checking

/// An instruction and the immediates it is asked to hold.
type FitsKey = (usize, Vec<Option<i64>>);

/// A recipe, for checking: its name, its parameters' widths, the tree of
/// the IR it replaces, and the tree of what its instructions do.
pub type RecipeCheck = (String, Vec<u32>, Tree, Tree);

impl Target {
    /// For each recipe: the tree of the IR it replaces, and the tree of
    /// what its instructions do, with their bodies put in for the calls.
    pub fn recipe_trees(&self) -> Result<Vec<RecipeCheck>, String> {
        let m = &self.module;
        let mut out = Vec::new();
        for (_, f) in m.functions() {
            let Some(Some(expand)) = attr(&f.fn_attrs, "recipe") else { continue };
            let want = self.body_tree(f, &HashMap::new(), 0)?.ok_or("recipe without a value")?;
            let g = m
                .global_order
                .iter()
                .copied()
                .find(|&g| m.global(g).name.as_deref() == Some(expand))
                .ok_or("no expansion")?;
            let e = self.func(g);
            let ret = self.ret_value(e).ok_or("expansion without a value")?;
            let got = self.eval_value(e, ret, &HashMap::new(), 0).map_err(|err| format!("@{expand}: {err}"))?;
            let bits = f.params.iter().map(|p| type_bits(m, f.locals[p.local.index()].ty)).collect();
            out.push((expand.to_string(), bits, want, got));
        }
        Ok(out)
    }

    /// Evaluates a tree on parameter values (each held in the low bits of
    /// a `u64`). `None` if the result is undefined, as for division by zero.
    pub fn eval_tree(&self, t: &Tree, args: &[u64]) -> Option<u64> {
        let mask = |bits: u32| if bits >= 64 { u64::MAX } else { (1u64 << bits) - 1 };
        Some(match t {
            Tree::Leaf(p) => args[*p],
            Tree::Lit(v, bits) => *v as u64 & mask(*bits),
            Tree::Op(h, kids) => {
                let k: Vec<u64> = kids.iter().map(|c| self.eval_tree(c, args)).collect::<Option<_>>()?;
                match *h {
                    Head::Bin(op, bits) => {
                        let m = mask(bits);
                        let (a, b) = (k[0] & m, k[1] & m);
                        let (sa, sb) = (sext(a, bits), sext(b, bits));
                        (match op {
                            BinOp::Add => a.wrapping_add(b),
                            BinOp::Sub => a.wrapping_sub(b),
                            BinOp::Mul => a.wrapping_mul(b),
                            BinOp::And => a & b,
                            BinOp::Or => a | b,
                            BinOp::Xor => a ^ b,
                            BinOp::Shl if b < bits as u64 => a << b,
                            BinOp::LShr if b < bits as u64 => a >> b,
                            BinOp::AShr if b < bits as u64 => (sa >> b) as u64,
                            BinOp::UDiv if b != 0 => a / b,
                            BinOp::URem if b != 0 => a % b,
                            BinOp::SDiv if b != 0 && !(sa == sext(1 << (bits - 1), bits) && sb == -1) => {
                                (sa / sb) as u64
                            }
                            BinOp::SRem if b != 0 && !(sa == sext(1 << (bits - 1), bits) && sb == -1) => {
                                (sa % sb) as u64
                            }
                            _ => return None,
                        }) & m
                    }
                    Head::ICmp(p, bits) => {
                        let m = mask(bits);
                        let (a, b) = (k[0] & m, k[1] & m);
                        let (sa, sb) = (sext(a, bits), sext(b, bits));
                        u64::from(match p {
                            ICmpPred::Eq => a == b,
                            ICmpPred::Ne => a != b,
                            ICmpPred::Ugt => a > b,
                            ICmpPred::Uge => a >= b,
                            ICmpPred::Ult => a < b,
                            ICmpPred::Ule => a <= b,
                            ICmpPred::Sgt => sa > sb,
                            ICmpPred::Sge => sa >= sb,
                            ICmpPred::Slt => sa < sb,
                            ICmpPred::Sle => sa <= sb,
                        })
                    }
                    Head::Select(_) => {
                        if k[0] & 1 != 0 {
                            k[1]
                        } else {
                            k[2]
                        }
                    }
                    Head::Cast(op, from, to) => {
                        let a = k[0] & mask(from);
                        (match op {
                            CastOp::ZExt | CastOp::Trunc | CastOp::BitCast => a,
                            CastOp::SExt => sext(a, from) as u64,
                            _ => return None,
                        }) & mask(to)
                    }
                    Head::Intrinsic(id, bits) => {
                        let m = mask(bits);
                        let (a, b) = (k[0] & m, k[1] & m);
                        let (sa, sb) = (sext(a, bits), sext(b, bits));
                        let name = &self.intrinsics[id as usize];
                        let pick = |x: bool| if x { a } else { b };
                        if name.starts_with("llvm.smax.") {
                            pick(sa >= sb)
                        } else if name.starts_with("llvm.smin.") {
                            pick(sa <= sb)
                        } else if name.starts_with("llvm.umax.") {
                            pick(a >= b)
                        } else if name.starts_with("llvm.umin.") {
                            pick(a <= b)
                        } else {
                            return None;
                        }
                    }
                    _ => return None,
                }
            }
            _ => return None,
        })
    }
}

// ---------------------------------------------------------------------------
// The trie

#[derive(Clone, Copy, PartialEq, Eq, Hash, Debug)]
pub enum Key {
    Head(Head),
    Lit(i64, u32),
    Wild,
}

#[derive(Default, Debug)]
pub struct TrieNode {
    /// Children by key. Nodes have few, so a list searched in order beats
    /// a hash map.
    pub next: Vec<(Key, usize)>,
    pub accept: Vec<usize>,
}

impl TrieNode {
    #[inline]
    pub fn get(&self, k: &Key) -> Option<usize> {
        self.next.iter().find(|(x, _)| x == k).map(|&(_, c)| c)
    }
}

/// A discrimination trie of patterns, keyed by their preorder traversal.
#[derive(Default, Debug)]
pub struct Trie {
    pub nodes: Vec<TrieNode>,
}

fn preorder_keys(t: &Tree, out: &mut Vec<Key>) {
    match t {
        Tree::Op(h, kids) => {
            out.push(Key::Head(*h));
            kids.iter().for_each(|k| preorder_keys(k, out));
        }
        Tree::Lit(v, b) => out.push(Key::Lit(*v, *b)),
        Tree::Leaf(_) | Tree::Next => out.push(Key::Wild),
        Tree::Flags(..) | Tree::Poison => unreachable!(),
    }
}

impl Trie {
    fn insert(&mut self, p: &Pattern, id: usize) {
        if self.nodes.is_empty() {
            self.nodes.push(TrieNode::default());
        }
        let mut keys = Vec::new();
        preorder_keys(&p.tree, &mut keys);
        let mut n = 0;
        for k in keys {
            n = match self.nodes[n].get(&k) {
                Some(c) => c,
                None => {
                    self.nodes.push(TrieNode::default());
                    let c = self.nodes.len() - 1;
                    self.nodes[n].next.push((k, c));
                    c
                }
            };
        }
        self.nodes[n].accept.push(id);
    }
}
