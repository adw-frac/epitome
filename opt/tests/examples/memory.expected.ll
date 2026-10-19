; @forward: combine: forward_store x1
; @reuse: combine: (load reused) x1, add_self x1
; @dead: combine: (dead store) x2, (dead) x1
; @live: combine: (dead) x1
; @same: combine: (dead) x1, (store of the value there) x1

target datalayout = "e-m:o-i64:64-i128:128-n32:64-S128"

declare void @opaque()

declare void @may_throw()

define i32 @forward(ptr %p, ptr noalias %q, i1 %c) {
entry:
  store i32 7, ptr %p
  br i1 %c, label %a, label %b

a:                                                ; preds = %entry
  store i32 1, ptr %q
  br label %j

b:                                                ; preds = %entry
  br label %j

j:                                                ; preds = %b, %a
  ret i32 7
}

define i32 @reuse(ptr %p, i1 %c) {
entry:
  %x = load i32, ptr %p
  br i1 %c, label %a, label %b

a:                                                ; preds = %entry
  call void @opaque() memory(none)
  br label %j

b:                                                ; preds = %entry
  br label %j

j:                                                ; preds = %b, %a
  %s = shl i32 %x, 1
  ret i32 %s
}

define void @dead(ptr %p, i1 %c) {
entry:
  br i1 %c, label %a, label %b

a:                                                ; preds = %entry
  store i32 2, ptr %p
  ret void

b:                                                ; preds = %entry
  store i32 3, ptr %p
  ret void
}

define void @live(ptr %p, i1 %c) {
entry:
  store i32 1, ptr %p
  br i1 %c, label %a, label %b

a:                                                ; preds = %entry
  store i32 2, ptr %p
  ret void

b:                                                ; preds = %entry
  call void @may_throw()
  store i32 3, ptr %p
  ret void
}

define void @same(ptr %p) {
  ret void
}
