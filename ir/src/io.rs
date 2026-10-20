//! Files named on the command line, where `-` is the standard stream, as
//! `clang` and `llc` read it: standard input for a file read, standard
//! output for one written.

use std::io::{Read, Write};

/// The text of `path`, or of standard input for `-`.
pub fn read_to_string(path: &str) -> std::io::Result<String> {
    if path == "-" {
        let mut s = String::new();
        std::io::stdin().read_to_string(&mut s)?;
        return Ok(s);
    }
    std::fs::read_to_string(path)
}

/// Writes `bytes` to `path`, or to standard output for `-`.
pub fn write(path: &str, bytes: impl AsRef<[u8]>) -> std::io::Result<()> {
    if path == "-" {
        let mut out = std::io::stdout().lock();
        out.write_all(bytes.as_ref())?;
        return out.flush();
    }
    std::fs::write(path, bytes)
}

#[cfg(test)]
mod tests {
    #[test]
    fn a_named_file_is_a_file() {
        let dir = std::env::temp_dir().join(format!("epitome-io-{}", std::process::id()));
        std::fs::create_dir_all(&dir).unwrap();
        let p = dir.join("x.txt");
        let p = p.to_str().unwrap();
        super::write(p, "abc").unwrap();
        assert_eq!(super::read_to_string(p).unwrap(), "abc");
        std::fs::remove_dir_all(&dir).unwrap();
    }
}
