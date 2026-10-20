// Threads sharing memory: atomics of every width and the standard
// library's locks, channels and one-time initialisation built on them,
// with results that do not depend on how the threads interleave.

use std::sync::atomic::{AtomicBool, AtomicI16, AtomicI64, AtomicPtr, AtomicU8, AtomicU32, AtomicUsize, Ordering};
use std::sync::{Arc, Condvar, Mutex, OnceLock, RwLock, mpsc};
use std::thread;

const THREADS: usize = 8;
const ROUNDS: usize = 20_000;

/// A spin lock on a byte, by compare-and-swap.
struct Spin {
    held: AtomicU8,
}

impl Spin {
    fn lock(&self) {
        while self.held.compare_exchange_weak(0, 1, Ordering::Acquire, Ordering::Relaxed).is_err() {
            std::hint::spin_loop();
        }
    }
    fn unlock(&self) {
        self.held.store(0, Ordering::Release);
    }
}

static COUNTER: AtomicUsize = AtomicUsize::new(0);
static BITS: AtomicU32 = AtomicU32::new(0);
static HIGH: AtomicI64 = AtomicI64::new(i64::MIN);
static LOW: AtomicI16 = AtomicI16::new(i16::MAX);
static FLAG: AtomicBool = AtomicBool::new(false);
static ONCE: OnceLock<String> = OnceLock::new();

fn main() {
    // Counting, from every thread, with each kind of read-modify-write.
    let spin = Arc::new(Spin { held: AtomicU8::new(0) });
    let shared = Arc::new(Mutex::new(Vec::new()));
    let plain = Arc::new(AtomicUsize::new(0));
    let mut handles = Vec::new();
    for t in 0..THREADS {
        let (spin, shared, plain) = (spin.clone(), shared.clone(), plain.clone());
        handles.push(thread::spawn(move || {
            for i in 0..ROUNDS {
                COUNTER.fetch_add(1, Ordering::Relaxed);
                COUNTER.fetch_sub(0, Ordering::SeqCst);
                BITS.fetch_or(1 << ((t * 4 + i) % 32), Ordering::AcqRel);
                BITS.fetch_and(!0, Ordering::Release);
                BITS.fetch_xor(0, Ordering::Acquire);
                HIGH.fetch_max((t * ROUNDS + i) as i64, Ordering::SeqCst);
                LOW.fetch_min(-((i % 1000) as i16) - t as i16, Ordering::SeqCst);
                // A read-modify-write the machine has no instruction for:
                // a compare-and-swap loop.
                let _ = COUNTER.fetch_update(Ordering::SeqCst, Ordering::Relaxed, |x| Some(x.wrapping_mul(1)));
                spin.lock();
                // Under the spin lock, a load and a store are enough.
                let v = plain.load(Ordering::Relaxed);
                plain.store(v + 1, Ordering::Relaxed);
                spin.unlock();
            }
            shared.lock().unwrap().push(t);
            let first = ONCE.get_or_init(|| "initialised once".to_string());
            assert_eq!(first, "initialised once");
            FLAG.swap(true, Ordering::SeqCst);
        }));
    }
    for h in handles {
        h.join().unwrap();
    }
    let mut who = shared.lock().unwrap().clone();
    who.sort();
    println!("counter {}", COUNTER.load(Ordering::SeqCst));
    println!("spin-locked {}", plain.load(Ordering::SeqCst));
    println!("bits {:#x}", BITS.load(Ordering::SeqCst));
    println!("high {} low {}", HIGH.load(Ordering::SeqCst), LOW.load(Ordering::SeqCst));
    println!("threads {who:?} flag {} once {:?}", FLAG.load(Ordering::SeqCst), ONCE.get());

    // A pointer swapped between threads.
    let boxes: Vec<*mut u64> = (0..THREADS as u64).map(|k| Box::into_raw(Box::new(k * 10))).collect();
    let slot = Arc::new(AtomicPtr::new(std::ptr::null_mut()));
    let taken: Vec<u64> = thread::scope(|s| {
        let hs: Vec<_> = boxes
            .iter()
            .map(|&b| {
                let slot = slot.clone();
                let b = b as usize;
                s.spawn(move || {
                    let old = slot.swap(b as *mut u64, Ordering::AcqRel);
                    if old.is_null() { u64::MAX } else { unsafe { *old } }
                })
            })
            .collect();
        hs.into_iter().map(|h| h.join().unwrap()).collect()
    });
    let last = slot.load(Ordering::Acquire);
    let mut seen: Vec<u64> = taken.into_iter().filter(|&v| v != u64::MAX).collect();
    seen.push(unsafe { *last });
    seen.sort();
    println!("pointers {seen:?}");
    for b in boxes {
        drop(unsafe { Box::from_raw(b) });
    }

    // A channel, a reader-writer lock and a condition variable.
    let (tx, rx) = mpsc::channel();
    let table = Arc::new(RwLock::new(vec![0u64; 16]));
    let ready = Arc::new((Mutex::new(0usize), Condvar::new()));
    for t in 0..THREADS {
        let (tx, table, ready) = (tx.clone(), table.clone(), ready.clone());
        thread::spawn(move || {
            for i in 0..100u64 {
                table.write().unwrap()[(t + i as usize) % 16] += i;
                let _sum: u64 = table.read().unwrap().iter().sum();
            }
            tx.send(t * t).unwrap();
            let (m, c) = &*ready;
            *m.lock().unwrap() += 1;
            c.notify_all();
        });
    }
    drop(tx);
    let mut got: Vec<usize> = rx.iter().collect();
    got.sort();
    let (m, c) = &*ready;
    let mut n = m.lock().unwrap();
    while *n < THREADS {
        n = c.wait(n).unwrap();
    }
    println!("sent {got:?} done {}", *n);
    println!("table {:?}", table.read().unwrap());
}
