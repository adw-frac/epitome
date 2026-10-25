//! Small `llvm.memset` and `llvm.memcpy` calls are written out as loads
//! and stores (`prepare::expand_small_mem_ops`): since AArch64's need no
//! alignment (`unaligned-access`), each as wide as the length allows
//! (integer registers to 16 bytes, vectors past them), the last
//! overlapping the one before; long or volatile ones stay calls.

use epitome_codegen::target::Target;
use epitome_codegen::{Options, compile};

fn asm(body: &str) -> String {
    let src = format!(
        "target triple = \"arm64-apple-macosx14.0.0\"\n\
         declare void @llvm.memset.p0.i64(ptr, i8, i64, i1)\n\
         declare void @llvm.memcpy.p0.p0.i64(ptr, ptr, i64, i1)\n{body}"
    );
    let t = Target::aarch64();
    let mut m = epitome_ir::parse_module(&src).unwrap();
    compile(&t, &mut m, &Options::default()).unwrap().asm
}

#[test]
fn small_ones_are_written_out() {
    // 24 zeros: two 16-byte vectors, the second overlapping the first.
    let a = asm(
        "define void @z(ptr %p) {\n  call void @llvm.memset.p0.i64(ptr align 8 %p, i8 0, i64 24, i1 false)\n  ret void\n}",
    );
    assert!(a.contains("str q0, [x0, #0]") && a.contains("stur q0, [x0, #8]"), "{a}");
    assert!(!a.contains("memset"), "{a}");
    // Six bytes of ones: two 4-byte stores, at 0 and 2.
    let a = asm(
        "define void @o(ptr %p) {\n  call void @llvm.memset.p0.i64(ptr align 2 %p, i8 -1, i64 6, i1 false)\n  ret void\n}",
    );
    assert!(a.contains("str w1, [x0, #0]") && a.contains("stur w1, [x0, #2]"), "{a}");
    // A copy of 20 bytes: two 16-byte vectors, at 0 and 4.
    let a = asm(
        "define void @u(ptr %d, ptr %s) {\n  call void @llvm.memcpy.p0.p0.i64(ptr align 1 %d, ptr align 1 %s, i64 20, i1 false)\n  ret void\n}",
    );
    assert_eq!(a.matches("ldr q").count() + a.matches("ldur q").count(), 2, "{a}");
    assert!(a.contains("stur q1, [x0, #4]"), "{a}");
    // Sixteen bytes: integer registers, one pair each way.
    let a = asm(
        "define void @c(ptr %d, ptr %s) {\n  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %d, ptr align 8 %s, i64 16, i1 false)\n  ret void\n}",
    );
    assert_eq!(a.matches("ldp x").count(), 1, "{a}");
    assert_eq!(a.matches("stp x").count(), 1, "{a}");
    assert!(!a.contains("memcpy"), "{a}");
}

#[test]
fn long_and_volatile_ones_stay_calls() {
    let a = asm(
        "define void @big(ptr %p) {\n  call void @llvm.memset.p0.i64(ptr align 1 %p, i8 0, i64 2000, i1 false)\n  ret void\n}",
    );
    assert!(a.contains("_memset"), "{a}");
    let a = asm(
        "define void @v(ptr %p) {\n  call void @llvm.memset.p0.i64(ptr align 8 %p, i8 0, i64 8, i1 true)\n  ret void\n}",
    );
    assert!(a.contains("_memset"), "{a}");
}
