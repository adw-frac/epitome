; epitome-opt: --no-inline --print-cycles
; Mutual recursion. @is_odd is internal and only called by @is_even, so
; @is_even is the only way into the cycle. Inlining @is_odd into it leaves
; a self-recursive tail call, which becomes a loop; @is_odd is then unused.
define i1 @is_even(i32 %n) {
entry:
  %zero = icmp eq i32 %n, 0
  br i1 %zero, label %yes, label %recur

recur:
  %m = sub i32 %n, 1
  %r = call i1 @is_odd(i32 %m)
  ret i1 %r

yes:
  ret i1 true
}

define internal i1 @is_odd(i32 %n) {
entry:
  %zero = icmp eq i32 %n, 0
  br i1 %zero, label %no, label %recur

recur:
  %m = sub i32 %n, 1
  %r = call i1 @is_even(i32 %m)
  ret i1 %r

no:
  ret i1 false
}

define i32 @main() {
entry:
  %e = call i1 @is_even(i32 77)
  %x = zext i1 %e to i32
  ret i32 %x
}
