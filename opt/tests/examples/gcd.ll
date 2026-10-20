; epitome-opt: --no-inline
; Tail recursion: the call's result is returned directly, so the call
; becomes a jump back to the start with new arguments. No stack needed.
define i32 @gcd(i32 %a, i32 %b) {
entry:
  %zero = icmp eq i32 %b, 0
  br i1 %zero, label %done, label %recur

recur:
  %rem = urem i32 %a, %b
  %g = call i32 @gcd(i32 %b, i32 %rem)
  ret i32 %g

done:
  ret i32 %a
}

define i32 @main() {
entry:
  %x = call i32 @gcd(i32 1071, i32 462)
  ret i32 %x
}
