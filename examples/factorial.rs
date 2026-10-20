//! Builds a factorial function, and a `main` that prints some factorials,
//! with `epitome_ir::build`'s chained builders; optimises the module with
//! Epitome and compiles it for AArch64.
//!
//! ```sh
//! cargo run --release --example factorial            # the IR and the assembly
//! cargo run --release --example factorial -- --run   # also link it and run it (needs clang)
//! ```
//!
//! What it builds, in C:
//!
//! ```c
//! static uint64_t factorial(uint64_t n) {
//!     uint64_t acc = 1;
//!     for (uint64_t i = 2; i <= n; i++) acc *= i;
//!     return acc;
//! }
//! int main(void) {
//!     for (uint64_t n = 0; n <= 20; n += 5) printf("%llu! = %llu\n", n, factorial(n));
//!     return 0;
//! }
//! ```

use std::process::{Command, ExitCode};

use epitome_codegen::target::Target;
use epitome_codegen::{Options, compile};
use epitome_ir::module::{BinOp, Function, Global, ICmpPred, Linkage, Module};

fn build() -> Module {
    let mut m = Module::default();
    m.triple = Some(b"arm64-apple-macosx14.0.0".to_vec());
    let (i32t, i64t, ptr) = (m.types.int(32), m.types.int(64), m.types.ptr(0));

    // static uint64_t factorial(uint64_t n)
    let mut b = Function::builder("factorial")
        .returns(i64t)
        .param("n", i64t)
        .linkage(Linkage::Internal)
        .attr("nounwind")
        .begin(&mut m);
    let n = b.param(0);
    let entry = b.block("entry");
    let body = b.new_block("loop");
    let done = b.new_block("done");

    // entry: for n < 2 the answer is 1.
    let one = b.const_int(i64t, 1);
    let two = b.const_int(i64t, 2);
    let small = b.name("small").icmp(ICmpPred::Ult, n, two);
    b.cond_br(small, done, body);

    // loop: acc *= i, for i from 2 to n.
    b.at(body);
    let i = b.name("i").phi(i64t, &[(two, entry)]);
    let acc = b.name("acc").phi(i64t, &[(one, entry)]);
    let acc1 = b.name("acc.next").build_binary(BinOp::Mul, acc, i).build();
    let i1 = b.name("i.next").build_binary(BinOp::Add, i, one).nuw().build();
    b.add_incoming(i, i1, body);
    b.add_incoming(acc, acc1, body);
    let more = b.name("more").icmp(ICmpPred::Ule, i1, n);
    b.cond_br(more, body, done);

    // done: 1 for small n, else what the loop made.
    b.at(done);
    let r = b.name("r").phi(i64t, &[(one, entry), (acc1, body)]);
    b.ret(r);
    let factorial = b.finish().expect("every block ends in a terminator");

    // int printf(ptr, ...), and the format string.
    let printf =
        Function::builder("printf").returns(i32t).param("", ptr).param_attr("noundef").varargs().declare(&mut m);
    let text = m.const_bytes(b"%llu! = %llu\n\0");
    let format = Global::builder("format").init(text).constant().linkage(Linkage::Private).align(1).build(&mut m);

    // int main(void): factorial(n) for n = 0, 5, ..., 20.
    let mut b = Function::builder("main").returns(i32t).begin(&mut m);
    let entry = b.block("entry");
    let body = b.new_block("loop");
    let done = b.new_block("done");
    let (zero, five, twenty) = (b.const_int(i64t, 0), b.const_int(i64t, 5), b.const_int(i64t, 20));
    b.br(body);
    b.at(body);
    let n = b.name("n").phi(i64t, &[(zero, entry)]);
    let f = b.name("f").build_call(factorial).arg(n).build().unwrap();
    let fmt = b.module().global_value(format);
    b.build_call(printf).arg(fmt).arg(n).arg(f).build();
    let n1 = b.name("n.next").build_binary(BinOp::Add, n, five).nuw().build();
    b.add_incoming(n, n1, body);
    let more = b.name("more").icmp(ICmpPred::Ule, n1, twenty);
    b.cond_br(more, body, done);
    b.at(done);
    let ok = b.const_int(i32t, 0);
    b.ret(ok);
    b.finish().expect("every block ends in a terminator");
    m
}

fn main() -> ExitCode {
    let run = std::env::args().any(|a| a == "--run");
    let mut m = build();
    println!("; As built:\n{m}");

    epitome_opt::pipeline::run(&mut m, &epitome_opt::pipeline::Options::default());
    println!("; Optimised by Epitome:\n{m}");

    let t = Target::aarch64();
    let compiled = match compile(&t, &mut m, &Options::default()) {
        Ok(c) => c,
        Err(e) => {
            eprintln!("factorial: {e}");
            return ExitCode::FAILURE;
        }
    };
    println!("; AArch64 assembly:\n{}", compiled.asm);
    if !run {
        return ExitCode::SUCCESS;
    }

    // Link the object (its main calls printf) and run it.
    let dir = std::env::temp_dir().join(format!("epitome-factorial-{}", std::process::id()));
    std::fs::create_dir_all(&dir).unwrap();
    let object = dir.join("factorial.o");
    std::fs::write(&object, compiled.object_file(&t).unwrap()).unwrap();
    let exe = dir.join("factorial");
    let linked = Command::new("clang").arg(&object).arg("-o").arg(&exe).status();
    if !linked.is_ok_and(|s| s.success()) {
        eprintln!("factorial: linking with clang failed");
        return ExitCode::FAILURE;
    }
    let status = Command::new(&exe).status();
    let _ = std::fs::remove_dir_all(&dir);
    if status.is_ok_and(|s| s.success()) { ExitCode::SUCCESS } else { ExitCode::FAILURE }
}
