; @gcd: recursion: 1 tail call(s) now jump back to the start


define i32 @gcd(i32 %a.arg, i32 %b.arg) {
entry.rec:
  br label %entry

entry:                                            ; preds = %recur, %entry.rec
  %a = phi i32 [ %a.arg, %entry.rec ], [ %b, %recur ]
  %b = phi i32 [ %b.arg, %entry.rec ], [ %rem, %recur ]
  %zero = icmp eq i32 %b, 0
  br i1 %zero, label %done, label %recur

recur:                                            ; preds = %entry
  %rem = urem i32 %a, %b
  br label %entry

done:                                             ; preds = %entry
  ret i32 %a
}

define i32 @main() {
entry:
  %x = call i32 @gcd(i32 1071, i32 462)
  ret i32 %x
}
