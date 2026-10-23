//! The lexer for MLIR text.
//!
//! As in `epitome_ir`'s lexer, a token is just a slice of the source, its
//! kind worked out from its first characters when needed, and its position
//! from where the slice sits in the source.
//!
//! Unlike LLVM IR, MLIR cannot be split into tokens once, up front: how
//! the text divides depends on where the parser is. `4x8xf32` in a shape
//! is a dimension, an `x` and the rest, and the body of a dialect type such
//! as `!llvm.func<void (ptr)>` is text for the dialect, not tokens. So
//! tokens are made on demand, from a byte offset, and the parser can read
//! characters directly where the grammar needs it.

/// A token: a slice of the source.
#[derive(Clone, Copy, PartialEq, Eq, Debug)]
pub struct Token<'a>(pub &'a str);

impl<'a> Token<'a> {
    pub fn text(self) -> &'a str {
        self.0
    }

    pub fn is_eof(self) -> bool {
        self.0.is_empty()
    }

    /// `%name` or `%12`.
    pub fn is_value(self) -> bool {
        self.0.len() > 1 && self.0.starts_with('%')
    }

    /// `@name` or `@"name"`.
    pub fn is_symbol(self) -> bool {
        self.0.len() > 1 && self.0.starts_with('@')
    }

    /// `^bb0`.
    pub fn is_block(self) -> bool {
        self.0.len() > 1 && self.0.starts_with('^')
    }

    /// `!name` or `!dialect.name`: a type alias or a dialect type.
    pub fn is_type_id(self) -> bool {
        self.0.len() > 1 && self.0.starts_with('!')
    }

    /// `#name` or `#dialect.name`: an attribute alias or a dialect attribute.
    pub fn is_attr_id(self) -> bool {
        self.0.len() > 1 && self.0.starts_with('#') && self.0 != "#-}"
    }

    /// `"..."`
    pub fn is_string(self) -> bool {
        self.0.starts_with('"')
    }

    /// A bare identifier: a keyword, a type name or an attribute name.
    pub fn is_bare(self) -> bool {
        self.0.bytes().next().is_some_and(|c| c.is_ascii_alphabetic() || c == b'_')
    }

    /// An integer or float literal, without a sign.
    pub fn is_number(self) -> bool {
        self.0.bytes().next().is_some_and(|c| c.is_ascii_digit())
    }

    /// The name after the sigil of `%x`, `@x`, `^x`, `!x` or `#x`, with a
    /// quoted symbol's quotes and escapes removed.
    pub fn name(self) -> String {
        let body = &self.0[1..];
        if body.starts_with('"') {
            String::from_utf8_lossy(&unescape(&body[1..body.len().saturating_sub(1).max(1)])).into_owned()
        } else {
            body.to_string()
        }
    }

    /// The contents of a string token, with escapes decoded.
    pub fn string_bytes(self) -> Vec<u8> {
        unescape(&self.0[1..self.0.len().saturating_sub(1).max(1)])
    }
}

/// Decodes MLIR's string escapes: `\"`, `\\`, `\n`, `\t` and `\xx`.
pub fn unescape(s: &str) -> Vec<u8> {
    let b = s.as_bytes();
    let mut out = Vec::with_capacity(b.len());
    let mut i = 0;
    while i < b.len() {
        if b[i] == b'\\' && i + 1 < b.len() {
            match b[i + 1] {
                b'"' | b'\\' => {
                    out.push(b[i + 1]);
                    i += 2;
                    continue;
                }
                b'n' => {
                    out.push(b'\n');
                    i += 2;
                    continue;
                }
                b't' => {
                    out.push(b'\t');
                    i += 2;
                    continue;
                }
                _ => {}
            }
            if let (Some(&h), Some(&l)) = (b.get(i + 1), b.get(i + 2))
                && let (Some(h), Some(l)) = ((h as char).to_digit(16), (l as char).to_digit(16))
            {
                out.push((h * 16 + l) as u8);
                i += 3;
                continue;
            }
        }
        out.push(b[i]);
        i += 1;
    }
    out
}

/// Characters of a bare identifier after the first.
pub fn is_bare_char(c: u8) -> bool {
    c.is_ascii_alphanumeric() || matches!(c, b'_' | b'$' | b'.')
}

/// Characters of a `%`, `^`, `!` or `#` name: a bare identifier's, and `-`.
fn is_suffix_char(c: u8) -> bool {
    is_bare_char(c) || c == b'-'
}

/// The offset of the first character at or after `i` that is not
/// whitespace or inside a `//` comment.
pub fn skip_trivia(b: &[u8], mut i: usize) -> usize {
    loop {
        while i < b.len() && b[i].is_ascii_whitespace() {
            i += 1;
        }
        if b[i..].starts_with(b"//") {
            while i < b.len() && b[i] != b'\n' {
                i += 1;
            }
            continue;
        }
        return i;
    }
}

/// The token starting at `start`, which must not be whitespace. At the end
/// of the source it is the empty slice there.
pub fn token_at(src: &str, start: usize) -> Token<'_> {
    let b = src.as_bytes();
    let Some(&c) = b.get(start) else { return Token(&src[src.len()..]) };
    let end = match c {
        b'"' => string_end(b, start),
        b'@' if b.get(start + 1) == Some(&b'"') => string_end(b, start + 1),
        b'%' | b'@' | b'^' | b'!' | b'#' => {
            if c == b'#' && b[start..].starts_with(b"#-}") {
                start + 3
            } else {
                let mut i = start + 1;
                while i < b.len() && is_suffix_char(b[i]) {
                    i += 1;
                }
                i
            }
        }
        b'0'..=b'9' => number_end(b, start),
        b'-' if b.get(start + 1) == Some(&b'>') => start + 2,
        b':' if b.get(start + 1) == Some(&b':') => start + 2,
        b'{' if b[start..].starts_with(b"{-#") => start + 3,
        _ if c.is_ascii_alphabetic() || c == b'_' => {
            let mut i = start + 1;
            while i < b.len() && is_bare_char(b[i]) {
                i += 1;
            }
            i
        }
        _ => start + 1,
    };
    Token(&src[start..end])
}

/// The end of a string starting at the quote at `i`. A backslash escapes
/// the next character.
pub fn string_end(b: &[u8], i: usize) -> usize {
    let mut j = i + 1;
    while j < b.len() {
        match b[j] {
            b'\\' => j += 2,
            b'"' => return j + 1,
            _ => j += 1,
        }
    }
    b.len()
}

/// Integers (`12`, `0x1F`) and floats (`1.5`, `2.0e-3`). A number stops
/// before an `x` that is not part of a hex prefix, so that `4x8` in a shape
/// is `4` then `x8`.
fn number_end(b: &[u8], start: usize) -> usize {
    let mut i = start;
    if b[i] == b'0' && b.get(i + 1) == Some(&b'x') && b.get(i + 2).is_some_and(|c| c.is_ascii_hexdigit()) {
        i += 2;
        while i < b.len() && b[i].is_ascii_hexdigit() {
            i += 1;
        }
        return i;
    }
    while i < b.len() && b[i].is_ascii_digit() {
        i += 1;
    }
    if b.get(i) == Some(&b'.') {
        i += 1;
        while i < b.len() && b[i].is_ascii_digit() {
            i += 1;
        }
        if matches!(b.get(i), Some(b'e' | b'E')) {
            let mut j = i + 1;
            if matches!(b.get(j), Some(b'+' | b'-')) {
                j += 1;
            }
            if b.get(j).is_some_and(|c| c.is_ascii_digit()) {
                i = j;
                while i < b.len() && b[i].is_ascii_digit() {
                    i += 1;
                }
            }
        }
    }
    i
}

/// The end of the bracketed text starting at the opening `<`, `(`, `[` or
/// `{` at `start`: the offset just past its matching close. Strings are
/// skipped whole, `->` is not a bracket, and a `>` that does not close a
/// `<` (as in `>=` inside parentheses) is ignored. `None` if it is never
/// closed.
pub fn balanced_end(b: &[u8], start: usize) -> Option<usize> {
    let mut stack: Vec<u8> = Vec::new();
    let mut i = start;
    while i < b.len() {
        match b[i] {
            b'"' => {
                i = string_end(b, i);
                continue;
            }
            b'-' if b.get(i + 1) == Some(&b'>') => {
                i += 2;
                continue;
            }
            c @ (b'<' | b'(' | b'[' | b'{') => stack.push(c),
            c @ (b'>' | b')' | b']' | b'}') => {
                let open = match c {
                    b'>' => b'<',
                    b')' => b'(',
                    b']' => b'[',
                    _ => b'{',
                };
                if stack.last() == Some(&open) {
                    stack.pop();
                    if stack.is_empty() {
                        return Some(i + 1);
                    }
                } else if c != b'>' {
                    return None;
                }
            }
            _ => {}
        }
        i += 1;
    }
    None
}

#[cfg(test)]
mod tests {
    use super::*;

    fn lex(s: &str) -> Vec<&str> {
        let mut out = Vec::new();
        let mut i = 0;
        loop {
            i = skip_trivia(s.as_bytes(), i);
            let t = token_at(s, i);
            if t.is_eof() {
                return out;
            }
            out.push(t.0);
            i += t.0.len();
        }
    }

    #[test]
    fn basic() {
        assert_eq!(
            lex("%0:2 = \"foo.bar\"(%a, %b#1) : (i32, f32) -> i8 // comment\n"),
            [
                "%0",
                ":",
                "2",
                "=",
                "\"foo.bar\"",
                "(",
                "%a",
                ",",
                "%b",
                "#1",
                ")",
                ":",
                "(",
                "i32",
                ",",
                "f32",
                ")",
                "->",
                "i8"
            ]
        );
    }

    #[test]
    fn names_and_numbers() {
        assert_eq!(
            lex("^bb0 @\"a b\" @f::@g !llvm.ptr #loc12"),
            ["^bb0", "@\"a b\"", "@f", "::", "@g", "!llvm.ptr", "#loc12"]
        );
        assert_eq!(lex("4x8xf32 0x1F 1.5e-3 2.0"), ["4", "x8xf32", "0x1F", "1.5e-3", "2.0"]);
        assert_eq!(lex("{-# a #-}"), ["{-#", "a", "#-}"]);
        assert_eq!(lex("\"a\\\"b\""), ["\"a\\\"b\""]);
    }

    #[test]
    fn brackets() {
        let s = "<void (ptr)> x";
        assert_eq!(balanced_end(s.as_bytes(), 0), Some(12));
        let s = "<(d0) -> (d0)> x";
        assert_eq!(balanced_end(s.as_bytes(), 0), Some(14));
        let s = "<(d0) : (d0 - 1 >= 0)>";
        assert_eq!(balanced_end(s.as_bytes(), 0), Some(s.len()));
        let s = "<\">\">";
        assert_eq!(balanced_end(s.as_bytes(), 0), Some(s.len()));
        assert_eq!(balanced_end(b"<(>", 0), None);
    }

    #[test]
    fn escapes() {
        assert_eq!(unescape("a\\\"b\\\\c\\0Ad"), b"a\"b\\c\nd");
    }
}
