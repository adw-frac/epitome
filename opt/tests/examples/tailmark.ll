; epitome-opt: --passes=tailmark
; Calls marked tail where nothing in the caller's frame can be reached.
define i32 @g(i32 %x) {
  %r = add i32 %x, 1
  ret i32 %r
}

define void @use(ptr %p) {
  ret void
}

declare i32 @setjmp(ptr) returns_twice

; No allocas: marked.
define i32 @plain(i32 %x) {
  %r = call i32 @g(i32 %x)
  ret i32 %r
}

; An alloca whose address the callee may keep: left alone.
define i32 @with_alloca(i32 %x) {
  %p = alloca i32
  call void @use(ptr %p)
  %r = call i32 @g(i32 %x)
  ret i32 %r
}

; Variable arguments live in the frame: left alone.
define i32 @variadic(i32 %x, ...) {
  %r = call i32 @g(i32 %x)
  ret i32 %r
}

; A byval parameter's copy is in the caller's frame: left alone.
define i32 @by_value(ptr byval(i32) %p) {
  call void @use(ptr %p)
  ret i32 0
}

; setjmp's frame must stay; notail is kept as written.
define i32 @kept(ptr %b, i32 %x) {
  %s = call i32 @setjmp(ptr %b)
  %n = notail call i32 @g(i32 %s)
  ret i32 %n
}

define i32 @main() {
  %a = call i32 @plain(i32 1)
  %b = call i32 @with_alloca(i32 2)
  %c = add i32 %a, %b
  ret i32 %c
}
