//! Module-wide rules for metadata that the IR text shows but does not spell
//! out:
//!
//! - Identical nodes that are not `distinct` are the same node.
//! - Attachments are kept in a fixed order of their kinds.
//! - When printed, nodes are numbered in the order they are first reached,
//!   except `!DIExpression` and `!DIArgList`, which are always written inline.
//!
//! These rules come from reading what LLVM's tools print for small inputs
//! (`clang -S -emit-llvm -x ir`); see `docs/llvm-ir/08-observed-behaviour.md`.

use std::collections::HashMap;

use crate::module::*;

/// Attachment kinds built into LLVM, in the order LLVM prints them. Other
/// kinds follow, in the order the module first uses them.
pub const FIXED_KINDS: [&str; 41] = [
    "dbg",
    "tbaa",
    "prof",
    "fpmath",
    "range",
    "tbaa.struct",
    "invariant.load",
    "alias.scope",
    "noalias",
    "nontemporal",
    "llvm.mem.parallel_loop_access",
    "nonnull",
    "dereferenceable",
    "dereferenceable_or_null",
    "make.implicit",
    "unpredictable",
    "invariant.group",
    "align",
    "llvm.loop",
    "type",
    "section_prefix",
    "absolute_symbol",
    "associated",
    "callees",
    "irr_loop",
    "llvm.access.group",
    "callback",
    "vcall_visibility",
    "noundef",
    "annotation",
    "nosanitize",
    "func_sanitize",
    "exclude",
    "memprof",
    "callsite",
    "kcfi_type",
    "pcsections",
    "DIAssignID",
    "coro.outside.frame",
    "mmra",
    "noalias.addrspace",
];

impl Module {
    /// Records the first use of an attachment kind that is not built in.
    pub fn register_md_kind(&mut self, kind: &str) {
        if !FIXED_KINDS.contains(&kind) && !self.md_kinds.iter().any(|k| k == kind) {
            self.md_kinds.push(kind.to_string());
        }
    }

    /// The position of `kind` in attachment order. Unregistered kinds sort last.
    pub fn md_kind_rank(&self, kind: &str) -> usize {
        match FIXED_KINDS.iter().position(|&k| k == kind) {
            Some(i) => i,
            None => FIXED_KINDS.len() + self.md_kinds.iter().position(|k| k == kind).unwrap_or(usize::MAX / 2),
        }
    }

    /// Puts attachments into kind order.
    pub fn sort_attachments(&self, list: &mut [Attachment]) {
        list.sort_by_key(|a| self.md_kind_rank(&a.kind));
    }

    /// True for metadata that is always written where it is used, never as `!N`.
    pub fn md_is_inline(&self, id: MdId) -> bool {
        match &self.metadata[id.index()].data {
            Metadata::String(_) | Metadata::Value(_) => true,
            Metadata::Node { kind, .. } => kind == "DIExpression" || kind == "DIArgList",
            _ => false,
        }
    }
}

/// The nodes a node refers to, in operand order.
fn children(data: &Metadata) -> Vec<MdId> {
    match data {
        Metadata::Tuple { ops, .. } => ops.iter().flatten().copied().collect(),
        Metadata::Node { fields, .. } => fields
            .iter()
            .filter_map(|f| match f.value {
                MdFieldValue::Md(m) => Some(m),
                _ => None,
            })
            .collect(),
        _ => Vec::new(),
    }
}

/// The operands numbering walks, in the order it walks them. For most kinds
/// this is the printed field order, but a few kinds walk some fields early.
fn walk_children(data: &Metadata) -> Vec<MdId> {
    let Metadata::Node { kind, fields, .. } = data else { return children(data) };
    let early: &[&str] = match kind.as_str() {
        "DIDerivedType" | "DICompositeType" | "DILexicalBlock" | "DILexicalBlockFile" | "DIModule" => {
            &["file", "scope"]
        }
        "DISubprogram" => &["file", "scope", "type", "unit", "declaration", "retainedNodes"],
        _ => &[],
    };
    let mut refs: Vec<(usize, MdId)> = fields
        .iter()
        .filter_map(|f| match f.value {
            MdFieldValue::Md(m) => {
                let rank = f.name.as_deref().and_then(|n| early.iter().position(|&e| e == n)).unwrap_or(early.len());
                Some((rank, m))
            }
            _ => None,
        })
        .collect();
    refs.sort_by_key(|&(rank, _)| rank);
    refs.into_iter().map(|(_, m)| m).collect()
}

/// True when a node holds a function's local value. Such nodes belong to one
/// function, and `LocalId`s from different functions must not be compared.
fn holds_local(data: &Metadata) -> bool {
    match data {
        Metadata::Value(v) => matches!(v, Value::Local(_)),
        Metadata::Node { fields, .. } => fields.iter().any(|f| matches!(f.value, MdFieldValue::Value(Value::Local(_)))),
        _ => false,
    }
}

/// A copy of `data` with every operand replaced by `map(operand)`.
fn remap(data: &Metadata, map: impl Fn(MdId) -> MdId) -> Metadata {
    let mut data = data.clone();
    match &mut data {
        Metadata::Tuple { ops, .. } => ops.iter_mut().flatten().for_each(|o| *o = map(*o)),
        Metadata::Node { fields, .. } => {
            for f in fields {
                if let MdFieldValue::Md(m) = &mut f.value {
                    *m = map(*m);
                }
            }
        }
        _ => {}
    }
    data
}

/// Merges identical nodes that are not `distinct`, and points every
/// reference in the module at the surviving node. Merged-away nodes stay in
/// the table, unreferenced.
///
/// Two nodes are identical when they have the same kind and the same
/// operands after their operands have been merged. A node that reaches
/// itself through its operands is left alone.
pub fn unique_metadata(m: &mut Module) {
    const NEW: u8 = 0;
    const OPEN: u8 = 1;
    const DONE: u8 = 2;
    let n = m.metadata.len();
    let kids: Vec<Vec<MdId>> = m.metadata.iter().map(|node| children(&node.data)).collect();
    let mut canon: Vec<MdId> = (0..n as u32).map(MdId).collect();
    let mut state = vec![NEW; n];
    let mut cyclic = vec![false; n];
    let mut seen: HashMap<Metadata, MdId> = HashMap::new();

    // Operands are merged before the nodes that use them (post-order).
    let mut stack: Vec<(MdId, usize)> = Vec::new();
    for root in 0..n {
        if state[root] != NEW {
            continue;
        }
        state[root] = OPEN;
        stack.push((MdId(root as u32), 0));
        while let Some(top) = stack.last_mut() {
            let (id, next) = *top;
            if let Some(&kid) = kids[id.index()].get(next) {
                top.1 += 1;
                match state[kid.index()] {
                    NEW => {
                        state[kid.index()] = OPEN;
                        stack.push((kid, 0));
                    }
                    OPEN => cyclic[kid.index()] = true,
                    _ => {}
                }
                continue;
            }
            stack.pop();
            state[id.index()] = DONE;
            let data = &m.metadata[id.index()].data;
            let distinct =
                matches!(data, Metadata::Tuple { distinct: true, .. } | Metadata::Node { distinct: true, .. });
            if distinct || cyclic[id.index()] || holds_local(data) || matches!(data, Metadata::Forward) {
                continue;
            }
            let key = remap(data, |k| canon[k.index()]);
            canon[id.index()] = *seen.entry(key).or_insert(id);
        }
    }

    let map = |id: MdId| canon[id.index()];
    for node in &mut m.metadata {
        node.data = remap(&node.data, map);
    }
    for named in &mut m.named_metadata {
        named.ops.iter_mut().for_each(|o| *o = map(*o));
    }
    let remap_attachments = |list: &mut Vec<Attachment>| list.iter_mut().for_each(|a| a.node = map(a.node));
    for g in &mut m.globals {
        remap_attachments(&mut g.attachments);
        let GlobalKind::Function(f) = &mut g.kind else { continue };
        for inst in &mut f.insts {
            remap_attachments(&mut inst.attachments);
            for r in &mut inst.debug_records {
                r.args.iter_mut().for_each(|a| *a = map(*a));
            }
            if let Some(call) = inst.op.call_mut() {
                for arg in &mut call.args {
                    if let Value::Metadata(md) = &mut arg.value {
                        *md = map(*md);
                    }
                }
            }
        }
    }
}

/// The nodes that get numbers when `m` is printed, in number order.
///
/// Numbering walks the module in this order, giving each node its number
/// the first time it is reached and then walking its operands, depth first:
///
/// 1. attachments of global variables,
/// 2. named metadata,
/// 3. for each function, in module order: the function's attachments, then
///    for each instruction its debug records, its metadata arguments and its
///    attachments.
///
/// Inline nodes get no number, but their operands are still walked. Operands
/// are walked in field order, except for the kinds listed in `walk_children`.
pub fn numbering(m: &Module, globals: &[GlobalId]) -> Vec<MdId> {
    let mut walk = Walk { m, seen: vec![false; m.metadata.len()], order: Vec::new() };
    for &g in globals {
        if let GlobalKind::Variable(_) = m.global(g).kind {
            m.global(g).attachments.iter().for_each(|a| walk.visit(a.node));
        }
    }
    for named in &m.named_metadata {
        named.ops.iter().for_each(|&o| walk.visit(o));
    }
    for &g in globals {
        let GlobalKind::Function(f) = &m.global(g).kind else { continue };
        m.global(g).attachments.iter().for_each(|a| walk.visit(a.node));
        for &b in &f.layout {
            for &i in &f.blocks[b.index()].insts {
                let inst = &f.insts[i.index()];
                for r in &inst.debug_records {
                    r.args.iter().for_each(|&a| walk.visit(a));
                }
                if let Some(call) = inst.op.call() {
                    for arg in &call.args {
                        if let Value::Metadata(md) = arg.value {
                            walk.visit(md);
                        }
                    }
                }
                inst.attachments.iter().for_each(|a| walk.visit(a.node));
            }
        }
    }
    walk.order
}

struct Walk<'m> {
    m: &'m Module,
    seen: Vec<bool>,
    order: Vec<MdId>,
}

impl Walk<'_> {
    fn visit(&mut self, root: MdId) {
        // Marking nodes as they are popped gives the same order as a
        // recursive walk.
        let mut stack = vec![root];
        while let Some(id) = stack.pop() {
            if std::mem::replace(&mut self.seen[id.index()], true) {
                continue;
            }
            if !self.m.md_is_inline(id) {
                self.order.push(id);
            }
            stack.extend(walk_children(&self.m.metadata[id.index()].data).into_iter().rev());
        }
    }
}
