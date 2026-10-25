//! The program `examples/llm.rs` links a language model into: it turns a
//! prompt into tokens, runs the model compiled by Epitome to choose each
//! next token greedily, and prints the text as it goes.
//!
//! ```sh
//! target/smollm2/llm "Once upon a time, there was a little dog called"
//! target/smollm2/llm --ids "..."   # the token ids too
//! target/smollm2/llm --bench 10     # forward passes for 10 s, timed
//! EPITOME_PROFILE=1 target/smollm2/llm --bench 10   # and each task's time
//! target/smollm2/llm --score "6403 1980 ... | 8728 ..."   # how well it predicts the ids after |
//! target/smollm2/llm --score-text "Some text."            # and text's tokens after the first
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
//!
//! The model's work is split among threads: it calls
//! `__epitome_parallel_for`, which this program provides, with a pool of
//! threads made the first time, one a core (at most 16), or
//! `EPITOME_THREADS` of them (1: none but the caller).

use std::collections::HashMap;
use std::io::Write;
use std::sync::OnceLock;
use std::time::Instant;

unsafe extern "C" {
    fn forward(ids: *const i64, logits: *mut f32);
}

/// For the model: calls `task(context, i)` for each `i` in `0..chunks`,
/// on the pool's threads and this one, and returns when all are done.
///
/// # Safety
///
/// `task` must be safe to call with `context` and each chunk, from any
/// thread, the chunks at once.
#[unsafe(no_mangle)]
pub unsafe extern "C" fn __epitome_parallel_for(task: extern "C" fn(*mut u8, i64), context: *mut u8, chunks: i64) {
    if !profiling() {
        return pool::run(task, context, chunks);
    }
    let start = Instant::now();
    pool::run(task, context, chunks);
    let secs = start.elapsed().as_secs_f64();
    let mut times = TIMES.lock().unwrap();
    match times.iter_mut().find(|t| t.0 == task as usize) {
        Some(t) => {
            t.1 += 1;
            t.2 += secs;
        }
        None => times.push((task as usize, 1, secs, chunks)),
    }
}

/// Whether to time each task (`EPITOME_PROFILE` set), for `--bench` to
/// print: each task's calls, chunks and time.
fn profiling() -> bool {
    static ON: OnceLock<bool> = OnceLock::new();
    *ON.get_or_init(|| std::env::var_os("EPITOME_PROFILE").is_some())
}

/// Each task's address, calls, time and chunks.
static TIMES: std::sync::Mutex<Vec<(usize, u64, f64, i64)>> = std::sync::Mutex::new(Vec::new());

/// The tasks' times, most first, for each forward pass of `passes`: by
/// their addresses' distance from `__epitome_weights` (for `nm` to name).
fn print_times(passes: u64, ms: f64) {
    let mut times = TIMES.lock().unwrap().clone();
    times.sort_by(|a, b| b.2.total_cmp(&a.2));
    let base = __epitome_weights as usize as i64;
    let all: f64 = times.iter().map(|t| t.2).sum::<f64>() * 1e3 / passes as f64;
    println!("{all:.2} ms of {ms:.2} in {} tasks; the rest on one thread", times.len());
    for &(task, calls, secs, chunks) in &times {
        let each = secs * 1e3 / passes as f64;
        println!("{:+#x} {chunks:4} chunks {:3} calls {each:8.3} ms", task as i64 - base, calls / passes);
    }
}

/// For the model: where its weights are, if they are in a file of their
/// own (`weights.bin`, beside the program, for `llm`; `weights-bf16.bin`
/// for `llm-bf16`), loaded the first time, at a multiple of 64 bytes.
#[unsafe(no_mangle)]
pub extern "C" fn __epitome_weights() -> *const u8 {
    static WEIGHTS: OnceLock<usize> = OnceLock::new();
    *WEIGHTS.get_or_init(|| {
        let exe = std::env::current_exe().unwrap_or_default();
        let name = exe.file_name().and_then(|n| n.to_str()).unwrap_or("llm");
        let file = exe.with_file_name(format!("weights{}.bin", name.strip_prefix("llm").unwrap_or("")));
        let mut f = std::fs::File::open(&file).unwrap_or_else(|e| {
            eprintln!("llm: {}: {e}", file.display());
            std::process::exit(1)
        });
        let n = f.metadata().map(|m| m.len() as usize).unwrap_or(0);
        let layout = std::alloc::Layout::from_size_align(n.max(64), 64).unwrap();
        let p = unsafe { std::alloc::alloc(layout) };
        let bytes = unsafe { std::slice::from_raw_parts_mut(p, n) };
        use std::io::Read;
        f.read_exact(bytes).unwrap_or_else(|e| {
            eprintln!("llm: {}: {e}", file.display());
            std::process::exit(1)
        });
        p as usize
    }) as *const u8
}

/// Threads made once. Each job's chunks are shared out in fixed blocks:
/// of `chunks` among `threads`, thread `t` (the caller is thread 0) does
/// chunks `t * chunks / threads` up to `(t + 1) * chunks / threads`. So a
/// thread does the same part of each job split the same way, and works on
/// the same memory from one operation to the next, as it would where each
/// processor had memory of its own. Between jobs a thread waits by
/// spinning for a while (the model's operations come microseconds apart),
/// then by sleeping until the next.
///
/// A job is in one of a ring of slots, with its number; a thread claims
/// each chunk before doing it, in a word that also holds the job's number,
/// so a thread that comes late to a job (asleep, or not running) claims
/// nothing of a later one. The caller does what is still unclaimed of the
/// job after waiting a while, so that it never waits long for a thread the
/// system is not running.
mod pool {
    use std::sync::atomic::{AtomicI64, AtomicU64, AtomicUsize, Ordering::SeqCst};
    use std::sync::{Condvar, Mutex, OnceLock};
    use std::time::{Duration, Instant};

    /// Chunks a job can have: 32 to a claim word.
    const MOST: i64 = 128;
    const SLOTS: usize = 64;

    #[derive(Default)]
    struct Slot {
        /// The job's number, 0 while it is being written.
        job: AtomicU64,
        task: AtomicUsize,
        context: AtomicUsize,
        chunks: AtomicI64,
        /// The job's number (low 32 bits) above 32 bits of chunks claimed.
        claimed: [AtomicU64; MOST as usize / 32],
        done: AtomicI64,
    }

    impl Slot {
        /// Chunk `i` of job `job`, done if no thread has claimed it.
        fn take(&self, job: u64, task: extern "C" fn(*mut u8, i64), context: usize, i: i64) {
            let word = &self.claimed[i as usize / 32];
            let bit = 1u64 << (i % 32);
            let mut w = word.load(SeqCst);
            loop {
                if w >> 32 != job & 0xffff_ffff || w & bit != 0 {
                    return;
                }
                match word.compare_exchange(w, w | bit, SeqCst, SeqCst) {
                    Ok(_) => break,
                    Err(now) => w = now,
                }
            }
            task(context as *mut u8, i);
            self.done.fetch_add(1, SeqCst);
        }
    }

    struct Pool {
        threads: usize,
        /// The latest job's number.
        latest: AtomicU64,
        slots: Vec<Slot>,
        sleeping: AtomicUsize,
        lock: Mutex<()>,
        wake: Condvar,
    }

    /// Spins before a waiting thread sleeps.
    const SPINS: u32 = 1 << 18;
    /// How long the caller waits for a thread to claim its chunks.
    const PATIENCE: Duration = Duration::from_micros(20);

    impl Pool {
        fn block(&self, chunks: i64, t: usize) -> std::ops::Range<i64> {
            let n = self.threads as i64;
            t as i64 * chunks / n..(t as i64 + 1) * chunks / n
        }

        fn worker(&self, t: usize) {
            let mut seen = 0;
            loop {
                let mut spins = 0;
                while self.latest.load(SeqCst) == seen {
                    if spins < SPINS {
                        spins += 1;
                        std::hint::spin_loop();
                        continue;
                    }
                    let mut guard = self.lock.lock().unwrap();
                    self.sleeping.fetch_add(1, SeqCst);
                    while self.latest.load(SeqCst) == seen {
                        guard = self.wake.wait(guard).unwrap();
                    }
                    self.sleeping.fetch_sub(1, SeqCst);
                }
                seen = self.latest.load(SeqCst);
                let slot = &self.slots[seen as usize % SLOTS];
                // The job as it was when numbered `seen`, if it still is.
                let before = slot.job.load(SeqCst);
                let (task, context, chunks) =
                    (slot.task.load(SeqCst), slot.context.load(SeqCst), slot.chunks.load(SeqCst));
                if before != seen || slot.job.load(SeqCst) != seen {
                    continue;
                }
                let task: extern "C" fn(*mut u8, i64) = unsafe { std::mem::transmute(task) };
                for i in self.block(chunks, t) {
                    slot.take(seen, task, context, i);
                }
            }
        }
    }

    fn pool() -> &'static Pool {
        static POOL: OnceLock<&'static Pool> = OnceLock::new();
        POOL.get_or_init(|| {
            let threads = std::env::var("EPITOME_THREADS")
                .ok()
                .and_then(|v| v.parse().ok())
                // Half the cores, as the threads spin between jobs and a job
                // waits for the slowest: the rest are left for the system,
                // whose work would otherwise stop a thread mid-job. (Past 16,
                // the LM head is as fast as memory lets it be.)
                .unwrap_or_else(|| (std::thread::available_parallelism().map_or(1, |n| n.get()) / 2).clamp(1, 16))
                .max(1);
            let p: &'static Pool = Box::leak(Box::new(Pool {
                threads,
                latest: AtomicU64::new(0),
                slots: (0..SLOTS).map(|_| Slot::default()).collect(),
                sleeping: AtomicUsize::new(0),
                lock: Mutex::new(()),
                wake: Condvar::new(),
            }));
            for t in 1..threads {
                std::thread::spawn(move || p.worker(t));
            }
            p
        })
    }

    pub fn run(task: extern "C" fn(*mut u8, i64), context: *mut u8, chunks: i64) {
        let p = pool();
        if p.threads == 1 || chunks <= 1 || chunks > MOST {
            for i in 0..chunks {
                task(context, i);
            }
            return;
        }
        let job = p.latest.load(SeqCst) + 1;
        let slot = &p.slots[job as usize % SLOTS];
        slot.job.store(0, SeqCst);
        slot.task.store(task as usize, SeqCst);
        slot.context.store(context as usize, SeqCst);
        slot.chunks.store(chunks, SeqCst);
        slot.done.store(0, SeqCst);
        for w in &slot.claimed {
            w.store((job & 0xffff_ffff) << 32, SeqCst);
        }
        slot.job.store(job, SeqCst);
        p.latest.store(job, SeqCst);
        if p.sleeping.load(SeqCst) > 0 {
            let _guard = p.lock.lock().unwrap();
            p.wake.notify_all();
        }
        let context = context as usize;
        for i in p.block(chunks, 0) {
            slot.take(job, task, context, i);
        }
        let start = Instant::now();
        let mut spins = 0u32;
        while slot.done.load(SeqCst) < chunks {
            std::hint::spin_loop();
            spins += 1;
            if spins % 64 == 0 && start.elapsed() > PATIENCE {
                for i in 0..chunks {
                    slot.take(job, task, context, i);
                }
            }
        }
    }
}

fn main() {
    let mut args: Vec<String> = std::env::args().skip(1).collect();
    let show_ids = args.first().is_some_and(|a| a == "--ids");
    if show_ids {
        args.remove(0);
    }
    let bench = match args.first().map(String::as_str) {
        Some("--bench") => {
            args.remove(0);
            let secs = if args.is_empty() { 5.0 } else { args.remove(0).parse().unwrap_or(5.0) };
            Some(secs)
        }
        _ => None,
    };
    if args.first().is_some_and(|a| a == "--score-text") {
        // Text as the tokenizer splits it, predicted from its first token.
        let dir = std::env::current_exe().ok().and_then(|p| p.parent().map(|p| p.to_path_buf())).unwrap_or_default();
        let bpe = Bpe::load(&dir).unwrap_or_else(|e| {
            eprintln!("llm: {e}");
            std::process::exit(1)
        });
        let ids: Vec<i64> = bpe.encode(&args[1..].join(" ")).into_iter().map(i64::from).collect();
        score(&ids, 1);
        return;
    }
    if args.first().is_some_and(|a| a == "--score") {
        // A prompt, then | and the ids to predict after it.
        let text = args[1..].join(" ");
        let (prompt, rest) = text.split_once('|').unwrap_or(("", &text));
        let parse = |s: &str| s.split_whitespace().filter_map(|t| t.parse().ok()).collect::<Vec<i64>>();
        let (prompt, rest) = (parse(prompt), parse(rest));
        score(&[prompt.as_slice(), rest.as_slice()].concat(), prompt.len().max(1));
        return;
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
    if let Some(secs) = bench {
        // The same window again and again, for profiling; after one pass
        // not timed (the weights loaded, the threads started).
        // SAFETY: as below.
        unsafe { forward(window.as_ptr(), logits.as_mut_ptr()) };
        TIMES.lock().unwrap().clear();
        let start = Instant::now();
        let mut n = 0;
        while start.elapsed().as_secs_f64() < secs {
            // SAFETY: as below.
            unsafe { forward(window.as_ptr(), logits.as_mut_ptr()) };
            n += 1;
        }
        let ms = start.elapsed().as_secs_f64() * 1e3 / n as f64;
        println!("{n} forward passes, {ms:.2} ms each");
        if profiling() {
            print_times(n, ms);
        }
        return;
    }

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

/// One forward pass over `ids` (a window at most): how often the model's
/// choice is the next id, and the perplexity of the ids from `from` on (the
/// exponential of their mean negative log-probability).
fn score(ids: &[i64], from: usize) {
    let dir = std::env::current_exe().ok().and_then(|p| p.parent().map(|p| p.to_path_buf())).unwrap_or_default();
    let Config { window: win, vocab, .. } = Config::load(&dir).unwrap_or_else(|e| {
        eprintln!("llm: {e}");
        std::process::exit(1)
    });
    let n = ids.len().min(win);
    let mut window = vec![0i64; win];
    window[..n].copy_from_slice(&ids[..n]);
    let mut logits = vec![0f32; win * vocab];
    // SAFETY: `window` and `logits` have the sizes `forward` was compiled for.
    unsafe { forward(window.as_ptr(), logits.as_mut_ptr()) };
    let (mut agree, mut nll) = (0, 0f64);
    for t in from - 1..n - 1 {
        let row = &logits[t * vocab..(t + 1) * vocab];
        let next = ids[t + 1] as usize;
        agree += (argmax(row) as usize == next) as usize;
        let max = row.iter().copied().fold(f32::MIN, f32::max) as f64;
        let sum: f64 = row.iter().map(|&x| (x as f64 - max).exp()).sum();
        nll -= row[next] as f64 - max - sum.ln();
    }
    let count = n - from;
    println!("{agree} of {count} next ids chosen; perplexity {:.4}", (nll / count as f64).exp());
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
