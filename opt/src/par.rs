//! Running work on many threads.
//!
//! Two shapes cover what the passes need:
//!
//! - `map`: independent items, such as scanning every function for calls.
//! - `run_dag`: tasks with dependencies, such as call-graph SCCs that must
//!   wait for their callees.
//!
//! Both use only `std`. A task that panics stops the others from taking new
//! work, and the panic is raised again on the calling thread.

use std::collections::BinaryHeap;
use std::panic::{self, AssertUnwindSafe};
use std::sync::atomic::{AtomicUsize, Ordering};
use std::sync::{Condvar, Mutex};

/// The number of threads to use when the caller asks for 0.
pub fn default_threads() -> usize {
    std::thread::available_parallelism().map(|n| n.get()).unwrap_or(1)
}

/// `work(i, &items[i])` for every item, on up to `threads` threads. The
/// results come back in item order.
pub fn map<T: Sync, R: Send>(items: &[T], threads: usize, work: impl Fn(usize, &T) -> R + Sync) -> Vec<R> {
    let threads = threads.max(1).min(items.len().max(1));
    if threads == 1 {
        return items.iter().enumerate().map(|(i, t)| work(i, t)).collect();
    }
    let next = AtomicUsize::new(0);
    let results: Vec<Mutex<Option<R>>> = items.iter().map(|_| Mutex::new(None)).collect();
    std::thread::scope(|s| {
        for _ in 0..threads {
            s.spawn(|| {
                loop {
                    let i = next.fetch_add(1, Ordering::Relaxed);
                    if i >= items.len() {
                        break;
                    }
                    let r = work(i, &items[i]);
                    *results[i].lock().unwrap() = Some(r);
                }
            });
        }
    });
    results.into_iter().map(|r| r.into_inner().unwrap().expect("task did not finish")).collect()
}

struct DagState {
    /// Ready tasks, highest priority first, then lowest index.
    ready: BinaryHeap<(u64, std::cmp::Reverse<usize>)>,
    /// Unfinished dependencies of each task.
    pending: Vec<usize>,
    /// Tasks not yet finished.
    remaining: usize,
    /// A task panicked; stop taking work.
    failed: Option<Box<dyn std::any::Any + Send>>,
}

/// Runs task `i` for every `i` in `0..deps.len()`, each only after all of
/// `deps[i]` have finished. Among ready tasks, higher `priority` goes first.
///
/// With one thread the tasks run on the calling thread, in the same order
/// the scheduler would pick them.
pub fn run_dag(deps: &[Vec<usize>], priority: &[u64], threads: usize, work: impl Fn(usize) + Sync) {
    let n = deps.len();
    let mut users: Vec<Vec<usize>> = vec![Vec::new(); n];
    let mut pending = vec![0; n];
    for (i, ds) in deps.iter().enumerate() {
        for &d in ds {
            users[d].push(i);
            pending[i] += 1;
        }
    }
    let ready = (0..n).filter(|&i| pending[i] == 0).map(|i| (priority[i], std::cmp::Reverse(i))).collect();
    let state = Mutex::new(DagState { ready, pending, remaining: n, failed: None });
    let wake = Condvar::new();

    let worker = || {
        loop {
            let task = {
                let mut st = state.lock().unwrap();
                loop {
                    if st.failed.is_some() || st.remaining == 0 {
                        return;
                    }
                    if let Some((_, std::cmp::Reverse(i))) = st.ready.pop() {
                        break i;
                    }
                    st = wake.wait(st).unwrap();
                }
            };
            let result = panic::catch_unwind(AssertUnwindSafe(|| work(task)));
            let mut st = state.lock().unwrap();
            match result {
                Ok(()) => {
                    st.remaining -= 1;
                    let mut woken = 0;
                    for &u in &users[task] {
                        st.pending[u] -= 1;
                        if st.pending[u] == 0 {
                            st.ready.push((priority[u], std::cmp::Reverse(u)));
                            woken += 1;
                        }
                    }
                    if st.remaining == 0 {
                        wake.notify_all();
                    } else {
                        // This thread takes one of the new tasks itself; wake
                        // one other thread for each of the rest.
                        for _ in 1..woken {
                            wake.notify_one();
                        }
                    }
                }
                Err(e) => {
                    st.failed.get_or_insert(e);
                    wake.notify_all();
                }
            }
        }
    };

    let threads = threads.max(1);
    if threads == 1 {
        worker();
    } else {
        std::thread::scope(|s| {
            for _ in 0..threads {
                s.spawn(worker);
            }
        });
    }
    let st = state.into_inner().unwrap();
    if let Some(e) = st.failed {
        panic::resume_unwind(e);
    }
    assert_eq!(st.remaining, 0, "dependency cycle in run_dag");
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn dag_respects_dependencies() {
        // 0 <- 1 <- 3, 0 <- 2 <- 3
        let deps = vec![vec![], vec![0], vec![0], vec![1, 2]];
        for threads in [1, 4] {
            let order = Mutex::new(Vec::new());
            run_dag(&deps, &[0; 4], threads, |i| order.lock().unwrap().push(i));
            let order = order.into_inner().unwrap();
            let pos = |x| order.iter().position(|&y| y == x).unwrap();
            assert!(pos(0) < pos(1) && pos(0) < pos(2) && pos(1) < pos(3) && pos(2) < pos(3));
        }
    }

    #[test]
    fn map_keeps_order() {
        let items: Vec<u32> = (0..100).collect();
        assert_eq!(map(&items, 8, |_, x| x * 2), items.iter().map(|x| x * 2).collect::<Vec<_>>());
    }

    #[test]
    #[should_panic(expected = "boom")]
    fn dag_panic_is_raised() {
        let deps = vec![vec![], vec![0]];
        run_dag(&deps, &[0, 0], 2, |i| {
            if i == 0 {
                panic!("boom")
            }
        });
    }
}
