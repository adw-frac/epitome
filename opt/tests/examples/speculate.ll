; epitome-opt: --passes=simplifycfg,combine
; Arms that compute a little, safely, run before the branch, so the joins
; become selects: a clamp has no branch left. An arm that may trap keeps
; its branch.
define i32 @clamp(i32 %x) {
entry:
  %low = icmp slt i32 %x, -50
  br i1 %low, label %done, label %upper

upper:
  %high = icmp sgt i32 %x, 200
  %c = select i1 %high, i32 200, i32 %x
  br label %done

done:
  %r = phi i32 [ -50, %entry ], [ %c, %upper ]
  ret i32 %r
}

define i32 @divides(i32 %x, i32 %y) {
entry:
  %zero = icmp eq i32 %y, 0
  br i1 %zero, label %done, label %div

div:
  %q = sdiv i32 %x, %y
  br label %done

done:
  %r = phi i32 [ 0, %entry ], [ %q, %div ]
  ret i32 %r
}

define i32 @main() {
  %a = call i32 @clamp(i32 300)
  %b = call i32 @clamp(i32 -80)
  %c = call i32 @divides(i32 7, i32 0)
  %s = add i32 %a, %b
  %t = add i32 %s, %c
  ret i32 %t
}
