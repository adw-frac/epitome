//! Exception tables: each function with landing pads gets a language-
//! specific data area (LSDA), which its personality routine reads while
//! unwinding (`__gxx_personality_v0`, `rust_eh_personality`), in the form
//! the Itanium C++ ABI's unwinding uses and the platforms' assemblers write
//! (observed with clang):
//!
//! - the landing pads' base: omitted (the function's start);
//! - the type table's encoding (indirect, PC-relative, 4 bytes: through
//!   the GOT) and where it ends, or omitted when nothing is caught;
//! - the call sites, as ULEB128s: every call, so that unwinding through
//!   one is allowed, with its landing pad (from the function's start; 0 for
//!   none) and its action (0 for a cleanup only, else 1 + where its chain
//!   of action records starts);
//! - the action records: (filter, offset to the next), a filter being a
//!   type's index in the type table, from 1, to catch it; 0 for a cleanup;
//!   or negative for an exception filter (a list of types that may pass,
//!   -1 less the list's offset after the type table);
//! - the type table, last type first, each a GOT-relative reference to
//!   the type's information, or 0 to catch everything;
//! - after it, the filters' lists: type indices as ULEB128s, then 0.
//!
//! The function's unwind tables name the LSDA and the personality (see
//! `unwind.rs`).

use crate::abi::Syntax;
use crate::mir::{MFunc, MOp, Opcode};
use crate::target::Target;

/// A function's LSDA: its bytes, and where GOT-relative references to
/// symbols go in them (4 bytes each).
pub struct Lsda {
    pub bytes: Vec<u8>,
    pub got_refs: Vec<(u64, String)>,
}

pub fn uleb(out: &mut Vec<u8>, mut v: u64) {
    loop {
        let b = (v & 0x7f) as u8;
        v >>= 7;
        if v == 0 {
            out.push(b);
            return;
        }
        out.push(b | 0x80);
    }
}

pub fn sleb(out: &mut Vec<u8>, mut v: i64) {
    loop {
        let b = (v & 0x7f) as u8;
        v >>= 7;
        let done = (v == 0 && b & 0x40 == 0) || (v == -1 && b & 0x40 != 0);
        out.push(if done { b } else { b | 0x80 });
        if done {
            return;
        }
    }
}

/// The LSDA of `f`, laid out (its instructions' offsets are final), if it
/// has landing pads. `symbol` gives a type's symbol as the platform writes
/// it.
pub fn lsda(t: &Target, f: &MFunc, syntax: Syntax, symbol: &dyn Fn(&str) -> String) -> Result<Option<Lsda>, String> {
    let Some(eh) = &f.eh else { return Ok(None) };
    if syntax == Syntax::Elf {
        return Err(format!("{}: exception tables in ELF objects are not supported yet", f.name));
    }
    // Where each block starts.
    let mut starts = Vec::new();
    let mut at = 0u64;
    for b in &f.blocks {
        starts.push(at);
        at += b.insts.iter().map(|i| f.bytes(i) as u64).sum::<u64>();
    }
    // The action records, and where each action's chain starts.
    let mut actions = Vec::new();
    let mut chain_at = Vec::new();
    for (cleanup, filters) in &eh.actions {
        if filters.is_empty() {
            chain_at.push(None);
            continue;
        }
        chain_at.push(Some(actions.len() as u64));
        let mut list = filters.clone();
        if *cleanup {
            list.push(0);
        }
        for (k, &filter) in list.iter().enumerate() {
            sleb(&mut actions, filter);
            // The next record is right after this offset's one byte.
            sleb(&mut actions, if k + 1 < list.len() { 1 } else { 0 });
        }
    }
    // The call sites.
    let mut sites = Vec::new();
    let mut pc = 0u64;
    for b in &f.blocks {
        for inst in &b.insts {
            if let Opcode::Instr(k) = inst.op
                && (t.has_role(k, "call") || t.has_role(k, "callr"))
            {
                let n = t.instrs[k].operands.len();
                let (landing, action) = match (inst.ops.get(n), inst.ops.get(n + 1)) {
                    (Some(MOp::Label(lp)), Some(MOp::Imm(a))) => {
                        let c = usize::try_from(*a).ok().and_then(|a| chain_at.get(a)).ok_or_else(|| {
                            format!("{}: a call with landing-pad action {a}, of {}", f.name, chain_at.len())
                        })?;
                        let at = starts.get(*lp).ok_or_else(|| {
                            format!("{}: a call whose landing pad is block {lp}, of {}", f.name, starts.len())
                        })?;
                        (*at, c.map_or(0, |c| c + 1))
                    }
                    _ => (0, 0),
                };
                uleb(&mut sites, pc);
                uleb(&mut sites, f.bytes(inst) as u64);
                uleb(&mut sites, landing);
                uleb(&mut sites, action);
            }
            pc += f.bytes(inst) as u64;
        }
    }
    // The whole: the header, sites, actions, then the type table, aligned
    // to 4, ending where the header says (its distance counted from just
    // after it, so found by trying sizes).
    let types = eh.types.len();
    // A filter's list is found from the type table, so it is there even
    // if nothing is caught.
    let table = types > 0 || !eh.specs.is_empty();
    let mut out = Vec::new();
    for size in 1..6 {
        out.clear();
        out.push(0xff);
        out.push(if table { 0x9b } else { 0xff });
        let after_header = 2 + if table { size } else { 0 };
        let mut rest = vec![1u8];
        uleb(&mut rest, sites.len() as u64);
        rest.extend(&sites);
        rest.extend(&actions);
        if !table {
            out.extend(rest);
            return Ok(Some(Lsda { bytes: out, got_refs: vec![] }));
        }
        let mut len = after_header + rest.len();
        while len % 4 != 0 {
            rest.push(0);
            len += 1;
        }
        let ttbase = rest.len() + 4 * types;
        let mut field = Vec::new();
        uleb(&mut field, ttbase as u64);
        if field.len() != size {
            continue;
        }
        out.extend(field);
        out.extend(rest);
        let mut got_refs = Vec::new();
        for ty in eh.types.iter().rev() {
            match ty {
                Some(name) => {
                    got_refs.push((out.len() as u64, symbol(name)));
                    out.extend([0u8; 4]);
                }
                None => out.extend([0u8; 4]),
            }
        }
        out.extend(&eh.specs);
        return Ok(Some(Lsda { bytes: out, got_refs }));
    }
    Err(format!("{}: an exception table too big", f.name))
}
