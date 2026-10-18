; cycle: @is_even -> @is_odd -> @is_even
; @is_even: recursion: inlined @is_odd to break the cycle
; @is_even: recursion: 1 tail call(s) now jump back to the start
; @is_even: combine: (dead) x1, add_add_const x1, icmp_eq_add x1, sub_const x2
; @is_odd: combine: sub_const x1
; @is_odd: deleted, no longer used


define i1 @is_even(i32 %n.arg) {
entry.rec:
  br label %entry

entry:                                            ; preds = %recur.i, %entry.rec
  %n = phi i32 [ %n.arg, %entry.rec ], [ %m.i, %recur.i ]
  %zero = icmp eq i32 %n, 0
  br i1 %zero, label %yes, label %recur

recur:                                            ; preds = %entry
  %zero.i = icmp eq i32 %n, 1
  br i1 %zero.i, label %no.i, label %recur.i

recur.i:                                          ; preds = %recur
  %m.i = add i32 %n, -2
  br label %entry

no.i:                                             ; preds = %recur
  ret i1 false

yes:                                              ; preds = %entry
  ret i1 true
}

define i32 @main() {
entry:
  %e = call i1 @is_even(i32 77)
  %x = zext i1 %e to i32
  ret i32 %x
}
