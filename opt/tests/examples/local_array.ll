; smaugian-opt: --no-inline
; Each activation has its own local array, and its address is live across
; the recursive call. The alloca moves into the loop with the old entry
; block, so every activation allocates afresh; popping a frame restores
; the stack pointer, which frees the finished activation's array too.
declare void @llvm.memset.p0.i64(ptr, i8, i64, i1)

define i32 @walk(i32 %n) {
entry:
  %buf = alloca [4 x i32]
  call void @llvm.memset.p0.i64(ptr %buf, i8 0, i64 16, i1 false)
  store i32 %n, ptr %buf
  %stop = icmp eq i32 %n, 0
  br i1 %stop, label %done, label %recur

recur:
  %m = sub i32 %n, 1
  %inner = call i32 @walk(i32 %m)
  %mine = load i32, ptr %buf
  %sum = add i32 %inner, %mine
  ret i32 %sum

done:
  ret i32 0
}

define i32 @main() {
entry:
  %x = call i32 @walk(i32 10)
  ret i32 %x
}
