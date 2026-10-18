; @sum: mem2reg: 3 allocas promoted (5 loads, 5 stores removed)
; @pick: mem2reg: 1 allocas promoted (2 loads, 3 stores removed)
; @maybe: mem2reg: 1 allocas promoted (1 loads, 1 stores removed)


declare void @use(ptr)

define i32 @sum(i32 %n) {
entry:
  br label %cond

cond:                                             ; preds = %body, %entry
  %s = phi i32 [ 0, %entry ], [ %add, %body ]
  %i = phi i32 [ 0, %entry ], [ %inc, %body ]
  %c = icmp slt i32 %i, %n
  br i1 %c, label %body, label %done

body:                                             ; preds = %cond
  %add = add i32 %s, %i
  %inc = add i32 %i, 1
  br label %cond

done:                                             ; preds = %cond
  ret i32 %s
}

define i32 @pick(i1 %c, i32 %a, i32 %b) {
entry:
  br i1 %c, label %then, label %else

then:                                             ; preds = %entry
  %t2 = mul i32 %a, 2
  br label %join

else:                                             ; preds = %entry
  br label %join

join:                                             ; preds = %else, %then
  %x = phi i32 [ %t2, %then ], [ %b, %else ]
  ret i32 %x
}

define i32 @maybe(i1 %c) {
entry:
  br i1 %c, label %set, label %join

set:                                              ; preds = %entry
  br label %join

join:                                             ; preds = %set, %entry
  %x = phi i32 [ undef, %entry ], [ 7, %set ]
  ret i32 %x
}

define i32 @kept(i64 %w) {
entry:
  %passed = alloca i32
  %array = alloca [2 x i32]
  %other = alloca i64
  store i32 1, ptr %passed
  call void @use(ptr %passed)
  %second = getelementptr [2 x i32], ptr %array, i64 0, i64 1
  store i32 2, ptr %second
  store i64 %w, ptr %other
  %low = load i32, ptr %other
  %a = load i32, ptr %passed
  %b = load i32, ptr %second
  %s = add i32 %a, %b
  %r = add i32 %s, %low
  ret i32 %r
}
