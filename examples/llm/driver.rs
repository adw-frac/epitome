//! The program `examples/llm.rs` links a language model into: it turns a
//! prompt into tokens, runs the model compiled by Epitome to choose each
//! next token greedily, and prints the text as it goes.
//!
//! ```sh
//! target/smollm2/llm "Once upon a time, there was a little dog called"
//! target/smollm2/llm --ids "..."   # the token ids too
//! ```
//!
//! The model is one function, written by Epitome into `model.o`:
//!
//! ```text
//! forward(ids: *const i64 /* [1, WINDOW] */, logits: *mut f32 /* [1, WINDOW, VOCAB] */)
//! ```
//!
//! The tokenizer is GPT-2's byte-level BPE, from `tokens.txt` and
//! `merges.txt`, and the window, vocabulary and end token are in
//! `config.txt`, all next to the program (written by `export.py`).

use std::collections::HashMap;
use std::io::Write;
use std::time::Instant;

unsafe extern "C" {
    fn forward(ids: *const i64, logits: *mut f32);
}

fn main() {
    let mut args: Vec<String> = std::env::args().skip(1).collect();
    let show_ids = args.first().is_some_and(|a| a == "--ids");
    if show_ids {
        args.remove(0);
    }
    let prompt = if args.is_empty() { "Once upon a time".to_string() } else { args.join(" ") };
    let dir = std::env::current_exe().ok().and_then(|p| p.parent().map(|p| p.to_path_buf())).unwrap_or_default();
    let (bpe, config) = match Bpe::load(&dir).and_then(|b| Ok((b, Config::load(&dir)?))) {
        Ok(x) => x,
        Err(e) => {
            eprintln!("llm: {e}");
            std::process::exit(1);
        }
    };
    let Config { window: win, vocab, end } = config;

    let mut ids = bpe.encode(&prompt);
    if ids.len() >= win {
        eprintln!("llm: the prompt is {} tokens; the window is {win}", ids.len());
        std::process::exit(1);
    }
    let mut window = vec![0i64; win];
    for (w, &id) in window.iter_mut().zip(&ids) {
        *w = id as i64;
    }
    let mut logits = vec![0f32; win * vocab];

    let mut out = std::io::stdout().lock();
    out.write_all(prompt.as_bytes()).unwrap();
    out.flush().unwrap();
    let start = Instant::now();
    let first = ids.len();
    while ids.len() < win {
        // SAFETY: `window` and `logits` have the sizes `forward` was compiled for.
        unsafe { forward(window.as_ptr(), logits.as_mut_ptr()) };
        let t = ids.len() - 1;
        let row = &logits[t * vocab..(t + 1) * vocab];
        let next = argmax(row);
        if Some(next) == end {
            break;
        }
        window[ids.len()] = next as i64;
        ids.push(next);
        out.write_all(&bpe.tokens[next as usize]).unwrap();
        out.flush().unwrap();
    }
    writeln!(out).unwrap();
    let made = ids.len() - first;
    let secs = start.elapsed().as_secs_f64();
    eprintln!("({made} tokens in {secs:.2} s, {:.1} tokens/s)", made as f64 / secs);
    if show_ids {
        let list: Vec<String> = ids.iter().map(|i| i.to_string()).collect();
        println!("{}", list.join(" "));
    }
}

/// The window, vocabulary and end token the model was exported with.
struct Config {
    window: usize,
    vocab: usize,
    end: Option<u32>,
}

impl Config {
    fn load(dir: &std::path::Path) -> Result<Config, String> {
        let path = dir.join("config.txt");
        let text = std::fs::read_to_string(&path).map_err(|e| format!("{}: {e}", path.display()))?;
        let get = |key: &str| -> Result<i64, String> {
            text.lines()
                .find_map(|l| l.strip_prefix(key).and_then(|v| v.trim().parse().ok()))
                .ok_or_else(|| format!("{}: no {key}", path.display()))
        };
        Ok(Config {
            window: get("window ")? as usize,
            vocab: get("vocab ")? as usize,
            end: u32::try_from(get("end ")?).ok(),
        })
    }
}

/// The first index of the largest value, as PyTorch's `argmax` picks.
fn argmax(row: &[f32]) -> u32 {
    let mut best = 0;
    for (i, &v) in row.iter().enumerate() {
        if v > row[best] {
            best = i;
        }
    }
    best as u32
}

/// GPT-2's byte-level BPE: a token is a string of bytes, and a word starts
/// as its bytes, then the pair of neighbours that comes first in the
/// merges is joined, again and again.
struct Bpe {
    tokens: Vec<Vec<u8>>,
    ids: HashMap<Vec<u8>, u32>,
    ranks: HashMap<(Vec<u8>, Vec<u8>), usize>,
}

impl Bpe {
    fn load(dir: &std::path::Path) -> Result<Bpe, String> {
        let read = |name: &str| {
            std::fs::read_to_string(dir.join(name)).map_err(|e| format!("{}: {e}", dir.join(name).display()))
        };
        let tokens: Vec<Vec<u8>> = read("tokens.txt")?.lines().map(unhex).collect::<Result<_, _>>()?;
        let ids = tokens.iter().enumerate().map(|(i, t)| (t.clone(), i as u32)).collect();
        let mut ranks = HashMap::new();
        for (rank, line) in read("merges.txt")?.lines().enumerate() {
            let (a, b) = line.split_once(' ').ok_or_else(|| format!("merges.txt: line {} is not two tokens", rank + 1))?;
            ranks.insert((unhex(a)?, unhex(b)?), rank);
        }
        Ok(Bpe { tokens, ids, ranks })
    }

    fn encode(&self, text: &str) -> Vec<u32> {
        let mut out = Vec::new();
        for word in pretokenize(text) {
            let mut parts: Vec<Vec<u8>> = word.bytes().map(|b| vec![b]).collect();
            loop {
                // The pair of neighbours merged first, if any.
                let best = (0..parts.len().saturating_sub(1))
                    .filter_map(|i| self.ranks.get(&(parts[i].clone(), parts[i + 1].clone())).map(|&r| (r, i)))
                    .min();
                let Some((_, i)) = best else { break };
                let (a, b) = (parts[i].clone(), parts[i + 1].clone());
                // Join every occurrence of the pair, left to right.
                let mut joined = Vec::with_capacity(parts.len());
                let mut k = 0;
                while k < parts.len() {
                    if k + 1 < parts.len() && parts[k] == a && parts[k + 1] == b {
                        joined.push([a.as_slice(), b.as_slice()].concat());
                        k += 2;
                    } else {
                        joined.push(parts[k].clone());
                        k += 1;
                    }
                }
                parts = joined;
            }
            out.extend(parts.iter().map(|p| self.ids[p]));
        }
        out
    }
}

fn unhex(s: &str) -> Result<Vec<u8>, String> {
    (0..s.len())
        .step_by(2)
        .map(|i| u8::from_str_radix(s.get(i..i + 2).unwrap_or(""), 16).map_err(|_| format!("'{s}' is not hex")))
        .collect()
}

/// Splits text into words as GPT-2's pattern does:
/// `'s|'t|'re|'ve|'m|'ll|'d| ?\p{L}+| ?\p{N}+| ?[^\s\p{L}\p{N}]+|\s+(?!\S)|\s+`.
fn pretokenize(text: &str) -> Vec<&str> {
    let chars: Vec<(usize, char)> = text.char_indices().collect();
    let at = |i: usize| chars.get(i).map(|c| c.1);
    let offset = |i: usize| chars.get(i).map_or(text.len(), |c| c.0);
    let class = |c: char| {
        if c.is_alphabetic() {
            1
        } else if c.is_numeric() {
            2
        } else if c.is_whitespace() {
            3
        } else {
            4
        }
    };
    let mut words = Vec::new();
    let mut i = 0;
    while i < chars.len() {
        let c = chars[i].1;
        // Contractions.
        if c == '\'' {
            let rest = &text[offset(i) + 1..];
            if let Some(s) = ["s", "t", "re", "ve", "m", "ll", "d"].iter().find(|s| rest.starts_with(**s)) {
                words.push(&text[offset(i)..offset(i) + 1 + s.len()]);
                i += 1 + s.len();
                continue;
            }
        }
        // A word, number or run of other characters, with one space before.
        let start = i;
        let lead = c == ' ' && at(i + 1).is_some_and(|n| class(n) != 3);
        let j = if lead { i + 1 } else { i };
        if let Some(k) = at(j).map(class).filter(|&k| k != 3) {
            let mut e = j + 1;
            while at(e).is_some_and(|n| class(n) == k) {
                e += 1;
            }
            words.push(&text[offset(start)..offset(e)]);
            i = e;
            continue;
        }
        // Whitespace: all but the last before a word, which goes with it.
        let mut e = i + 1;
        while at(e).is_some_and(|n| class(n) == 3) {
            e += 1;
        }
        if e < chars.len() && e - i > 1 {
            e -= 1;
        }
        words.push(&text[offset(start)..offset(e)]);
        i = e;
    }
    words
}
