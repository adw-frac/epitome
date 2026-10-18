; @walk: sroa: 1 allocas split into 1 pieces
; @walk: mem2reg: 1 allocas promoted (1 loads, 2 stores removed)
; @walk: recursion: 1 accumulator call(s) now jump back to the start, folding with add
; @walk: combine: add_zero x1, sub_const x1


define i32 @walk(i32 %n.arg) {
entry.rec:
  br label %entry

entry:                                            ; preds = %recur, %entry.rec
  %n = phi i32 [ %n.arg, %entry.rec ], [ %m, %recur ]
  %acc = phi i32 [ 0, %entry.rec ], [ %sum, %recur ]
  %stop = icmp eq i32 %n, 0
  br i1 %stop, label %done, label %recur

recur:                                            ; preds = %entry
  %m = add i32 %n, -1
  %sum = add i32 %acc, %n
  br label %entry

done:                                             ; preds = %entry
  ret i32 %acc
}

define i32 @main() {
entry:
  %x = call i32 @walk(i32 10)
  ret i32 %x
}
