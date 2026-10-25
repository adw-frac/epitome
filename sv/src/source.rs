//! Source text, and positions found from where a slice sits in it.
//!
//! Tokens and error spans are `&str` slices of a source's text. A slice's
//! byte offset is its pointer minus the text's pointer, so nothing needs
//! to store a position: line and column are worked out only when an error
//! is reported.

use std::fmt;

/// One piece of source text: a file, or text the preprocessor made.
pub struct Source {
    pub name: String,
    pub text: String,
}

impl Source {
    pub fn new(name: impl Into<String>, text: impl Into<String>) -> Self {
        Source { name: name.into(), text: text.into() }
    }

    /// Whether `s` is a slice of this source's text. The empty slice at
    /// the end counts.
    pub fn contains(&self, s: &str) -> bool {
        let start = self.text.as_ptr() as usize;
        let p = s.as_ptr() as usize;
        p >= start && p + s.len() <= start + self.text.len()
    }

    /// The byte offset of `s` within the text.
    pub fn offset_of(&self, s: &str) -> usize {
        assert!(self.contains(s), "slice is not part of {}", self.name);
        s.as_ptr() as usize - self.text.as_ptr() as usize
    }

    /// The 1-based line and column (in characters) where `s` starts.
    pub fn line_col(&self, s: &str) -> (usize, usize) {
        line_col(&self.text, self.offset_of(s))
    }

    /// `name:line:col` for `s`.
    pub fn locate(&self, s: &str) -> Location<'_> {
        let (line, col) = self.line_col(s);
        Location { name: &self.name, line, col }
    }

    /// The whole line holding `s`, without its newline.
    pub fn line_of(&self, s: &str) -> &str {
        let at = self.offset_of(s);
        let start = self.text[..at].rfind('\n').map_or(0, |i| i + 1);
        let end = self.text[at..].find('\n').map_or(self.text.len(), |i| at + i);
        self.text[start..end].trim_end_matches('\r')
    }
}

/// The 1-based line and column of byte `offset` in `text`. Columns count
/// characters, not bytes.
pub fn line_col(text: &str, offset: usize) -> (usize, usize) {
    let before = &text[..offset];
    let line = before.bytes().filter(|&b| b == b'\n').count() + 1;
    let col = before[before.rfind('\n').map_or(0, |i| i + 1)..].chars().count() + 1;
    (line, col)
}

/// A position for an error message.
#[derive(Clone, Copy, PartialEq, Eq, Debug)]
pub struct Location<'a> {
    pub name: &'a str,
    pub line: usize,
    pub col: usize,
}

impl fmt::Display for Location<'_> {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "{}:{}:{}", self.name, self.line, self.col)
    }
}

/// An error at a slice of some source.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct Error<'a> {
    pub at: &'a str,
    pub message: String,
}

impl<'a> Error<'a> {
    pub fn new(at: &'a str, message: impl Into<String>) -> Self {
        Error { at, message: message.into() }
    }

    /// `name:line:col: error: message`, then the line and a caret.
    pub fn render(&self, src: &Source) -> String {
        let loc = src.locate(self.at);
        let line = src.line_of(self.at);
        let caret: String = line.chars().take(loc.col - 1).map(|c| if c == '\t' { '\t' } else { ' ' }).collect();
        format!("{loc}: error: {}\n{line}\n{caret}^\n", self.message)
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn positions_from_pointers() {
        let src = Source::new("a.sv", "module m;\n  wire w;\nendmodule\n");
        let w = &src.text[17..18];
        assert_eq!(w, "w");
        assert_eq!(src.line_col(w), (2, 8));
        assert_eq!(src.locate(w).to_string(), "a.sv:2:8");
        assert_eq!(src.line_of(w), "  wire w;");
        let eof = &src.text[src.text.len()..];
        assert_eq!(src.line_col(eof), (4, 1));
        assert!(!src.contains("w"));
    }

    #[test]
    fn render_points_at_the_column() {
        let src = Source::new("a.sv", "x\n\tfoo bar\n");
        let e = Error::new(&src.text[7..10], "bad");
        assert_eq!(e.render(&src), "a.sv:2:6: error: bad\n\tfoo bar\n\t    ^\n");
    }
}
