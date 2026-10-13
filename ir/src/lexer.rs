//! The lexer for IR text.
//!
//! A token is just a slice of the source text. Its kind is worked out from
//! its first characters when needed, and its position from where the slice
//! sits in the source.

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

    /// `%name`, `%"name"` or `%12`.
    pub fn is_local(self) -> bool {
        self.0.starts_with('%')
    }

    /// `@name`, `@"name"` or `@12`.
    pub fn is_global(self) -> bool {
        self.0.starts_with('@')
    }

    /// `$name` or `$"name"`.
    pub fn is_comdat(self) -> bool {
        self.0.starts_with('$')
    }

    /// `#12`.
    pub fn is_attr_group(self) -> bool {
        self.0.len() > 1 && self.0.starts_with('#') && self.0.as_bytes()[1].is_ascii_digit()
    }

    /// `!name` or `!12`, but not a lone `!`.
    pub fn is_metadata_name(self) -> bool {
        self.0.len() > 1 && self.0.starts_with('!')
    }

    /// `"..."`
    pub fn is_string(self) -> bool {
        self.0.starts_with('"')
    }

    /// A label definition such as `entry:`, `12:` or `"a b":`.
    pub fn is_label(self) -> bool {
        self.0.len() > 1 && self.0.ends_with(':') && !self.is_string_unterminated()
    }

    fn is_string_unterminated(self) -> bool {
        self.0.starts_with('"') && !self.0.ends_with("\":")
    }

    /// A bare word: a keyword, type name or attribute name.
    pub fn is_word(self) -> bool {
        let Some(c) = self.0.chars().next() else { return false };
        (c.is_ascii_alphabetic() || c == '_' || c == '.') && !self.0.ends_with(':')
    }

    /// A decimal integer, possibly negative.
    pub fn is_int(self) -> bool {
        let digits = self.0.strip_prefix('-').unwrap_or(self.0);
        !digits.is_empty() && digits.bytes().all(|b| b.is_ascii_digit())
    }

    /// Any numeric literal: integers, decimal and hex floats, `u0x`/`s0x`,
    /// `f0x`, and the signed `inf`/`nan` forms.
    pub fn is_number(self) -> bool {
        let t = self.0;
        let b = t.as_bytes();
        match b.first() {
            Some(b'0'..=b'9') => true,
            Some(b'-' | b'+') => b.len() > 1 && (b[1].is_ascii_digit() || b[1].is_ascii_alphabetic()),
            Some(b'u' | b's' | b'f') => t.len() > 3 && t[1..].starts_with("0x"),
            _ => false,
        }
    }

    /// The name part of a sigil token, with quotes and escapes removed. For
    /// `%foo` this is `foo`; for `%"a\22b"` it is `a"b`.
    pub fn name_bytes(self) -> Vec<u8> {
        let body = &self.0[1..];
        if body.starts_with('"') { unescape(&body[1..body.len() - 1]) } else { unescape(body) }
    }

    /// The contents of a string token, with escapes decoded.
    pub fn string_bytes(self) -> Vec<u8> {
        let t = self.0.strip_prefix('c').unwrap_or(self.0);
        unescape(&t[1..t.len().saturating_sub(1).max(1)])
    }
}

/// Decodes `\\` and `\xx` escapes.
pub fn unescape(s: &str) -> Vec<u8> {
    let b = s.as_bytes();
    let mut out = Vec::with_capacity(b.len());
    let mut i = 0;
    while i < b.len() {
        if b[i] == b'\\' {
            if b.get(i + 1) == Some(&b'\\') {
                out.push(b'\\');
                i += 2;
                continue;
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

/// The byte offset of `token` within `src`.
///
/// Every token is a subslice of the source (the end-of-file token is the
/// empty slice at its end), so the offset is the difference of the two
/// start pointers.
pub fn offset_of(src: &str, token: &str) -> usize {
    let start = src.as_ptr();
    let end = src.as_ptr().wrapping_add(src.len());
    assert!(token.as_ptr() >= start && token.as_ptr() <= end, "token is not part of the source");
    // SAFETY: the assert above shows both pointers are in, or one past the
    // end of, the same allocation.
    unsafe { token.as_ptr().offset_from(start) as usize }
}

/// The 1-based line and column of byte `offset` in `src`.
pub fn line_col(src: &str, offset: usize) -> (usize, usize) {
    let before = &src[..offset];
    let line = before.bytes().filter(|&b| b == b'\n').count() + 1;
    let col = before.len() - before.rfind('\n').map_or(0, |i| i + 1) + 1;
    (line, col)
}

/// Splits `src` into tokens. Comments and whitespace are dropped. The last
/// token is always the empty end-of-file token.
pub fn tokenize(src: &str) -> Vec<Token<'_>> {
    let b = src.as_bytes();
    let mut toks = Vec::new();
    let mut i = 0;
    while i < b.len() {
        let c = b[i];
        if c.is_ascii_whitespace() {
            i += 1;
            continue;
        }
        if c == b';' {
            while i < b.len() && b[i] != b'\n' {
                i += 1;
            }
            continue;
        }
        if c == b'/' && b.get(i + 1) == Some(&b'*') {
            i += 2;
            while i < b.len() && !(b[i] == b'*' && b.get(i + 1) == Some(&b'/')) {
                i += 1;
            }
            i = (i + 2).min(b.len());
            continue;
        }
        let start = i;
        i = match c {
            b'"' => string_end(b, i),
            b'c' if b.get(i + 1) == Some(&b'"') => string_end(b, i + 1),
            b'%' | b'@' | b'$' | b'!' | b'#' | b'^' => {
                let j = i + 1;
                if b.get(j) == Some(&b'"') && c != b'!' { string_end(b, j) } else { word_end(b, j) }
            }
            b'-' | b'+' if b.get(i + 1).is_some_and(|&n| n.is_ascii_digit() || n.is_ascii_alphabetic()) => {
                number_end(b, i + 1)
            }
            b'0'..=b'9' => number_end(b, i),
            _ if is_word_char(c) => word_end(b, i),
            _ => i + 1,
        };
        // A label: a word, number or quoted name directly followed by `:`.
        let first = b[start];
        if i < b.len()
            && b[i] == b':'
            && i > start
            && (is_word_char(first) || first == b'"')
            && !matches!(first, b'%' | b'@' | b'$' | b'!' | b'#')
        {
            i += 1;
        }
        toks.push(Token(&src[start..i]));
    }
    toks.push(Token(&src[src.len()..]));
    toks
}

fn is_word_char(c: u8) -> bool {
    c.is_ascii_alphanumeric() || matches!(c, b'-' | b'$' | b'.' | b'_' | b'\\')
}

fn word_end(b: &[u8], mut i: usize) -> usize {
    while i < b.len() && is_word_char(b[i]) {
        i += 1;
    }
    i
}

/// The end of a string starting at the quote at `i`. Strings end at the
/// next quote; there is no escaped quote.
fn string_end(b: &[u8], i: usize) -> usize {
    match b[i + 1..].iter().position(|&c| c == b'"') {
        Some(p) => i + 1 + p + 1,
        None => b.len(),
    }
}

/// Numbers: digits, `.`, exponents, hex digits and the forms `nan(0x1)`.
fn number_end(b: &[u8], mut i: usize) -> usize {
    while i < b.len() {
        let c = b[i];
        let exponent_sign = (c == b'+' || c == b'-') && matches!(b[i - 1], b'e' | b'E' | b'p' | b'P');
        if c.is_ascii_alphanumeric() || c == b'.' || c == b'_' || exponent_sign {
            i += 1;
        } else if c == b'(' && b[..i].ends_with(b"nan") {
            while i < b.len() && b[i] != b')' {
                i += 1;
            }
            i = (i + 1).min(b.len());
        } else {
            break;
        }
    }
    i
}

#[cfg(test)]
mod tests {
    use super::*;

    fn lex(s: &str) -> Vec<&str> {
        tokenize(s).into_iter().map(|t| t.0).filter(|t| !t.is_empty()).collect()
    }

    #[test]
    fn basic() {
        assert_eq!(
            lex("%x = add nsw i32 %a, -4 ; comment\n  ret i32 %x"),
            ["%x", "=", "add", "nsw", "i32", "%a", ",", "-4", "ret", "i32", "%x"]
        );
    }

    #[test]
    fn labels_and_names() {
        assert_eq!(lex("entry:\n7:\n\"a b\":"), ["entry:", "7:", "\"a b\":"]);
        assert_eq!(lex("@\"??_R0H@8\" %\"class.std::x\""), ["@\"??_R0H@8\"", "%\"class.std::x\""]);
        assert_eq!(lex("memory(argmem: read)"), ["memory", "(", "argmem:", "read", ")"]);
    }

    #[test]
    fn numbers() {
        assert_eq!(
            lex("1.000000e+00 -2.5e-3 0xK3FFF8000 +inf -nan(0x1) u0x80 1e300"),
            ["1.000000e+00", "-2.5e-3", "0xK3FFF8000", "+inf", "-nan(0x1)", "u0x80", "1e300"]
        );
    }

    #[test]
    fn metadata_and_strings() {
        assert_eq!(
            lex("!0 = !{!\"a\\22\", c\"hi\\00\", !DIExpression(DW_OP_deref)}"),
            [
                "!0",
                "=",
                "!",
                "{",
                "!",
                "\"a\\22\"",
                ",",
                "c\"hi\\00\"",
                ",",
                "!DIExpression",
                "(",
                "DW_OP_deref",
                ")",
                "}"
            ]
        );
        assert_eq!(lex("#dbg_value(i32 %0) #0"), ["#dbg_value", "(", "i32", "%0", ")", "#0"]);
        assert_eq!(lex("<{ i8 }> ..."), ["<", "{", "i8", "}", ">", "..."]);
    }

    #[test]
    fn positions() {
        let src = "a\n  bc";
        let toks = tokenize(src);
        let off = offset_of(src, toks[1].0);
        assert_eq!(off, 4);
        assert_eq!(line_col(src, off), (2, 3));
        assert_eq!(offset_of(src, toks.last().unwrap().0), src.len());
    }
}
