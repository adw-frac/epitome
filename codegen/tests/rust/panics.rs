// A whole Rust program compiled by epitome (from rustc's IR), linked
// against rustc's std: panics unwind through drops and are caught by
// `catch_unwind`, resumed, and nested.
use std::panic;

// (Not an atomic or a thread local: epitome has neither yet.)
static mut DROPS: u32 = 0;

struct Guard(&'static str);

impl Drop for Guard {
    fn drop(&mut self) {
        unsafe { DROPS += 1 };
        println!("drop {}", self.0);
    }
}

#[inline(never)]
fn deep(n: u64) -> u64 {
    let _g = Guard("deep");
    if n == 0 {
        panic!("bottom");
    }
    let v = std::hint::black_box(deep(n - 1));
    v + n
}

#[inline(never)]
fn checked(x: i32) -> Result<i32, String> {
    panic::catch_unwind(|| {
        let _g = Guard("checked");
        if x < 0 {
            panic!("negative {x}");
        }
        x * 2
    })
    .map_err(|e| e.downcast_ref::<String>().cloned().unwrap_or_default())
}

fn main() {
    panic::set_hook(Box::new(|_| {}));
    println!("{:?}", checked(21));
    println!("{:?}", checked(-4));
    let r = panic::catch_unwind(|| deep(3));
    println!("deep: {}", if r.is_err() { "caught" } else { "returned" });
    // Caught, then resumed, then caught again further out.
    let outer = panic::catch_unwind(|| {
        let _g = Guard("outer");
        let inner = panic::catch_unwind(|| {
            let _g = Guard("inner");
            panic::panic_any(42u32)
        });
        match inner {
            Err(e) => panic::resume_unwind(e),
            Ok(()) => (),
        }
    });
    let v = outer.err().and_then(|e| e.downcast_ref::<u32>().copied());
    println!("resumed: {v:?}");
    println!("drops: {}", unsafe { DROPS });
}
