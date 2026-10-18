; smaugian-opt: -O2
; Recursion removal and inlining working together. @fact is processed
; first, because @main calls it. Once its recursion is gone it is a plain
; function, small enough to inline into @main, and since that was its only
; call and it is internal, it is deleted.
define internal i64 @fact(i64 %n) {
entry:
  %base = icmp ule i64 %n, 1
  br i1 %base, label %one, label %recur

recur:
  %m = sub i64 %n, 1
  %f = call i64 @fact(i64 %m)
  %p = mul i64 %n, %f
  ret i64 %p

one:
  ret i64 1
}

define i32 @main() {
entry:
  %f = call i64 @fact(i64 10)
  %x = trunc i64 %f to i32
  ret i32 %x
}
