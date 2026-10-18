; @repeat: cse: 2 merged, 0 loads reused, 0 stores forwarded
; @canonical: cse: 2 merged, 0 loads reused, 0 stores forwarded
; @flags: cse: 1 merged, 0 loads reused, 0 stores forwarded
; @dominance: cse: 2 merged, 0 loads reused, 0 stores forwarded
; @memory: cse: 0 merged, 2 loads reused, 1 stores forwarded


declare void @write(ptr)

declare i32 @pure(i32) memory(none)

define i32 @repeat(i32 %x, i32 %y) {
  %a = mul i32 %x, %y
  %c = add i32 %a, 1
  %r = xor i32 %c, %c
  ret i32 %r
}

define i1 @canonical(i32 %x, i32 %y) {
  %a = add i32 %x, %y
  %c = icmp slt i32 %a, %x
  %r = and i1 %c, %c
  ret i1 %r
}

define i32 @flags(i32 %x, i32 %y) {
  %a = add nuw i32 %x, %y
  %r = sub i32 %a, %a
  ret i32 %r
}

define i32 @dominance(i32 %x, i1 %c) {
entry:
  %a = shl i32 %x, 2
  br i1 %c, label %then, label %else

then:                                             ; preds = %entry
  %t = mul i32 %x, 3
  br label %join

else:                                             ; preds = %entry
  %e = mul i32 %x, 3
  br label %join

join:                                             ; preds = %else, %then
  %p = phi i32 [ %t, %then ], [ %e, %else ]
  %s = add i32 %p, %p
  %r = add i32 %s, %a
  ret i32 %r
}

define i32 @memory(ptr %p, i32 %v) {
  %a = load i32, ptr %p
  store i32 %v, ptr %p
  call void @write(ptr %p)
  %d = load i32, ptr %p
  %e = call i32 @pure(i32 %d)
  %s1 = add i32 %a, %a
  %s2 = add i32 %v, %d
  %s3 = add i32 %e, %d
  %s4 = add i32 %s1, %s2
  %r = add i32 %s4, %s3
  ret i32 %r
}

define i32 @loop(ptr %p, i32 %n) {
entry:
  %before = load i32, ptr %p
  br label %head

head:                                             ; preds = %head, %entry
  %i = phi i32 [ 0, %entry ], [ %next, %head ]
  %inside = load i32, ptr %p
  store i32 %i, ptr %p
  %next = add i32 %i, 1
  %more = icmp slt i32 %next, %n
  br i1 %more, label %head, label %done

done:                                             ; preds = %head
  %r = add i32 %before, %inside
  ret i32 %r
}

define i32 @not_merged(i32 %x, ptr %p) {
  %a = freeze i32 %x
  %b = freeze i32 %x
  %c = load volatile i32, ptr %p
  %d = load volatile i32, ptr %p
  %s = add i32 %a, %b
  %t = add i32 %c, %d
  %r = add i32 %s, %t
  ret i32 %r
}
