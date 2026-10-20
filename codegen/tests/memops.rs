//! Small `llvm.memset` and `llvm.memcpy` calls are written out as loads
//! and stores (`prepare::expand_small_mem_ops`), as wide as what is left
//! allows, since AArch64's need no alignment (`unaligned-access`); long or
//! volatile ones stay calls.

use draconian_codegen::target::Target;
use draconian_codegen::{Options, compile};

fn asm(body: &str) -> String {
    let src = format!(
        "target triple = \"arm64-apple-macosx14.0.0\"\n\
         declare void @llvm.memset.p0.i64(ptr, i8, i64, i1)\n\
         declare void @llvm.memcpy.p0.p0.i64(ptr, ptr, i64, i1)\n{body}"
    );
    let t = Target::aarch64();
    let mut m = draconian_ir::parse_module(&src).unwrap();
    compile(&t, &mut m, &Options::default()).unwrap().asm
}

#[test]
fn small_ones_are_written_out() {
    let a = asm(
        "define void @z(ptr %p) {\n  call void @llvm.memset.p0.i64(ptr align 8 %p, i8 0, i64 24, i1 false)\n  ret void\n}",
    );
    assert_eq!(a.matches("str xzr").count(), 3, "{a}");
    assert!(!a.contains("memset"), "{a}");
    // Ones at 2-byte alignment: four bytes, then two.
    let a = asm(
        "define void @o(ptr %p) {\n  call void @llvm.memset.p0.i64(ptr align 2 %p, i8 -1, i64 6, i1 false)\n  ret void\n}",
    );
    assert_eq!(a.matches("str w").count() + a.matches("strh").count(), 2, "{a}");
    // A copy at 1-byte alignment: 8, 8 and 4 bytes.
    let a = asm(
        "define void @u(ptr %d, ptr %s) {\n  call void @llvm.memcpy.p0.p0.i64(ptr align 1 %d, ptr align 1 %s, i64 20, i1 false)\n  ret void\n}",
    );
    assert_eq!(a.matches("ldr x").count(), 2, "{a}");
    assert_eq!(a.matches("ldr w").count(), 1, "{a}");
    let a = asm(
        "define void @c(ptr %d, ptr %s) {\n  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %d, ptr align 8 %s, i64 16, i1 false)\n  ret void\n}",
    );
    assert_eq!(a.matches("ldr x").count(), 2, "{a}");
    assert!(!a.contains("memcpy"), "{a}");
}

#[test]
fn long_and_volatile_ones_stay_calls() {
    let a = asm(
        "define void @big(ptr %p) {\n  call void @llvm.memset.p0.i64(ptr align 1 %p, i8 0, i64 200, i1 false)\n  ret void\n}",
    );
    assert!(a.contains("_memset"), "{a}");
    let a = asm(
        "define void @v(ptr %p) {\n  call void @llvm.memset.p0.i64(ptr align 8 %p, i8 0, i64 8, i1 true)\n  ret void\n}",
    );
    assert!(a.contains("_memset"), "{a}");
}
