//! The in-memory form of MLIR: operations, regions, blocks and values, and
//! interned types and attributes.
//!
//! As in `epitome_ir`, everything lives in index-based tables. A module owns
//! its types, attributes and operation names, which are interned, and the
//! tables of operations, blocks, regions and values.
//!
//! Builtin types and attributes are kept as structures. A dialect's types
//! and attributes, and the builtin attributes whose bodies have a grammar
//! of their own (`dense<...>`, `affine_map<...>`, `strided<...>`), are kept
//! as the text that was written, so that any dialect can be read and
//! printed back.

use std::collections::HashMap;

macro_rules! id_type {
    ($($(#[$doc:meta])* $name:ident;)*) => {$(
        $(#[$doc])*
        #[derive(Clone, Copy, PartialEq, Eq, Hash, Debug, PartialOrd, Ord)]
        pub struct $name(pub u32);
        impl $name {
            pub fn index(self) -> usize { self.0 as usize }
        }
    )*};
}

id_type! {
    /// An interned type.
    TypeId;
    /// An interned attribute.
    AttrId;
    /// An interned operation name.
    NameId;
    /// An operation.
    OpId;
    /// A block.
    BlockId;
    /// A region.
    RegionId;
    /// A value: an operation's result or a block's argument.
    ValueId;
}

/// A table of interned items.
#[derive(Clone, Debug)]
pub struct Interner<T> {
    list: Vec<T>,
    map: HashMap<T, u32>,
}

impl<T> Default for Interner<T> {
    fn default() -> Self {
        Interner { list: Vec::new(), map: HashMap::new() }
    }
}

impl<T: Clone + Eq + std::hash::Hash> Interner<T> {
    fn intern(&mut self, item: T) -> u32 {
        if let Some(&id) = self.map.get(&item) {
            return id;
        }
        let id = self.list.len() as u32;
        self.list.push(item.clone());
        self.map.insert(item, id);
        id
    }

    pub fn len(&self) -> usize {
        self.list.len()
    }

    pub fn is_empty(&self) -> bool {
        self.list.is_empty()
    }
}

// ---------------------------------------------------------------------------
// Types

#[derive(Clone, Copy, PartialEq, Eq, Hash, Debug)]
pub enum Signedness {
    /// `iN`
    Signless,
    /// `siN`
    Signed,
    /// `uiN`
    Unsigned,
}

/// The builtin floating-point types, by keyword.
pub const FLOAT_TYPES: &[&str] = &[
    "bf16",
    "f16",
    "tf32",
    "f32",
    "f64",
    "f80",
    "f128",
    "f4E2M1FN",
    "f6E2M3FN",
    "f6E3M2FN",
    "f8E3M4",
    "f8E4M3",
    "f8E4M3FN",
    "f8E4M3FNUZ",
    "f8E4M3B11FNUZ",
    "f8E5M2",
    "f8E5M2FNUZ",
    "f8E8M0FNU",
];

/// A dimension of a shaped type: a size, or `?` for one known only at run
/// time.
pub type Dim = Option<u64>;

#[derive(Clone, PartialEq, Eq, Hash, Debug)]
pub enum Type {
    /// `i32`, `si8`, `ui16`
    Int { width: u32, signedness: Signedness },
    /// `index`
    Index,
    /// A float type, by its keyword in `FLOAT_TYPES`.
    Float(&'static str),
    /// `none`
    None,
    /// `complex<f32>`
    Complex(TypeId),
    /// `tuple<i32, f32>`
    Tuple(Vec<TypeId>),
    /// `vector<4x[8]xf32>`: each dimension's size, and whether it is
    /// scalable (written in brackets).
    Vector { dims: Vec<(u64, bool)>, elem: TypeId },
    /// `tensor<2x?xf32, #enc>`, or `tensor<*xf32>` with no shape.
    Tensor { shape: Option<Vec<Dim>>, elem: TypeId, encoding: Option<AttrId> },
    /// `memref<4x?xf32, #layout, 1>`, or `memref<*xf32, 1>` with no shape.
    /// `extra` is the layout and the memory space, as written: which one a
    /// single entry is depends on its kind.
    MemRef { shape: Option<Vec<Dim>>, elem: TypeId, extra: Vec<AttrId> },
    /// `(i32, f32) -> i8`
    Function { inputs: Vec<TypeId>, results: Vec<TypeId> },
    /// `opaque<"dialect", "text">`
    Opaque { dialect: Vec<u8>, data: Vec<u8> },
    /// A dialect type, `!llvm.ptr` or `!llvm.struct<(i32, f32)>`: its name,
    /// and the bracketed body that follows it, as written.
    Dialect { name: String, body: Option<String> },
    /// A use of a type alias, `!name`.
    Alias(String),
}

// ---------------------------------------------------------------------------
// Attributes

#[derive(Clone, PartialEq, Eq, Hash, Debug)]
pub enum Attr {
    /// `unit`, or a dictionary entry with no value.
    Unit,
    /// `true` or `false`.
    Bool(bool),
    /// An integer as written, with its sign, and its type if one was given:
    /// `-1 : i32`.
    Int { text: String, ty: Option<TypeId> },
    /// A float as written: `1.000000e+00 : f32`.
    Float { text: String, ty: Option<TypeId> },
    /// `"text"`, possibly typed.
    String { bytes: Vec<u8>, ty: Option<TypeId> },
    /// A type used as an attribute.
    Type(TypeId),
    /// `[a, b]`
    Array(Vec<AttrId>),
    /// `{a = 1, b}`, in the order written.
    Dict(Vec<(String, AttrId)>),
    /// `@a::@b`
    SymbolRef(Vec<String>),
    /// A builtin attribute whose body is kept as written: `dense`,
    /// `dense_resource`, `sparse`, `array`, `affine_map`, `affine_set`,
    /// `strided`, `distinct`, `opaque`. `body` is what follows the keyword,
    /// such as `<[1, 2]>`; `ty` is the type after a `:`.
    Builtin { keyword: &'static str, body: String, ty: Option<TypeId> },
    /// A dialect attribute, `#llvm.linkage<external>`: its name, and the
    /// bracketed body that follows it, as written.
    Dialect { name: String, body: Option<String> },
    /// A use of an attribute alias, `#name`.
    Alias(String),
    /// A location, `loc(...)`.
    Loc(Loc),
}

/// The builtin attributes that `Attr::Builtin` keeps as text.
pub const BUILTIN_ATTRS: &[&str] =
    &["dense", "dense_resource", "sparse", "array", "affine_map", "affine_set", "strided", "distinct", "opaque"];

/// The builtin attributes that may be followed by `: type`.
pub const TYPED_BUILTIN_ATTRS: &[&str] = &["dense", "dense_resource", "sparse", "opaque"];

/// A location. Its parts are attributes: locations, or aliases of them.
#[derive(Clone, PartialEq, Eq, Hash, Debug)]
pub enum Loc {
    /// `unknown`
    Unknown,
    /// `"file":line:col`, with an end such as `to 3:4` or `to :9` kept as
    /// written.
    File { file: Vec<u8>, line: u32, col: u32, end: Option<String> },
    /// `"name"`, or `"name"(child)`.
    Name { name: Vec<u8>, child: Option<AttrId> },
    /// `callsite(callee at caller)`
    CallSite { callee: AttrId, caller: AttrId },
    /// `fused[a, b]` or `fused<metadata>[a, b]`
    Fused { metadata: Option<AttrId>, locs: Vec<AttrId> },
    /// An alias, `#loc3`, as the whole location.
    Alias(String),
}

// ---------------------------------------------------------------------------
// Operations

#[derive(Clone, Debug)]
pub struct Operation {
    pub name: NameId,
    pub operands: Vec<ValueId>,
    pub results: Vec<ValueId>,
    pub successors: Vec<BlockId>,
    /// `<{...}>`, a dictionary.
    pub properties: Option<AttrId>,
    pub regions: Vec<RegionId>,
    /// `{...}`, a dictionary.
    pub attrs: Option<AttrId>,
    /// The function type after `:`.
    pub ty: TypeId,
    pub loc: Option<AttrId>,
    /// The block holding this operation; `None` at the top level.
    pub parent: Option<BlockId>,
}

#[derive(Clone, Debug, Default)]
pub struct Region {
    pub blocks: Vec<BlockId>,
    /// The operation holding this region.
    pub parent: Option<OpId>,
}

#[derive(Clone, Debug)]
pub struct Block {
    /// `bb0` for `^bb0`; `None` for an entry block written without a label.
    pub name: Option<String>,
    pub args: Vec<ValueId>,
    pub ops: Vec<OpId>,
    pub parent: RegionId,
}

#[derive(Clone, Debug)]
pub struct Value {
    /// The name after `%`. For a result of an operation with several, the
    /// name of the group, as in `%0:2`.
    pub name: Option<String>,
    /// The result's number within its group, `#1` in `%0#1`, when the group
    /// has more than one.
    pub group_index: Option<u32>,
    pub ty: TypeId,
    pub def: ValueDef,
    /// A block argument's location, `^bb0(%a: i32 loc(...))`.
    pub loc: Option<AttrId>,
}

#[derive(Clone, Copy, PartialEq, Eq, Debug)]
pub enum ValueDef {
    Result {
        op: OpId,
        index: u32,
    },
    BlockArg {
        block: BlockId,
        index: u32,
    },
    /// Used before being defined. Only seen while parsing.
    Forward,
}

/// Something at the top level of a file, in the order written.
#[derive(Clone, Debug)]
pub enum Item {
    Op(OpId),
    /// `!name = type`
    TypeAlias {
        name: String,
        ty: TypeId,
    },
    /// `#name = attr`
    AttrAlias {
        name: String,
        attr: AttrId,
    },
    /// The text between `{-#` and `#-}`, such as `dialect_resources`, kept
    /// as written and shared between the modules passes make. It can hold a
    /// model's weights.
    Resources(std::sync::Arc<str>),
    /// A blob of `dialect_resources` a pass made, such as weights it
    /// transposed: its key, the alignment its data needs, and the data.
    Blob {
        key: String,
        align: u32,
        bytes: std::sync::Arc<Vec<u8>>,
    },
}

/// A parsed MLIR file.
#[derive(Clone, Debug, Default)]
pub struct Module {
    types: Interner<Type>,
    attrs: Interner<Attr>,
    names: Interner<String>,
    pub ops: Vec<Operation>,
    pub blocks: Vec<Block>,
    pub regions: Vec<Region>,
    pub values: Vec<Value>,
    pub items: Vec<Item>,
}

impl Module {
    pub fn intern_type(&mut self, ty: Type) -> TypeId {
        TypeId(self.types.intern(ty))
    }

    pub fn ty(&self, id: TypeId) -> &Type {
        &self.types.list[id.index()]
    }

    pub fn intern_attr(&mut self, attr: Attr) -> AttrId {
        AttrId(self.attrs.intern(attr))
    }

    pub fn attr(&self, id: AttrId) -> &Attr {
        &self.attrs.list[id.index()]
    }

    pub fn intern_name(&mut self, name: &str) -> NameId {
        if let Some(&id) = self.names.map.get(name) {
            return NameId(id);
        }
        NameId(self.names.intern(name.to_string()))
    }

    pub fn name(&self, id: NameId) -> &str {
        &self.names.list[id.index()]
    }

    /// An operation's name, such as `arith.addi`.
    pub fn op_name(&self, op: OpId) -> &str {
        self.name(self.ops[op.index()].name)
    }

    /// The operations at the top level, in order.
    pub fn top_ops(&self) -> impl Iterator<Item = OpId> + '_ {
        self.items.iter().filter_map(|i| match i {
            Item::Op(op) => Some(*op),
            _ => None,
        })
    }

    /// Every type interned so far.
    pub fn types(&self) -> impl Iterator<Item = (TypeId, &Type)> {
        self.types.list.iter().enumerate().map(|(i, t)| (TypeId(i as u32), t))
    }

    /// Every attribute interned so far.
    pub fn attrs(&self) -> impl Iterator<Item = (AttrId, &Attr)> {
        self.attrs.list.iter().enumerate().map(|(i, a)| (AttrId(i as u32), a))
    }

    /// The type an alias stands for, following aliases of aliases.
    pub fn resolve_type(&self, mut ty: TypeId) -> TypeId {
        for _ in 0..64 {
            let Type::Alias(name) = self.ty(ty) else { return ty };
            let found = self.items.iter().find_map(|i| match i {
                Item::TypeAlias { name: n, ty } if n == name => Some(*ty),
                _ => None,
            });
            match found {
                Some(t) => ty = t,
                None => return ty,
            }
        }
        ty
    }

    /// The attribute an alias stands for, following aliases of aliases.
    pub fn resolve_attr(&self, mut attr: AttrId) -> AttrId {
        for _ in 0..64 {
            let name = match self.attr(attr) {
                Attr::Alias(n) | Attr::Loc(Loc::Alias(n)) => n,
                _ => return attr,
            };
            let found = self.items.iter().find_map(|i| match i {
                Item::AttrAlias { name: n, attr } if n == name => Some(*attr),
                _ => None,
            });
            match found {
                Some(a) => attr = a,
                None => return attr,
            }
        }
        attr
    }

    /// The file's `dialect_resources` blobs and those passes made, by key:
    /// an index made once, as a model's weights can be a gigabyte of text.
    pub fn resources(&self) -> Resources<'_> {
        let mut map = HashMap::new();
        for item in &self.items {
            match item {
                Item::Blob { key, bytes, .. } => {
                    map.insert(key.as_str(), Blob::Bytes(&bytes[..]));
                }
                Item::Resources(text) => {
                    for line in text.lines() {
                        let line = line.trim().trim_end_matches(',');
                        let Some((k, value)) = line.split_once(':') else { continue };
                        if let Some(hex) = value.trim().strip_prefix("\"0x").and_then(|v| v.strip_suffix('"')) {
                            map.insert(k.trim().trim_matches('"'), Blob::Hex(hex));
                        }
                    }
                }
                _ => {}
            }
        }
        Resources { map }
    }

    /// The value of `key` in an operation's properties or attributes.
    pub fn op_attr(&self, op: OpId, key: &str) -> Option<AttrId> {
        let o = &self.ops[op.index()];
        [o.properties, o.attrs].into_iter().flatten().find_map(|d| match self.attr(d) {
            Attr::Dict(entries) => entries.iter().find(|(k, _)| k == key).map(|(_, v)| *v),
            _ => None,
        })
    }

    /// The operand types and result types of an operation.
    pub fn op_signature(&self, op: OpId) -> (&[TypeId], &[TypeId]) {
        match self.ty(self.ops[op.index()].ty) {
            Type::Function { inputs, results } => (inputs, results),
            _ => (&[], &[]),
        }
    }

    /// Calls `f` on every operation nested in `op`, `op` first, in order.
    pub fn walk(&self, op: OpId, f: &mut impl FnMut(OpId)) {
        f(op);
        for &r in &self.ops[op.index()].regions {
            for &b in &self.regions[r.index()].blocks {
                for &o in &self.blocks[b.index()].ops {
                    self.walk(o, f);
                }
            }
        }
    }
}

/// A module's `dialect_resources` blobs, by key (`Module::resources`).
pub struct Resources<'m> {
    map: HashMap<&'m str, Blob<'m>>,
}

enum Blob<'m> {
    /// As the file has it: hex, starting with the alignment word.
    Hex(&'m str),
    /// As a pass made it, without the alignment word.
    Bytes(&'m [u8]),
}

impl<'m> Resources<'m> {
    /// The data of blob `key`, without the alignment word it starts with.
    pub fn get(&self, key: &str) -> Option<std::borrow::Cow<'m, [u8]>> {
        match self.map.get(key)? {
            Blob::Bytes(b) => Some(std::borrow::Cow::Borrowed(b)),
            Blob::Hex(hex) => {
                let bytes: Option<Vec<u8>> =
                    (0..hex.len()).step_by(2).map(|i| u8::from_str_radix(hex.get(i..i + 2)?, 16).ok()).collect();
                Some(std::borrow::Cow::Owned(bytes?.get(4..)?.to_vec()))
            }
        }
    }

    pub fn contains(&self, key: &str) -> bool {
        self.map.contains_key(key)
    }
}
