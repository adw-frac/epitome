//! IR shapes found in crates (memchr, hashbrown, serde_json, aho-corasick,
//! regex-syntax, zmij) that once kept them from compiling: each compiles,
//! to an object file, into what it should.

use epitome_codegen::target::Target;
use epitome_codegen::{Options, compile};

/// Our assembly for `body` (functions for apple-m1, with NEON), after
/// checking it makes an object file.
fn asm(body: &str) -> String {
    let src = format!(
        "target triple = \"arm64-apple-macosx14.0.0\"\n\
         declare <2 x i64> @llvm.umin.v2i64(<2 x i64>, <2 x i64>)\n\
         declare <2 x i64> @llvm.ctpop.v2i64(<2 x i64>)\n\
         declare <16 x i8> @llvm.aarch64.neon.umaxp.v16i8(<16 x i8>, <16 x i8>)\n\
         declare <16 x i8> @llvm.aarch64.neon.tbl1.v16i8(<16 x i8>, <16 x i8>)\n\
         declare void @llvm.experimental.memset.pattern.p0.i32.i64(ptr, i32, i64, i1)\n{body}"
    );
    let t = Target::aarch64();
    let mut m = epitome_ir::parse_module(&src).unwrap();
    let c = compile(&t, &mut m, &Options::default()).unwrap();
    c.object_file(&t).unwrap();
    c.asm
}

#[test]
fn vectors_and_integers_of_one_width() {
    let a = asm("define i64 @a(<4 x i16> %v) {\n  %r = bitcast <4 x i16> %v to i64\n  ret i64 %r\n}");
    assert!(a.contains("fmov x0, d0"), "{a}");
    // 128 bits go through memory: a store, and a load of the other type.
    let a = asm("define i128 @b(<16 x i8> %v) {\n  %r = bitcast <16 x i8> %v to i128\n  ret i128 %r\n}");
    assert!(a.contains("str q0") && a.contains("ldp x0, x1"), "{a}");
    let a = asm("define <16 x i8> @c(i128 %v) {\n  %r = bitcast i128 %v to <16 x i8>\n  ret <16 x i8> %r\n}");
    assert!(a.contains("stp x0, x1") && a.contains("ldr q0"), "{a}");
}

#[test]
fn neon_without_an_instruction() {
    // No 64-bit lane minimum: compare and select.
    let a = asm(
        "define <2 x i64> @m(<2 x i64> %x, <2 x i64> %y) {\n  %r = call <2 x i64> @llvm.umin.v2i64(<2 x i64> %x, <2 x i64> %y)\n  ret <2 x i64> %r\n}",
    );
    assert!(a.contains("cmhi") && a.contains("bsl"), "{a}");
    // Bits counted in bytes only: lane by lane.
    let a = asm(
        "define <2 x i64> @p(<2 x i64> %x) {\n  %r = call <2 x i64> @llvm.ctpop.v2i64(<2 x i64> %x)\n  ret <2 x i64> %r\n}",
    );
    assert_eq!(a.matches("cnt").count(), 2, "{a}");
}

#[test]
fn neon_intrinsics() {
    let a = asm(
        "define <16 x i8> @u(<16 x i8> %x, <16 x i8> %y) {\n  %r = call <16 x i8> @llvm.aarch64.neon.umaxp.v16i8(<16 x i8> %x, <16 x i8> %y)\n  ret <16 x i8> %r\n}",
    );
    assert!(a.contains("umaxp v0.16b, v0.16b, v1.16b"), "{a}");
    let a = asm(
        "define <16 x i8> @t(<16 x i8> %x, <16 x i8> %y) {\n  %r = call <16 x i8> @llvm.aarch64.neon.tbl1.v16i8(<16 x i8> %x, <16 x i8> %y)\n  ret <16 x i8> %r\n}",
    );
    assert!(a.contains("tbl v0.16b, {v0.16b}, v1.16b"), "{a}");
}

#[test]
fn shuffles_by_their_type() {
    // A splat of the first lane, of a vector in a register.
    let a = asm(
        "define <4 x i32> @s(<4 x i32> %x) {\n  %r = shufflevector <4 x i32> %x, <4 x i32> poison, <4 x i32> zeroinitializer\n  ret <4 x i32> %r\n}",
    );
    assert!(a.contains("dup v0.4s, v0.s[0]"), "{a}");
    // A mask the description has for <4 x i16> (rev64), at <4 x i32>,
    // where it has none: lane by lane.
    let a = asm(
        "define <4 x i32> @r(<4 x i32> %x) {\n  %r = shufflevector <4 x i32> %x, <4 x i32> poison, <4 x i32> <i32 3, i32 2, i32 1, i32 0>\n  ret <4 x i32> %r\n}",
    );
    assert!(!a.contains("rev64"), "{a}");
}

#[test]
fn selects_of_structs() {
    let a = asm(
        "define { ptr, i64 } @s(i1 %c, ptr %a, i64 %x, ptr %b) {\n  %s1 = insertvalue { ptr, i64 } poison, ptr %a, 0\n  %s2 = insertvalue { ptr, i64 } %s1, i64 %x, 1\n  %t = insertvalue { ptr, i64 } { ptr null, i64 7 }, ptr %b, 0\n  %r = select i1 %c, { ptr, i64 } %s2, { ptr, i64 } %t\n  ret { ptr, i64 } %r\n}",
    );
    assert_eq!(a.matches("csel").count(), 2, "{a}");
}

#[test]
fn memset_patterns_are_loops() {
    let a = asm(
        "define void @f(ptr %p, i64 %n) {\n  call void @llvm.experimental.memset.pattern.p0.i32.i64(ptr %p, i32 -1, i64 %n, i1 false)\n  ret void\n}",
    );
    assert!(a.contains("str w") && a.contains("lsl #2") && a.contains("b.lo"), "{a}");
}

#[test]
fn bitcasts_of_floats_beside_odd_widths() {
    // An odd width (i3) in the function once made every bitcast a copy,
    // this one too, leaving the integer's register never written.
    let a = asm(
        "define i8 @f(double %d) {\n  %b = bitcast double %d to i64\n  %s = lshr i64 %b, 52\n  %t = trunc i64 %s to i3\n  %z = zext i3 %t to i8\n  ret i8 %z\n}",
    );
    assert!(a.contains("fmov x"), "{a}");
}

#[test]
fn block_comments_in_inline_assembly() {
    // A value barrier: an empty template naming its operand.
    let a = asm(
        "define i64 @f(i64 %x) {\n  %r = call i64 asm sideeffect \"/*${0}*/\", \"=&r,0,~{cc},~{memory}\"(i64 %x)\n  ret i64 %r\n}",
    );
    assert!(a.contains("/*x0*/"), "{a}");
}
