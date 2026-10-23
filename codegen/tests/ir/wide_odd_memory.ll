; Wide integers whose high half is not a whole word, stored and loaded at
; odd addresses: exactly their bytes, never the bytes after (wide.rs, the
; high half as an i40 or i24 that promote_odd splits). An i104 store once
; wrote 16 bytes, three past the value.
define void @st104(ptr %p, i64 %lo, i64 %hi) {
  %a = zext i64 %lo to i104
  %b = zext i64 %hi to i104
  %c = shl i104 %b, 64
  %v = or i104 %a, %c
  store i104 %v, ptr %p, align 1
  ret void
}

define void @st104c(ptr %p) {
  store i104 1113232139568363117924917183234, ptr %p, align 1
  ret void
}

define void @st88(ptr %p, i64 %lo, i64 %hi) {
  %a = zext i64 %lo to i88
  %b = zext i64 %hi to i88
  %c = shl i88 %b, 64
  %v = or i88 %a, %c
  store i88 %v, ptr %p, align 1
  ret void
}

define void @st100(ptr %p, i64 %lo, i64 %hi) {
  %a = zext i64 %lo to i100
  %b = zext i64 %hi to i100
  %c = shl i100 %b, 64
  %v = or i100 %a, %c
  store i100 %v, ptr %p, align 1
  ret void
}

; The high half of a loaded i104, an i88.
define i64 @ld104(ptr %p) {
  %v = load i104, ptr %p, align 1
  %h = lshr i104 %v, 64
  %t = trunc i104 %h to i64
  ret i64 %t
}

define i64 @ld88(ptr %p) {
  %v = load i88, ptr %p, align 1
  %h = lshr i88 %v, 64
  %t = trunc i88 %h to i64
  ret i64 %t
}
