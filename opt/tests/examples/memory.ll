; draconian-opt: --passes=combine,memory
; The combiner's memory rules and steps: a stored value forwarded across a
; join, a load reused across a diamond, stores overwritten on every path or
; to a local never read again deleted, and stores that must stay.
target datalayout = "e-m:o-i64:64-i128:128-n32:64-S128"
declare void @opaque()
declare void @may_throw()

; Forwarding a stored value across a join, where the walker sees one write.
define i32 @forward(ptr %p, ptr noalias %q, i1 %c) {
entry:
  store i32 7, ptr %p
  br i1 %c, label %a, label %b
a:
  store i32 1, ptr %q
  br label %j
b:
  br label %j
j:
  %v = load i32, ptr %p
  ret i32 %v
}

; Reusing a load across a diamond with no writes.
define i32 @reuse(ptr %p, i1 %c) {
entry:
  %x = load i32, ptr %p
  br i1 %c, label %a, label %b
a:
  call void @opaque() memory(none)
  br label %j
b:
  br label %j
j:
  %y = load i32, ptr %p
  %s = add i32 %x, %y
  ret i32 %s
}

; Dead stores: overwritten on every path; a local never read again.
define void @dead(ptr %p, i1 %c) {
entry:
  %t = alloca i32
  store i32 1, ptr %p
  store i32 5, ptr %t
  br i1 %c, label %a, label %b
a:
  store i32 2, ptr %p
  ret void
b:
  store i32 3, ptr %p
  ret void
}

; Not dead: read on one path; and a call that may throw in between.
define void @live(ptr %p, i1 %c) {
entry:
  store i32 1, ptr %p
  br i1 %c, label %a, label %b
a:
  %v = load i32, ptr %p
  store i32 2, ptr %p
  ret void
b:
  call void @may_throw()
  store i32 3, ptr %p
  ret void
}

; A store of the value already there.
define void @same(ptr %p) {
  %v = load i32, ptr %p
  store i32 %v, ptr %p
  ret void
}
