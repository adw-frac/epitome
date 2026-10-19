//! Address sinking (`prepare::sink_addresses`): an address computed in one
//! block and used by loads in another is folded into the loads there, but
//! is not moved into a loop that its own block is not in.

use draconian_codegen::target::Target;
use draconian_codegen::{Options, compile};

fn asm(src: &str) -> String {
    let t = Target::aarch64();
    let mut m = draconian_ir::parse_module(src).unwrap();
    compile(&t, &mut m, &Options::default()).unwrap().asm
}

fn instructions(asm: &str) -> Vec<String> {
    asm.lines()
        .map(str::trim)
        .filter(|l| !l.is_empty() && !l.starts_with('.') && !l.ends_with(':'))
        .map(str::to_string)
        .collect()
}

#[test]
fn addresses_fold_into_loads_in_other_blocks() {
    let a = asm(r#"
target triple = "arm64-apple-macosx14.0.0"
define i64 @f(ptr %p, i1 %c, i64 %i) {
entry:
  %a = getelementptr inbounds i64, ptr %p, i64 3
  %b = getelementptr inbounds i64, ptr %p, i64 %i
  br i1 %c, label %then, label %else
then:
  %x = load i64, ptr %a
  %y = load i64, ptr %b
  %s = add i64 %x, %y
  ret i64 %s
else:
  %z = load i64, ptr %a
  ret i64 %z
}
"#);
    let insts = instructions(&a);
    assert!(insts.iter().any(|l| l.contains("[x0, #24]")), "{a}");
    assert!(insts.iter().any(|l| l.contains("lsl #3]")), "{a}");
    assert!(!insts.iter().any(|l| l.starts_with("add") && l.contains("#24")), "the address is still computed:\n{a}");
}

#[test]
fn addresses_stay_out_of_loops() {
    // The address is computed once before the loop; copying it into the
    // loop would compute it every time round if it did not fold.
    let a = asm(r#"
target triple = "arm64-apple-macosx14.0.0"
define i64 @g(ptr %p, i64 %n, i64 %i) {
entry:
  %b = getelementptr inbounds i64, ptr %p, i64 %i
  br label %loop
loop:
  %k = phi i64 [ 0, %entry ], [ %k1, %loop ]
  %acc = phi i64 [ 0, %entry ], [ %acc1, %loop ]
  %v = load i64, ptr %b
  %acc1 = add i64 %acc, %v
  %k1 = add i64 %k, 1
  %c = icmp ult i64 %k1, %n
  br i1 %c, label %loop, label %done
done:
  ret i64 %acc1
}
"#);
    // Computed once, before the loop's label; inside it, loaded from.
    let (before, inside) = a.split_once("LBB0_1:").expect("a loop");
    assert!(before.contains("lsl #3"), "the address was moved into the loop:\n{a}");
    assert!(!inside.contains("lsl #3"), "the address is computed in the loop:\n{a}");
}
