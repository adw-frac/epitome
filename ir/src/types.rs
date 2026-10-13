//! Types and the per-module type table.
//!
//! Types are interned: two `TypeId`s are equal exactly when the types are the
//! same. Literal structs are interned by their members. Identified (named)
//! structs are interned by identity, so two names with the same body are
//! still different types.

use std::collections::HashMap;

/// A handle to an interned type.
#[derive(Clone, Copy, PartialEq, Eq, Hash, Debug, PartialOrd, Ord, Default)]
pub struct TypeId(pub u32);

#[derive(Clone, PartialEq, Eq, Hash, Debug)]
pub enum Type {
    Void,
    Label,
    Token,
    Metadata,
    X86Amx,
    /// `iN`
    Int(u32),
    /// `bN`
    Byte(u32),
    Half,
    BFloat,
    Float,
    Double,
    X86Fp80,
    Fp128,
    PpcFp128,
    /// `ptr addrspace(N)`
    Ptr(u32),
    Vector {
        scalable: bool,
        len: u32,
        elem: TypeId,
    },
    Array {
        len: u64,
        elem: TypeId,
    },
    /// A literal struct, `{ ... }` or `<{ ... }>`.
    Struct {
        packed: bool,
        fields: Vec<TypeId>,
    },
    /// An identified struct. The index is into `Types::structs`.
    Named(u32),
    Function {
        ret: TypeId,
        params: Vec<TypeId>,
        varargs: bool,
    },
    /// `target("name", types..., ints...)`
    TargetExt {
        name: Vec<u8>,
        types: Vec<TypeId>,
        ints: Vec<u32>,
    },
}

/// An identified struct. `name` is `None` for a numbered type such as `%0`.
#[derive(Clone, Debug)]
pub struct NamedStruct {
    pub name: Option<String>,
    /// `None` while opaque.
    pub body: Option<StructBody>,
}

#[derive(Clone, Debug, PartialEq, Eq)]
pub struct StructBody {
    pub packed: bool,
    pub fields: Vec<TypeId>,
}

#[derive(Clone, Debug, Default)]
pub struct Types {
    list: Vec<Type>,
    map: HashMap<Type, TypeId>,
    pub structs: Vec<NamedStruct>,
    struct_names: HashMap<String, u32>,
}

impl Types {
    pub fn intern(&mut self, ty: Type) -> TypeId {
        if let Some(&id) = self.map.get(&ty) {
            return id;
        }
        let id = TypeId(self.list.len() as u32);
        self.list.push(ty.clone());
        self.map.insert(ty, id);
        id
    }

    pub fn get(&self, id: TypeId) -> &Type {
        &self.list[id.0 as usize]
    }

    pub fn void(&mut self) -> TypeId {
        self.intern(Type::Void)
    }
    pub fn label(&mut self) -> TypeId {
        self.intern(Type::Label)
    }
    pub fn token(&mut self) -> TypeId {
        self.intern(Type::Token)
    }
    pub fn metadata(&mut self) -> TypeId {
        self.intern(Type::Metadata)
    }
    pub fn int(&mut self, bits: u32) -> TypeId {
        self.intern(Type::Int(bits))
    }
    pub fn ptr(&mut self, addrspace: u32) -> TypeId {
        self.intern(Type::Ptr(addrspace))
    }

    /// Finds or creates the identified struct with this name.
    pub fn named_struct(&mut self, name: &str) -> TypeId {
        let index = match self.struct_names.get(name) {
            Some(&i) => i,
            None => {
                let i = self.structs.len() as u32;
                self.structs.push(NamedStruct { name: Some(name.to_string()), body: None });
                self.struct_names.insert(name.to_string(), i);
                i
            }
        };
        self.intern(Type::Named(index))
    }

    /// Creates a new numbered identified struct, such as `%0 = type { ... }`.
    pub fn numbered_struct(&mut self, number: u32) -> TypeId {
        let key = number.to_string();
        let index = match self.struct_names.get(&key) {
            Some(&i) => i,
            None => {
                let i = self.structs.len() as u32;
                self.structs.push(NamedStruct { name: None, body: None });
                self.struct_names.insert(key, i);
                i
            }
        };
        self.intern(Type::Named(index))
    }

    pub fn is_int(&self, id: TypeId) -> bool {
        matches!(self.get(id), Type::Int(_))
    }

    pub fn is_float(&self, id: TypeId) -> bool {
        matches!(
            self.get(id),
            Type::Half | Type::BFloat | Type::Float | Type::Double | Type::X86Fp80 | Type::Fp128 | Type::PpcFp128
        )
    }

    pub fn is_ptr(&self, id: TypeId) -> bool {
        matches!(self.get(id), Type::Ptr(_))
    }

    /// The element type of a vector, or the type itself.
    pub fn scalar(&self, id: TypeId) -> TypeId {
        match self.get(id) {
            Type::Vector { elem, .. } => *elem,
            _ => id,
        }
    }

    /// The same shape of vector as `like`, with a new element type. Returns
    /// `elem` itself when `like` is not a vector.
    pub fn with_elem(&mut self, like: TypeId, elem: TypeId) -> TypeId {
        match *self.get(like) {
            Type::Vector { scalable, len, .. } => self.intern(Type::Vector { scalable, len, elem }),
            _ => elem,
        }
    }

    /// The type of member `index` of a struct, array or vector.
    pub fn member(&self, id: TypeId, index: u64) -> Option<TypeId> {
        match self.get(id) {
            Type::Struct { fields, .. } => fields.get(index as usize).copied(),
            Type::Named(i) => {
                let body = self.structs[*i as usize].body.as_ref()?;
                body.fields.get(index as usize).copied()
            }
            Type::Array { elem, .. } | Type::Vector { elem, .. } => Some(*elem),
            _ => None,
        }
    }

    /// True for types that can begin a value of struct type (literal or identified).
    pub fn is_struct(&self, id: TypeId) -> bool {
        matches!(self.get(id), Type::Struct { .. } | Type::Named(_))
    }

    pub fn len(&self) -> usize {
        self.list.len()
    }

    pub fn is_empty(&self) -> bool {
        self.list.is_empty()
    }
}
