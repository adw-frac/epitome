//! A cap on a process's memory, so that a compilation that runs away stops
//! with an error instead of taking the machine down with it (macOS
//! compresses and swaps a growing process for a long time, then shows a
//! dialog and pauses applications).
//!
//! A binary installs it as its allocator and sets the limit at the start of
//! `main`:
//!
//! ```ignore
//! #[global_allocator]
//! static MEMORY: epitome_ir::memlimit::Limited = epitome_ir::memlimit::Limited;
//!
//! fn main() {
//!     epitome_ir::memlimit::set_from_env(4096);
//!     // ...
//! }
//! ```
//!
//! `EPITOME_MEMORY_LIMIT_MB` overrides the default; 0 means no limit. Past
//! the limit an allocation fails, and Rust stops the process ("memory
//! allocation of N bytes failed") after a line saying why. With
//! `EPITOME_MEMORY_BACKTRACE=1` the process prints where it was instead,
//! and stops (for finding what grew, without a debugger).

use std::alloc::{GlobalAlloc, Layout, System};
use std::io::Write;
use std::sync::atomic::{AtomicBool, AtomicUsize, Ordering};

/// Bytes allocated now, and the most allowed (`usize::MAX`: no limit).
static USED: AtomicUsize = AtomicUsize::new(0);
static LIMIT: AtomicUsize = AtomicUsize::new(usize::MAX);
static SAID: AtomicBool = AtomicBool::new(false);
static BACKTRACE: AtomicBool = AtomicBool::new(false);

/// The system allocator, counting, refusing past the limit.
pub struct Limited;

impl Limited {
    fn take(&self, size: usize) -> bool {
        let before = USED.fetch_add(size, Ordering::Relaxed);
        if before.saturating_add(size) > LIMIT.load(Ordering::Relaxed) {
            USED.fetch_sub(size, Ordering::Relaxed);
            if !SAID.swap(true, Ordering::Relaxed) {
                // No allocation here: a fixed message, written directly.
                let _ = std::io::stderr().write_all(
                    b"epitome: the memory limit was reached (raise it with EPITOME_MEMORY_LIMIT_MB, 0 for none)\n",
                );
                if BACKTRACE.load(Ordering::Relaxed) {
                    // Lifted, so that the backtrace itself can allocate.
                    LIMIT.store(usize::MAX, Ordering::Relaxed);
                    let bt = std::backtrace::Backtrace::force_capture();
                    let _ = writeln!(std::io::stderr(), "an allocation of {size} bytes, at:\n{bt}");
                    std::process::abort();
                }
            }
            return false;
        }
        true
    }
}

unsafe impl GlobalAlloc for Limited {
    unsafe fn alloc(&self, layout: Layout) -> *mut u8 {
        if !self.take(layout.size()) {
            return std::ptr::null_mut();
        }
        let p = unsafe { System.alloc(layout) };
        if p.is_null() {
            USED.fetch_sub(layout.size(), Ordering::Relaxed);
        }
        p
    }

    unsafe fn alloc_zeroed(&self, layout: Layout) -> *mut u8 {
        if !self.take(layout.size()) {
            return std::ptr::null_mut();
        }
        let p = unsafe { System.alloc_zeroed(layout) };
        if p.is_null() {
            USED.fetch_sub(layout.size(), Ordering::Relaxed);
        }
        p
    }

    unsafe fn dealloc(&self, ptr: *mut u8, layout: Layout) {
        unsafe { System.dealloc(ptr, layout) };
        USED.fetch_sub(layout.size(), Ordering::Relaxed);
    }

    unsafe fn realloc(&self, ptr: *mut u8, layout: Layout, new_size: usize) -> *mut u8 {
        let old = layout.size();
        if new_size > old && !self.take(new_size - old) {
            return std::ptr::null_mut();
        }
        let p = unsafe { System.realloc(ptr, layout, new_size) };
        if p.is_null() {
            if new_size > old {
                USED.fetch_sub(new_size - old, Ordering::Relaxed);
            }
        } else if new_size < old {
            USED.fetch_sub(old - new_size, Ordering::Relaxed);
        }
        p
    }
}

/// Sets the limit to `EPITOME_MEMORY_LIMIT_MB` megabytes, or to
/// `default_mb` if that is not set; 0 means no limit.
pub fn set_from_env(default_mb: usize) {
    let mb = std::env::var("EPITOME_MEMORY_LIMIT_MB").ok().and_then(|v| v.trim().parse().ok()).unwrap_or(default_mb);
    set_limit_mb(mb);
    BACKTRACE.store(std::env::var("EPITOME_MEMORY_BACKTRACE").is_ok_and(|v| v == "1"), Ordering::Relaxed);
}

/// Sets the limit in megabytes; 0 means no limit.
pub fn set_limit_mb(mb: usize) {
    LIMIT.store(if mb == 0 { usize::MAX } else { mb.saturating_mul(1 << 20) }, Ordering::Relaxed);
}

/// Bytes allocated now, through `Limited`.
pub fn used() -> usize {
    USED.load(Ordering::Relaxed)
}
