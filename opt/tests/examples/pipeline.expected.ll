; @fact: recursion: 1 accumulator call(s) now jump back to the start, folding with mul
; @fact: combine: mul_one x1, sub_const x1
; @main: inlined @fact: cost 4, bonus 8, threshold 100
; @fact: deleted, no longer used


define i32 @main() {
entry:
  br label %entry.i

entry.i:                                          ; preds = %recur.i, %entry
  %n.i = phi i64 [ 10, %entry ], [ %m.i, %recur.i ]
  %acc.i = phi i64 [ 1, %entry ], [ %p.i, %recur.i ]
  %base.i = icmp ule i64 %n.i, 1
  br i1 %base.i, label %one.i, label %recur.i

recur.i:                                          ; preds = %entry.i
  %m.i = add i64 %n.i, -1
  %p.i = mul i64 %acc.i, %n.i
  br label %entry.i

one.i:                                            ; preds = %entry.i
  %x = trunc i64 %acc.i to i32
  ret i32 %x
}
