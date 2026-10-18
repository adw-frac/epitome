; draconian-opt: --passes=mem2reg
; Promoting allocas to SSA values.

declare void @use(ptr)
declare void @llvm.lifetime.start.p0(ptr)

; int sum(int n) { int s = 0; for (int i = 0; i < n; i++) s += i; return s; }
; as a front end writes it: every variable in memory.
define i32 @sum(i32 %n) {
entry:
  %n.addr = alloca i32
  %s = alloca i32
  %i = alloca i32
  store i32 %n, ptr %n.addr
  store i32 0, ptr %s
  store i32 0, ptr %i
  br label %cond

cond:
  %iv = load i32, ptr %i
  %nv = load i32, ptr %n.addr
  %c = icmp slt i32 %iv, %nv
  br i1 %c, label %body, label %done

body:
  %sv = load i32, ptr %s
  %iv2 = load i32, ptr %i
  %add = add i32 %sv, %iv2
  store i32 %add, ptr %s
  %inc = add i32 %iv2, 1
  store i32 %inc, ptr %i
  br label %cond

done:
  %r = load i32, ptr %s
  ret i32 %r
}

; if/else: the stores meet in a phi. Inside one block, a load sees the
; store just before it.
define i32 @pick(i1 %c, i32 %a, i32 %b) {
entry:
  %x = alloca i32
  call void @llvm.lifetime.start.p0(ptr %x)
  br i1 %c, label %then, label %else

then:
  store i32 %a, ptr %x
  %t = load i32, ptr %x
  %t2 = mul i32 %t, 2
  store i32 %t2, ptr %x
  br label %join

else:
  store i32 %b, ptr %x
  br label %join

join:
  %r = load i32, ptr %x
  ret i32 %r
}

; A path with no store reads undef.
define i32 @maybe(i1 %c) {
entry:
  %x = alloca i32
  br i1 %c, label %set, label %join

set:
  store i32 7, ptr %x
  br label %join

join:
  %r = load i32, ptr %x
  ret i32 %r
}

; Not promoted: the address is passed to a call, accessed at an offset, or
; read at another type.
define i32 @kept(i64 %w) {
entry:
  %passed = alloca i32
  %array = alloca [2 x i32]
  %other = alloca i64
  store i32 1, ptr %passed
  call void @use(ptr %passed)
  %second = getelementptr [2 x i32], ptr %array, i64 0, i64 1
  store i32 2, ptr %second
  store i64 %w, ptr %other
  %low = load i32, ptr %other
  %a = load i32, ptr %passed
  %b = load i32, ptr %second
  %s = add i32 %a, %b
  %r = add i32 %s, %low
  ret i32 %r
}
