; smaugian-opt: --no-inline
; One non-tail call. The value loaded before the call is needed after it,
; so it is saved in the frame. The parameter `%depth` is passed through
; unchanged by every recursive call, so it is never saved.
%node = type { i32, ptr }

define i32 @sum(ptr %list, i32 %depth) {
entry:
  %end = icmp eq ptr %list, null
  br i1 %end, label %empty, label %more

more:
  %value = load i32, ptr %list
  %next.addr = getelementptr inbounds %node, ptr %list, i32 0, i32 1
  %next = load ptr, ptr %next.addr
  %rest = call i32 @sum(ptr %next, i32 %depth)
  %scaled = mul i32 %value, %depth
  %total = add i32 %scaled, %rest
  ret i32 %total

empty:
  ret i32 0
}

@n3 = global %node { i32 30, ptr null }
@n2 = global %node { i32 20, ptr @n3 }
@n1 = global %node { i32 10, ptr @n2 }

define i32 @main() {
entry:
  %x = call i32 @sum(ptr @n1, i32 2)
  ret i32 %x
}
