; Functions the loader calls before main: one by `#[link_section]` (a
; pointer in __mod_init_func, kept by @llvm.used, as `ctor` makes), two by
; @llvm.global_ctors (in priority order); and data in a section of its own.
target triple = "arm64-apple-macosx14.0.0"
@log = global [4 x i32] zeroinitializer
@n = global i32 0
@CTOR = internal constant ptr @by_section, section "__DATA,__mod_init_func", align 8
@table = constant [2 x i32] [i32 11, i32 22], section "__DATA,__my_table", align 4
@llvm.used = appending global [2 x ptr] [ptr @CTOR, ptr @table], section "llvm.metadata"
@llvm.global_ctors = appending global [2 x { i32, ptr, ptr }] [{ i32, ptr, ptr } { i32 200, ptr @late, ptr null }, { i32, ptr, ptr } { i32 100, ptr @early, ptr null }]

define internal void @record(i32 %v) {
  %k = load i32, ptr @n
  %p = getelementptr [4 x i32], ptr @log, i32 0, i32 %k
  store i32 %v, ptr %p
  %k1 = add i32 %k, 1
  store i32 %k1, ptr @n
  ret void
}
define internal void @by_section() {
  call void @record(i32 1)
  ret void
}
define internal void @early() {
  call void @record(i32 2)
  ret void
}
define internal void @late() {
  call void @record(i32 3)
  ret void
}
define i32 @logged(i32 %i) {
  %p = getelementptr [4 x i32], ptr @log, i32 0, i32 %i
  %v = load i32, ptr %p
  ret i32 %v
}
define i32 @count() {
  %k = load i32, ptr @n
  ret i32 %k
}
define i32 @table_entry(i32 %i) {
  %p = getelementptr [2 x i32], ptr @table, i32 0, i32 %i
  %v = load i32, ptr %p
  ret i32 %v
}
