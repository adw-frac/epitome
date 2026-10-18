; @sum: recursion: 1 accumulator call(s) now jump back to the start, folding with add
; @sum: combine: add_zero x1


%node = type { i32, ptr }

@n3 = global %node { i32 30, ptr null }
@n2 = global %node { i32 20, ptr @n3 }
@n1 = global %node { i32 10, ptr @n2 }

define i32 @sum(ptr %list.arg, i32 %depth) {
entry.rec:
  br label %entry

entry:                                            ; preds = %more, %entry.rec
  %list = phi ptr [ %list.arg, %entry.rec ], [ %next, %more ]
  %acc = phi i32 [ 0, %entry.rec ], [ %total, %more ]
  %end = icmp eq ptr %list, null
  br i1 %end, label %empty, label %more

more:                                             ; preds = %entry
  %value = load i32, ptr %list
  %next.addr = getelementptr inbounds %node, ptr %list, i32 0, i32 1
  %next = load ptr, ptr %next.addr
  %scaled = mul i32 %value, %depth
  %total = add i32 %acc, %scaled
  br label %entry

empty:                                            ; preds = %entry
  ret i32 %acc
}

define i32 @main() {
entry:
  %x = call i32 @sum(ptr @n1, i32 2)
  ret i32 %x
}
