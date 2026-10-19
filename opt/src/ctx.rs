//! The state shared by threads while passes run on functions in parallel.
//!
//! A module splits cleanly into per-function state and module-wide state.
//! Each function owns its locals, blocks and instructions. Types, constants
//! and metadata are interned in module-wide tables, and global headers
//! (names, linkage, attributes) are module-wide too.
//!
//! For a parallel phase, `parallel_phase` takes the module apart:
//!
//! - Each function body moves into its own `FnSlot`. A task `take`s the
//!   bodies it works on, so it has `&mut Function` with no locking, and
//!   `publish`es them when done. A published body is read-only from then
//!   on, so any task can read it without locking.
//! - The type and constant tables become `table::TypeTable` and
//!   `table::ConstTable`, which any thread reads with no lock; adding an
//!   entry takes a lock briefly. Metadata, which passes rarely touch, goes
//!   behind a `RwLock`.
//! - The rest of the module stays behind a shared `&Module`, read-only.
//!   Global headers cannot change during a phase: a pass that needs a new
//!   global declares it before the phase starts.
//!
//! Output never depends on thread timing. Interned ids can come out in a
//! different order from run to run, but the printer writes types and
//! constants by content and renumbers metadata by walking the module, so
//! the text is the same. Identified structs are the exception (they print
//! in table order), so parallel passes only create literal structs.

use std::sync::{Mutex, OnceLock, RwLock, RwLockReadGuard};

use crate::table::{ConstTable, TypeTable};

use draconian_ir::apint::ApInt;
use draconian_ir::module::*;
use draconian_ir::types::{Type, TypeId};

/// One function's body during a parallel phase.
pub struct FnSlot {
    /// The body while nobody has taken it.
    work: Mutex<Option<Box<Function>>>,
    /// The body once published.
    done: OnceLock<Box<Function>>,
    /// Remarks about this function, printed in module order at the end.
    remarks: Mutex<Vec<String>>,
}

/// Functions a pass may call that must be declared before a phase starts.
#[derive(Clone, Copy, Debug, Default)]
pub struct Intrinsics {
    /// `ptr @llvm.stacksave.p0()`
    pub stacksave: Option<GlobalId>,
    /// `void @llvm.stackrestore.p0(ptr)`
    pub stackrestore: Option<GlobalId>,
    /// `void @llvm.memset.p0.i64(ptr, i8, i64, i1)`
    pub memset: Option<GlobalId>,
    /// `iN @llvm.fshl.iN(iN, iN, iN)` for N = 8, 16, 32, 64, in that order.
    pub fshl: [Option<GlobalId>; 4],
}

pub struct Shared<'m> {
    /// Read-only. Its type, constant and metadata tables are empty during
    /// the phase, and function bodies must be read through the slots.
    pub module: &'m Module,
    types: TypeTable,
    consts: ConstTable,
    metadata: RwLock<Vec<MdNode>>,
    /// Indexed by `GlobalId`; `None` for globals that are not functions.
    slots: Vec<Option<FnSlot>>,
    pub intrinsics: Intrinsics,
    /// The module's data layout, or the defaults if it has none or it does
    /// not parse.
    pub layout: draconian_ir::layout::DataLayout,
}

/// Runs `phase` with the module split up for parallel work, then puts it
/// back together. Returns what `phase` returns, and the remarks of each
/// function in module order.
pub fn parallel_phase<R>(
    m: &mut Module,
    intrinsics: Intrinsics,
    phase: impl FnOnce(&Shared) -> R,
) -> (R, Vec<(GlobalId, Vec<String>)>) {
    let types = std::mem::take(&mut m.types);
    let consts = std::mem::take(&mut m.consts);
    let metadata = std::mem::take(&mut m.metadata);
    let slots: Vec<Option<FnSlot>> = m
        .globals
        .iter_mut()
        .map(|g| match &mut g.kind {
            GlobalKind::Function(body) => {
                let body = std::mem::take(body);
                let slot = FnSlot { work: Mutex::new(None), done: OnceLock::new(), remarks: Mutex::new(Vec::new()) };
                if body.has_body {
                    *slot.work.lock().unwrap() = Some(body);
                } else {
                    // Declarations never change; publish them now.
                    let _ = slot.done.set(body);
                }
                Some(slot)
            }
            _ => None,
        })
        .collect();

    let shared = Shared {
        module: m,
        types: TypeTable::new(types),
        consts: ConstTable::new(consts),
        metadata: RwLock::new(metadata),
        slots,
        intrinsics,
        layout: m
            .data_layout
            .as_deref()
            .and_then(|s| draconian_ir::layout::DataLayout::parse(&String::from_utf8_lossy(s)).ok())
            .unwrap_or_default(),
    };
    let result = phase(&shared);
    let Shared { types, consts, metadata, slots, .. } = shared;

    m.types = types.into_inner();
    m.consts = consts.into_inner();
    m.metadata = metadata.into_inner().unwrap();
    let mut remarks = Vec::new();
    for (i, slot) in slots.into_iter().enumerate() {
        let Some(slot) = slot else { continue };
        let body = match slot.done.into_inner() {
            Some(b) => b,
            None => slot.work.into_inner().unwrap().expect("a function body was taken and never published"),
        };
        let GlobalKind::Function(f) = &mut m.globals[i].kind else { unreachable!() };
        *f = body;
        let list = slot.remarks.into_inner().unwrap();
        if !list.is_empty() {
            remarks.push((GlobalId(i as u32), list));
        }
    }
    let mut position = vec![usize::MAX; m.globals.len()];
    for (k, g) in m.global_order.iter().enumerate() {
        position[g.index()] = k;
    }
    remarks.sort_by_key(|(g, _)| position[g.index()]);
    (result, remarks)
}

impl Shared<'_> {
    fn slot(&self, g: GlobalId) -> &FnSlot {
        self.slots[g.index()].as_ref().expect("not a function")
    }

    pub fn is_function(&self, g: GlobalId) -> bool {
        self.slots.get(g.index()).is_some_and(|s| s.is_some())
    }

    /// Takes a body to work on. Panics if it was already taken.
    pub fn take(&self, g: GlobalId) -> Box<Function> {
        self.slot(g).work.lock().unwrap().take().expect("function body already taken")
    }

    /// Makes a body read-only and visible to every task.
    pub fn publish(&self, g: GlobalId, body: Box<Function>) {
        if self.slot(g).done.set(body).is_err() {
            panic!("function published twice");
        }
    }

    /// A published body, or `None` if it is not published yet.
    pub fn published(&self, g: GlobalId) -> Option<&Function> {
        self.slots.get(g.index())?.as_ref()?.done.get().map(|b| &**b)
    }

    pub fn remark(&self, g: GlobalId, text: String) {
        self.slot(g).remarks.lock().unwrap().push(text);
    }

    pub fn name(&self, g: GlobalId) -> String {
        match &self.module.globals[g.index()].name {
            Some(n) => n.clone(),
            None => format!("{}", g.0),
        }
    }

    // Types

    pub fn types(&self) -> &TypeTable {
        &self.types
    }

    pub fn ty(&self, id: TypeId) -> Type {
        self.types().get(id).clone()
    }

    pub fn intern_type(&self, ty: Type) -> TypeId {
        self.types.intern(ty)
    }

    // Constants

    pub fn consts(&self) -> &ConstTable {
        &self.consts
    }

    pub fn intern_const(&self, c: Constant) -> ConstId {
        self.consts.intern(c)
    }

    pub fn int(&self, bits: u32, value: i64) -> Value {
        let ty = self.intern_type(Type::Int(bits));
        Value::Const(self.intern_const(Constant { ty, kind: ConstKind::Int(ApInt::from_i64(bits, value)) }))
    }

    pub fn null_ptr(&self) -> Value {
        let ty = self.intern_type(Type::Ptr(0));
        Value::Const(self.intern_const(Constant { ty, kind: ConstKind::Null }))
    }

    pub fn undef(&self, ty: TypeId) -> Value {
        Value::Const(self.intern_const(Constant { ty, kind: ConstKind::Undef }))
    }

    pub fn poison(&self, ty: TypeId) -> Value {
        Value::Const(self.intern_const(Constant { ty, kind: ConstKind::Poison }))
    }

    /// The address of a global, as a `ptr` constant.
    pub fn global_ref(&self, g: GlobalId) -> Value {
        let ty = self.intern_type(Type::Ptr(0));
        Value::Const(self.intern_const(Constant { ty, kind: ConstKind::Global(g) }))
    }

    /// The function a call calls directly, if the callee is a function's
    /// address.
    pub fn direct_callee(&self, call: &Call) -> Option<GlobalId> {
        let Value::Const(c) = call.callee else { return None };
        let ConstKind::Global(g) = self.consts().get(c).kind else { return None };
        self.is_function(g).then_some(g)
    }

    // Metadata

    pub fn metadata(&self) -> RwLockReadGuard<'_, Vec<MdNode>> {
        self.metadata.read().unwrap()
    }

    /// Adds a node. Identical nodes are merged after the phase.
    pub fn add_md(&self, data: Metadata) -> MdId {
        let mut md = self.metadata.write().unwrap();
        md.push(MdNode { slot: None, data });
        MdId(md.len() as u32 - 1)
    }

    /// Replaces the contents of a node added during this phase.
    pub fn set_md(&self, id: MdId, data: Metadata) {
        self.metadata.write().unwrap()[id.index()].data = data;
    }

    /// `metadata <value>`, as used by debug records.
    pub fn md_value(&self, v: Value) -> MdId {
        self.add_md(Metadata::Value(v))
    }
}
