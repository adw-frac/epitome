//! Interning tables that many threads read without locking.
//!
//! During a parallel phase, the types and constants that existed before it
//! started are frozen: any thread reads them with no synchronisation at
//! all. Entries added during the phase go into an append-only list whose
//! entries never move, so they are read without a lock too. Only adding an
//! entry takes a lock, to keep the lookup map consistent.
//!
//! Reads vastly outnumber additions: a combine reads constants on every
//! instruction it visits and creates one only when a rule computes a new
//! value. With a read-write lock instead, every read was an atomic update
//! of the lock's cache line, which made eight threads slower than one.

use crate::fx::FxHashMap as HashMap;
use std::hash::Hash;
use std::sync::atomic::{AtomicUsize, Ordering};
use std::sync::{Mutex, OnceLock};

use epitome_ir::module::{ConstId, Constant, Constants};
use epitome_ir::types::{NamedStruct, Type, TypeId, Types};

/// Chunk `k` holds `FIRST << k` entries, so 40 chunks are more than enough.
const FIRST: usize = 256;
const CHUNKS: usize = 40;

/// A list that only grows, whose entries can be read by index with no lock
/// while another thread appends.
struct AppendOnly<T> {
    chunks: [OnceLock<Box<[OnceLock<T>]>>; CHUNKS],
    len: AtomicUsize,
}

impl<T> AppendOnly<T> {
    fn new() -> Self {
        AppendOnly { chunks: std::array::from_fn(|_| OnceLock::new()), len: AtomicUsize::new(0) }
    }

    fn locate(i: usize) -> (usize, usize) {
        // Chunk k starts at FIRST * (2^k - 1).
        let k = (i / FIRST + 1).ilog2() as usize;
        (k, i - FIRST * ((1 << k) - 1))
    }

    /// Appends; the caller holds the lock that serialises appends.
    fn push(&self, value: T) -> usize {
        let i = self.len.load(Ordering::Relaxed);
        let (k, at) = Self::locate(i);
        let chunk = self.chunks[k].get_or_init(|| (0..FIRST << k).map(|_| OnceLock::new()).collect());
        if chunk[at].set(value).is_err() {
            unreachable!("slot filled twice");
        }
        self.len.store(i + 1, Ordering::Release);
        i
    }

    /// Reads an entry. Only indices handed out by `push` are valid.
    fn get(&self, i: usize) -> &T {
        let (k, at) = Self::locate(i);
        self.chunks[k].get().and_then(|c| c[at].get()).expect("entry not yet added")
    }

    fn into_vec(self) -> Vec<T> {
        let n = self.len.into_inner();
        let mut out = Vec::with_capacity(n);
        let mut chunks = self.chunks.into_iter();
        while out.len() < n {
            let chunk = chunks.next().unwrap().into_inner().unwrap();
            out.extend(chunk.into_vec().into_iter().map_while(|c| c.into_inner()).take(n - out.len()));
        }
        out
    }
}

/// The part shared by both tables: frozen entries below `base_len`, new
/// ones after.
struct Grown<T: Clone + Eq + Hash> {
    added: AppendOnly<T>,
    map: Mutex<HashMap<T, usize>>,
}

impl<T: Clone + Eq + Hash> Grown<T> {
    fn new() -> Self {
        Grown { added: AppendOnly::new(), map: Mutex::new(HashMap::default()) }
    }

    /// The index among the added entries, adding it if new.
    fn intern(&self, value: T) -> usize {
        let mut map = self.map.lock().unwrap();
        if let Some(&i) = map.get(&value) {
            return i;
        }
        let i = self.added.push(value.clone());
        map.insert(value, i);
        i
    }
}

/// Constants during a parallel phase.
pub struct ConstTable {
    base: Constants,
    grown: Grown<Constant>,
}

impl ConstTable {
    pub fn new(base: Constants) -> Self {
        ConstTable { base, grown: Grown::new() }
    }

    pub fn get(&self, id: ConstId) -> &Constant {
        let n = self.base.len();
        if id.index() < n { self.base.get(id) } else { self.grown.added.get(id.index() - n) }
    }

    pub fn intern(&self, c: Constant) -> ConstId {
        if let Some(id) = self.base.lookup(&c) {
            return id;
        }
        ConstId((self.base.len() + self.grown.intern(c)) as u32)
    }

    /// Puts the module's table back together, with the same ids.
    pub fn into_inner(self) -> Constants {
        let mut base = self.base;
        for c in self.grown.added.into_vec() {
            let expect = base.len();
            assert_eq!(base.intern(c).index(), expect, "constant ids changed while merging");
        }
        base
    }
}

/// Types during a parallel phase. No identified structs can be added.
pub struct TypeTable {
    base: Types,
    grown: Grown<Type>,
}

impl TypeTable {
    pub fn new(base: Types) -> Self {
        TypeTable { base, grown: Grown::new() }
    }

    pub fn get(&self, id: TypeId) -> &Type {
        let n = self.base.len();
        if (id.0 as usize) < n { self.base.get(id) } else { self.grown.added.get(id.0 as usize - n) }
    }

    pub fn intern(&self, ty: Type) -> TypeId {
        if let Some(id) = self.base.lookup(&ty) {
            return id;
        }
        TypeId((self.base.len() + self.grown.intern(ty)) as u32)
    }

    /// The element type of a vector, or the type itself.
    pub fn scalar(&self, id: TypeId) -> TypeId {
        match self.get(id) {
            Type::Vector { elem, .. } => *elem,
            _ => id,
        }
    }

    pub fn structs(&self) -> &[NamedStruct] {
        &self.base.structs
    }

    pub fn into_inner(self) -> Types {
        let mut base = self.base;
        for t in self.grown.added.into_vec() {
            let expect = base.len();
            assert_eq!(base.intern(t).0 as usize, expect, "type ids changed while merging");
        }
        base
    }
}

impl epitome_ir::layout::TypeAccess for TypeTable {
    fn ty(&self, id: TypeId) -> &Type {
        self.get(id)
    }
    fn named(&self) -> &[NamedStruct] {
        self.structs()
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn append_only_keeps_order_across_chunks() {
        let list = AppendOnly::new();
        for i in 0..5000 {
            assert_eq!(list.push(i), i);
        }
        assert_eq!(*list.get(0), 0);
        assert_eq!(*list.get(255), 255);
        assert_eq!(*list.get(256), 256);
        assert_eq!(*list.get(4999), 4999);
        assert_eq!(list.into_vec(), (0..5000).collect::<Vec<_>>());
    }

    #[test]
    fn many_threads_intern_the_same_values() {
        let table = TypeTable::new(Types::default());
        let ids: Vec<Vec<TypeId>> = std::thread::scope(|s| {
            let hs: Vec<_> =
                (0..8).map(|_| s.spawn(|| (1..200).map(|b| table.intern(Type::Int(b))).collect::<Vec<_>>())).collect();
            hs.into_iter().map(|h| h.join().unwrap()).collect()
        });
        assert!(ids.windows(2).all(|w| w[0] == w[1]));
        for (k, id) in ids[0].iter().enumerate() {
            assert_eq!(*table.get(*id), Type::Int(k as u32 + 1));
        }
    }
}
