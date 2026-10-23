; The module's own assembly (Rust's global_asm!, ctor's registrations):
; a section pushed and popped, data and a function defined there, used by
; the module's code. (In the older form, a line each, which the clang
; this is compared with reads; ir/tests/features.rs reads the newer.)
target triple = "arm64-apple-macosx14.0.0"

module asm ".pushsection __DATA,__my_table,regular,no_dead_strip"
module asm ".globl _table"
module asm ".p2align 3"
module asm "_table:"
module asm ".quad 7"
module asm ".quad _answer"
module asm ".popsection"
module asm ".globl _seven_plus"
module asm ".p2align 2"
module asm "_seven_plus:"
module asm "    add w0, w0, #7"
module asm "    ret"

@table = external global [2 x i64]
declare i32 @seven_plus(i32)

define i32 @answer() {
  ret i32 42
}

define i64 @first() {
  %v = load i64, ptr @table
  ret i64 %v
}

define i32 @second_called() {
  %p = getelementptr i64, ptr @table, i64 1
  %f = load ptr, ptr %p
  %v = call i32 %f()
  %w = call i32 @seven_plus(i32 %v)
  ret i32 %w
}
