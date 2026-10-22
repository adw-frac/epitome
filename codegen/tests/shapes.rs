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
    // 64-bit integers to floats: lane by lane, as narrowing the integers
    // first would lose their high bits.
    let a = asm(
        "define <2 x float> @u(<2 x i64> %x) {\n  %r = uitofp <2 x i64> %x to <2 x float>\n  ret <2 x float> %r\n}",
    );
    assert!(a.matches("ucvtf s").count() == 2 && !a.contains("xtn"), "{a}");
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

#[test]
fn double_vector_comparisons_are_of_doubles() {
    // <2 x double> and <4 x float> are both 128 bits: the comparison is
    // of the lanes' type.
    let a = asm(
        "define <2 x i64> @f(<2 x double> %a, <2 x double> %b) {\n  %m = fcmp ogt <2 x double> %a, %b\n  %r = sext <2 x i1> %m to <2 x i64>\n  ret <2 x i64> %r\n}",
    );
    assert!(a.contains("fcmgt v0.2d"), "{a}");
    // Unordered ones: the opposite ordered one, inverted.
    let a = asm(
        "define <2 x i64> @g(<2 x double> %a, <2 x double> %b) {\n  %m = fcmp une <2 x double> %a, %b\n  %r = sext <2 x i1> %m to <2 x i64>\n  ret <2 x i64> %r\n}",
    );
    assert!(a.contains("fcmeq") && a.contains(".2d"), "{a}");
}

#[test]
fn vectors_of_pointers_to_globals() {
    let a = asm(
        "@a = global i64 1\ndefine void @f(ptr %p) {\n  store <2 x ptr> <ptr @a, ptr null>, ptr %p, align 8\n  ret void\n}",
    );
    assert!(a.contains("_a@"), "{a}");
}

#[test]
fn first_set_lanes_and_scalar_selects() {
    let a = asm(
        "declare i64 @llvm.experimental.cttz.elts.i64.v16i1(<16 x i1>, i1)\ndefine i64 @f(<16 x i8> %v) {\n  %m = icmp eq <16 x i8> %v, zeroinitializer\n  %r = call i64 @llvm.experimental.cttz.elts.i64.v16i1(<16 x i1> %m, i1 false)\n  ret i64 %r\n}",
    );
    assert!(a.contains("rbit") || a.contains("ctz") || a.contains("clz"), "{a}");
    let a = asm(
        "define <2 x double> @s(i1 %c, <2 x double> %a, <2 x double> %b) {\n  %r = select i1 %c, <2 x double> %a, <2 x double> %b\n  ret <2 x double> %r\n}",
    );
    assert!(a.contains("bsl"), "{a}");
}

#[test]
fn wide_lanes_and_nested_aggregates() {
    // Lanes of i128, one by one.
    let a = asm(
        "define i8 @w(i128 %m, <8 x i8> %k) {\n  %si = insertelement <8 x i128> poison, i128 %m, i64 0\n  %sp = shufflevector <8 x i128> %si, <8 x i128> poison, <8 x i32> zeroinitializer\n  %z = zext <8 x i8> %k to <8 x i128>\n  %b = shl <8 x i128> splat (i128 1), %z\n  %a = and <8 x i128> %b, %sp\n  %c = icmp ne <8 x i128> %a, zeroinitializer\n  %r = bitcast <8 x i1> %c to i8\n  ret i8 %r\n}",
    );
    assert!(!a.is_empty());
    // A named struct with a struct inside: its leaves.
    let a = asm(
        "%In = type { ptr, i64 }\n%Out = type { %In, i32 }\ndefine i64 @n(ptr %p) {\n  %a = load volatile %Out, ptr %p, align 8\n  %i = extractvalue %Out %a, 0\n  %n = extractvalue %In %i, 1\n  ret i64 %n\n}",
    );
    assert!(a.contains("[x0, #8]") || a.contains("ldp"), "{a}");
    // An address as an offset from null.
    let a = asm(
        "@g = global i64 1\ndefine ptr @z() {\n  ret ptr getelementptr (i8, ptr null, i64 ptrtoint (ptr @g to i64))\n}",
    );
    assert!(a.contains("_g@"), "{a}");
}

/// `ptrtoaddr` (newer than the clang tests/ir.rs builds with): the
/// pointer's bits, of a value and of a constant.
#[test]
fn addresses_of_pointers() {
    let a = asm("define i64 @a(ptr %p) {\n  %r = ptrtoaddr ptr %p to i64\n  ret i64 %r\n}");
    assert!(a.lines().filter(|l| l.starts_with('\t') && !l.contains('.')).count() == 1, "{a}");
    let a = asm(
        "@g = global i64 0\ndefine i64 @b(ptr %p) {\n  %a = ptrtoaddr ptr %p to i64\n  %r = sub i64 %a, ptrtoaddr (ptr @g to i64)\n  ret i64 %r\n}",
    );
    assert!(a.contains("_g@") && a.contains("sub"), "{a}");
}

/// Bit tests (`tbz`, which reaches 32KB) going back to two blocks both
/// far away, in two loops: each becomes the opposite test around jumps,
/// in a block of its own; the second is found after the first moved the
/// blocks after it.
#[test]
fn far_branches_relaxed_one_after_another() {
    let mut body = String::from("define i32 @far(i64 %x, ptr %p) {\nentry:\n  br label %A0\n");
    for i in 0..2 {
        let next = if i == 0 { "A1".to_string() } else { "done".to_string() };
        body += &format!("A{i}:\n");
        body += &"  store volatile i32 1, ptr %p\n".repeat(9000);
        body += &format!("  br label %B{i}\nB{i}:\n");
        body += &"  store volatile i32 2, ptr %p\n".repeat(9000);
        body += &format!(
            "  %k{i} = load volatile i32, ptr %p\n  %e{i} = icmp eq i32 %k{i}, 0\n  br i1 %e{i}, label %{next}, label %C{i}\n\
             C{i}:\n  %b{i} = and i64 %x, {}\n  %c{i} = icmp ne i64 %b{i}, 0\n  br i1 %c{i}, label %A{i}, label %B{i}\n",
            1 << i
        );
    }
    body += "done:\n  ret i32 0\n}";
    let a = asm(&body);
    let lines: Vec<&str> = a.lines().map(str::trim).collect();
    for bit in ["#0", "#1"] {
        let k = lines.iter().position(|l| l.starts_with("tbz") && l.contains(bit)).expect(&a[..200]);
        // The test goes to the block after the jump that follows it.
        let target = lines[k].rsplit(' ').next().unwrap();
        assert!(lines[k + 1].starts_with("b ") && lines[k + 2] == format!("{target}:"), "{:?}", &lines[k - 1..k + 4]);
    }
}
