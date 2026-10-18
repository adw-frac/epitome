//! Looking up attributes, including those reached through attribute groups.

use smaugian_ir::module::{Attr, Linkage, Module};

/// Every attribute in `list`, with `#N` groups expanded.
fn expanded<'a>(m: &'a Module, list: &'a [Attr]) -> impl Iterator<Item = &'a Attr> {
    list.iter().flat_map(move |a| match a {
        Attr::Group(n) => m.attr_groups.iter().filter(|g| g.id == *n).flat_map(|g| g.attrs.iter()).collect::<Vec<_>>(),
        a => vec![a],
    })
}

/// True if `list` has the keyword attribute `word`, such as `noinline`.
pub fn has(m: &Module, list: &[Attr], word: &str) -> bool {
    expanded(m, list).any(|a| matches!(a, Attr::Word(w) if w == word))
}

/// The value of a string attribute, such as `"target-cpu"="apple-m1"`.
pub fn string<'a>(m: &'a Module, list: &'a [Attr], key: &str) -> Option<&'a [u8]> {
    expanded(m, list).find_map(|a| match a {
        Attr::Str { key: k, value } if k == key.as_bytes() => Some(value.as_deref().unwrap_or(b"")),
        _ => None,
    })
}

/// True if `list` has an attribute with this name in any form, such as
/// `byval(%T)`, `inalloca(i8)` or `preallocated(i32)`.
pub fn has_named(m: &Module, list: &[Attr], name: &str) -> bool {
    expanded(m, list).any(|a| match a {
        Attr::Word(w) => w == name,
        Attr::Int { name: n, .. } | Attr::Type { name: n, .. } | Attr::Parens { name: n, .. } => n == name,
        _ => false,
    })
}

/// True if the definition in this module is the one that will run. A
/// `weak`, `linkonce`, `common` or `extern_weak` definition may be replaced
/// by another at link time, so its body must not be inlined or rewritten as
/// if it were final. The `_odr` forms promise every definition is the same.
pub fn definition_is_final(linkage: Linkage) -> bool {
    matches!(
        linkage,
        Linkage::External
            | Linkage::Internal
            | Linkage::Private
            | Linkage::LinkOnceOdr
            | Linkage::WeakOdr
            | Linkage::AvailableExternally
    )
}

/// The text inside an attribute's parentheses, such as `none` for
/// `memory(none)`.
pub fn paren_text<'a>(m: &'a Module, list: &'a [Attr], name: &str) -> Option<&'a str> {
    expanded(m, list).find_map(|a| match a {
        Attr::Parens { name: n, text } if n == name => Some(text.as_str()),
        _ => None,
    })
}
