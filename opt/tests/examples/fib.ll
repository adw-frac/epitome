; smaugian-opt: --no-inline
; Two recursive calls per activation. Neither is a tail call, so each pushes
; a frame holding what is live after it: `n` after the first call, and the
; first result after the second.
define i32 @fib(i32 %n) {
entry:
  %small = icmp slt i32 %n, 2
  br i1 %small, label %done, label %recur

recur:
  %n1 = sub i32 %n, 1
  %a = call i32 @fib(i32 %n1)
  %n2 = sub i32 %n, 2
  %b = call i32 @fib(i32 %n2)
  %sum = add i32 %a, %b
  br label %done

done:
  %r = phi i32 [ %n, %entry ], [ %sum, %recur ]
  ret i32 %r
}

define i32 @main() {
entry:
  %x = call i32 @fib(i32 20)
  ret i32 %x
}
