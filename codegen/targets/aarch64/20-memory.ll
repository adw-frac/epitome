; The AArch64 description: loads and stores, and atomics. The conventions
; are in 00-base.ll.

; ===========================================================================
; Loads and stores, with an unsigned offset scaled by the size.

define i8 @LDRBui(ptr "reg"="xsp" %n, i64 "imm" %off) "enc"="00 111 0 01 01 imm12:12=off n:5 d:5" "asm"="ldrb {d}, [{n}, #{off}]" "zext"="8" {
  %p = getelementptr i8, ptr %n, i64 %off
  %v = load i8, ptr %p
  ret i8 %v
}

define i16 @LDRHui(ptr "reg"="xsp" %n, i64 "imm" %off) "enc"="01 111 0 01 01 imm12:12=off/2 n:5 d:5" "asm"="ldrh {d}, [{n}, #{off}]" "zext"="16" {
  %p = getelementptr i8, ptr %n, i64 %off
  %v = load i16, ptr %p
  ret i16 %v
}

define i32 @LDRWui(ptr "reg"="xsp" %n, i64 "imm" %off) "enc"="10 111 0 01 01 imm12:12=off/4 n:5 d:5" "asm"="ldr {d}, [{n}, #{off}]" {
  %p = getelementptr i8, ptr %n, i64 %off
  %v = load i32, ptr %p
  ret i32 %v
}

define i64 @LDRXui(ptr "reg"="xsp" %n, i64 "imm" %off) "enc"="11 111 0 01 01 imm12:12=off/8 n:5 d:5" "asm"="ldr {d}, [{n}, #{off}]" "role"="load.x" {
  %p = getelementptr i8, ptr %n, i64 %off
  %v = load i64, ptr %p
  ret i64 %v
}

define ptr @LDRPui(ptr "reg"="xsp" %n, i64 "imm" %off) "enc"="11 111 0 01 01 imm12:12=off/8 n:5 d:5" "asm"="ldr {d}, [{n}, #{off}]" "nodecode" {
  %p = getelementptr i8, ptr %n, i64 %off
  %v = load ptr, ptr %p
  ret ptr %v
}

define i32 @LDRSBWui(ptr "reg"="xsp" %n, i64 "imm" %off) "enc"="00 111 0 01 11 imm12:12=off n:5 d:5" "asm"="ldrsb {d}, [{n}, #{off}]" {
  %p = getelementptr i8, ptr %n, i64 %off
  %v = load i8, ptr %p
  %r = sext i8 %v to i32
  ret i32 %r
}

define i64 @LDRSBXui(ptr "reg"="xsp" %n, i64 "imm" %off) "enc"="00 111 0 01 10 imm12:12=off n:5 d:5" "asm"="ldrsb {d}, [{n}, #{off}]" {
  %p = getelementptr i8, ptr %n, i64 %off
  %v = load i8, ptr %p
  %r = sext i8 %v to i64
  ret i64 %r
}

define i32 @LDRSHWui(ptr "reg"="xsp" %n, i64 "imm" %off) "enc"="01 111 0 01 11 imm12:12=off/2 n:5 d:5" "asm"="ldrsh {d}, [{n}, #{off}]" {
  %p = getelementptr i8, ptr %n, i64 %off
  %v = load i16, ptr %p
  %r = sext i16 %v to i32
  ret i32 %r
}

define i64 @LDRSWui(ptr "reg"="xsp" %n, i64 "imm" %off) "enc"="10 111 0 01 10 imm12:12=off/4 n:5 d:5" "asm"="ldrsw {d}, [{n}, #{off}]" {
  %p = getelementptr i8, ptr %n, i64 %off
  %v = load i32, ptr %p
  %r = sext i32 %v to i64
  ret i64 %r
}

define void @STRBui(i8 "reg"="w" %t, ptr "reg"="xsp" %n, i64 "imm" %off) "enc"="00 111 0 01 00 imm12:12=off n:5 t:5" "asm"="strb {t}, [{n}, #{off}]" {
  %p = getelementptr i8, ptr %n, i64 %off
  store i8 %t, ptr %p
  ret void
}

define void @STRHui(i16 "reg"="w" %t, ptr "reg"="xsp" %n, i64 "imm" %off) "enc"="01 111 0 01 00 imm12:12=off/2 n:5 t:5" "asm"="strh {t}, [{n}, #{off}]" {
  %p = getelementptr i8, ptr %n, i64 %off
  store i16 %t, ptr %p
  ret void
}

define void @STRWui(i32 "reg"="w" %t, ptr "reg"="xsp" %n, i64 "imm" %off) "enc"="10 111 0 01 00 imm12:12=off/4 n:5 t:5" "asm"="str {t}, [{n}, #{off}]" {
  %p = getelementptr i8, ptr %n, i64 %off
  store i32 %t, ptr %p
  ret void
}

define void @STRXui(i64 "reg"="x" %t, ptr "reg"="xsp" %n, i64 "imm" %off) "enc"="11 111 0 01 00 imm12:12=off/8 n:5 t:5" "asm"="str {t}, [{n}, #{off}]" "role"="store.x" {
  %p = getelementptr i8, ptr %n, i64 %off
  store i64 %t, ptr %p
  ret void
}

define void @STRPui(ptr "reg"="x" %t, ptr "reg"="xsp" %n, i64 "imm" %off) "enc"="11 111 0 01 00 imm12:12=off/8 n:5 t:5" "asm"="str {t}, [{n}, #{off}]" "nodecode" {
  %p = getelementptr i8, ptr %n, i64 %off
  store ptr %t, ptr %p
  ret void
}

; Negative or unaligned offsets: unscaled, signed 9 bits.
define i8 @LDURBi(ptr "reg"="xsp" %n, i64 "imm" %off) "enc"="00 111 0 00 01 0 off:s9 00 n:5 d:5" "asm"="ldurb {d}, [{n}, #{off}]" "zext"="8" {
  %p = getelementptr i8, ptr %n, i64 %off
  %v = load i8, ptr %p
  ret i8 %v
}

define i32 @LDURWi(ptr "reg"="xsp" %n, i64 "imm" %off) "enc"="10 111 0 00 01 0 off:s9 00 n:5 d:5" "asm"="ldur {d}, [{n}, #{off}]" {
  %p = getelementptr i8, ptr %n, i64 %off
  %v = load i32, ptr %p
  ret i32 %v
}

define i64 @LDURXi(ptr "reg"="xsp" %n, i64 "imm" %off) "enc"="11 111 0 00 01 0 off:s9 00 n:5 d:5" "asm"="ldur {d}, [{n}, #{off}]" {
  %p = getelementptr i8, ptr %n, i64 %off
  %v = load i64, ptr %p
  ret i64 %v
}

define ptr @LDURPi(ptr "reg"="xsp" %n, i64 "imm" %off) "enc"="11 111 0 00 01 0 off:s9 00 n:5 d:5" "asm"="ldur {d}, [{n}, #{off}]" "nodecode" {
  %p = getelementptr i8, ptr %n, i64 %off
  %v = load ptr, ptr %p
  ret ptr %v
}

define void @STURBi(i8 "reg"="w" %t, ptr "reg"="xsp" %n, i64 "imm" %off) "enc"="00 111 0 00 00 0 off:s9 00 n:5 t:5" "asm"="sturb {t}, [{n}, #{off}]" {
  %p = getelementptr i8, ptr %n, i64 %off
  store i8 %t, ptr %p
  ret void
}

define void @STURWi(i32 "reg"="w" %t, ptr "reg"="xsp" %n, i64 "imm" %off) "enc"="10 111 0 00 00 0 off:s9 00 n:5 t:5" "asm"="stur {t}, [{n}, #{off}]" {
  %p = getelementptr i8, ptr %n, i64 %off
  store i32 %t, ptr %p
  ret void
}

define void @STURXi(i64 "reg"="x" %t, ptr "reg"="xsp" %n, i64 "imm" %off) "enc"="11 111 0 00 00 0 off:s9 00 n:5 t:5" "asm"="stur {t}, [{n}, #{off}]" {
  %p = getelementptr i8, ptr %n, i64 %off
  store i64 %t, ptr %p
  ret void
}

define void @STURPi(ptr "reg"="x" %t, ptr "reg"="xsp" %n, i64 "imm" %off) "enc"="11 111 0 00 00 0 off:s9 00 n:5 t:5" "asm"="stur {t}, [{n}, #{off}]" "nodecode" {
  %p = getelementptr i8, ptr %n, i64 %off
  store ptr %t, ptr %p
  ret void
}

; Post-increment: load or store at the base, then step the base. The
; stepped base is a second result, written back to the base register.

define { i8, ptr } @LDRBpost(ptr "reg"="xsp" "writeback" %n, i64 "imm" %off) "enc"="00 111 0 00 01 0 off:s9 01 n:5 d:5" "asm"="ldrb {d}, [{n}], #{off}" "zext"="8" {
  %v = load i8, ptr %n
  %next = getelementptr i8, ptr %n, i64 %off
  %a = insertvalue { i8, ptr } poison, i8 %v, 0
  %b = insertvalue { i8, ptr } %a, ptr %next, 1
  ret { i8, ptr } %b
}

define { i16, ptr } @LDRHpost(ptr "reg"="xsp" "writeback" %n, i64 "imm" %off) "enc"="01 111 0 00 01 0 off:s9 01 n:5 d:5" "asm"="ldrh {d}, [{n}], #{off}" "zext"="16" {
  %v = load i16, ptr %n
  %next = getelementptr i8, ptr %n, i64 %off
  %a = insertvalue { i16, ptr } poison, i16 %v, 0
  %b = insertvalue { i16, ptr } %a, ptr %next, 1
  ret { i16, ptr } %b
}

define { i32, ptr } @LDRWpost(ptr "reg"="xsp" "writeback" %n, i64 "imm" %off) "enc"="10 111 0 00 01 0 off:s9 01 n:5 d:5" "asm"="ldr {d}, [{n}], #{off}" {
  %v = load i32, ptr %n
  %next = getelementptr i8, ptr %n, i64 %off
  %a = insertvalue { i32, ptr } poison, i32 %v, 0
  %b = insertvalue { i32, ptr } %a, ptr %next, 1
  ret { i32, ptr } %b
}

define { i64, ptr } @LDRXpost(ptr "reg"="xsp" "writeback" %n, i64 "imm" %off) "enc"="11 111 0 00 01 0 off:s9 01 n:5 d:5" "asm"="ldr {d}, [{n}], #{off}" {
  %v = load i64, ptr %n
  %next = getelementptr i8, ptr %n, i64 %off
  %a = insertvalue { i64, ptr } poison, i64 %v, 0
  %b = insertvalue { i64, ptr } %a, ptr %next, 1
  ret { i64, ptr } %b
}

define { ptr, ptr } @LDRPpost(ptr "reg"="xsp" "writeback" %n, i64 "imm" %off) "enc"="11 111 0 00 01 0 off:s9 01 n:5 d:5" "asm"="ldr {d}, [{n}], #{off}" "nodecode" {
  %v = load ptr, ptr %n
  %next = getelementptr i8, ptr %n, i64 %off
  %a = insertvalue { ptr, ptr } poison, ptr %v, 0
  %b = insertvalue { ptr, ptr } %a, ptr %next, 1
  ret { ptr, ptr } %b
}

define { i32, ptr } @LDRSBWpost(ptr "reg"="xsp" "writeback" %n, i64 "imm" %off) "enc"="00 111 0 00 11 0 off:s9 01 n:5 d:5" "asm"="ldrsb {d}, [{n}], #{off}" {
  %v = load i8, ptr %n
  %x = sext i8 %v to i32
  %next = getelementptr i8, ptr %n, i64 %off
  %a = insertvalue { i32, ptr } poison, i32 %x, 0
  %b = insertvalue { i32, ptr } %a, ptr %next, 1
  ret { i32, ptr } %b
}

define { i64, ptr } @LDRSBXpost(ptr "reg"="xsp" "writeback" %n, i64 "imm" %off) "enc"="00 111 0 00 10 0 off:s9 01 n:5 d:5" "asm"="ldrsb {d}, [{n}], #{off}" {
  %v = load i8, ptr %n
  %x = sext i8 %v to i64
  %next = getelementptr i8, ptr %n, i64 %off
  %a = insertvalue { i64, ptr } poison, i64 %x, 0
  %b = insertvalue { i64, ptr } %a, ptr %next, 1
  ret { i64, ptr } %b
}

define { i32, ptr } @LDRSHWpost(ptr "reg"="xsp" "writeback" %n, i64 "imm" %off) "enc"="01 111 0 00 11 0 off:s9 01 n:5 d:5" "asm"="ldrsh {d}, [{n}], #{off}" {
  %v = load i16, ptr %n
  %x = sext i16 %v to i32
  %next = getelementptr i8, ptr %n, i64 %off
  %a = insertvalue { i32, ptr } poison, i32 %x, 0
  %b = insertvalue { i32, ptr } %a, ptr %next, 1
  ret { i32, ptr } %b
}

define { i64, ptr } @LDRSHXpost(ptr "reg"="xsp" "writeback" %n, i64 "imm" %off) "enc"="01 111 0 00 10 0 off:s9 01 n:5 d:5" "asm"="ldrsh {d}, [{n}], #{off}" {
  %v = load i16, ptr %n
  %x = sext i16 %v to i64
  %next = getelementptr i8, ptr %n, i64 %off
  %a = insertvalue { i64, ptr } poison, i64 %x, 0
  %b = insertvalue { i64, ptr } %a, ptr %next, 1
  ret { i64, ptr } %b
}

define { i64, ptr } @LDRSWpost(ptr "reg"="xsp" "writeback" %n, i64 "imm" %off) "enc"="10 111 0 00 10 0 off:s9 01 n:5 d:5" "asm"="ldrsw {d}, [{n}], #{off}" {
  %v = load i32, ptr %n
  %x = sext i32 %v to i64
  %next = getelementptr i8, ptr %n, i64 %off
  %a = insertvalue { i64, ptr } poison, i64 %x, 0
  %b = insertvalue { i64, ptr } %a, ptr %next, 1
  ret { i64, ptr } %b
}

define ptr @STRBpost(i8 "reg"="w" %t, ptr "reg"="xsp" "writeback" %n, i64 "imm" %off) "enc"="00 111 0 00 00 0 off:s9 01 n:5 t:5" "asm"="strb {t}, [{n}], #{off}" {
  store i8 %t, ptr %n
  %next = getelementptr i8, ptr %n, i64 %off
  ret ptr %next
}

define ptr @STRHpost(i16 "reg"="w" %t, ptr "reg"="xsp" "writeback" %n, i64 "imm" %off) "enc"="01 111 0 00 00 0 off:s9 01 n:5 t:5" "asm"="strh {t}, [{n}], #{off}" {
  store i16 %t, ptr %n
  %next = getelementptr i8, ptr %n, i64 %off
  ret ptr %next
}

define ptr @STRWpost(i32 "reg"="w" %t, ptr "reg"="xsp" "writeback" %n, i64 "imm" %off) "enc"="10 111 0 00 00 0 off:s9 01 n:5 t:5" "asm"="str {t}, [{n}], #{off}" {
  store i32 %t, ptr %n
  %next = getelementptr i8, ptr %n, i64 %off
  ret ptr %next
}

define ptr @STRXpost(i64 "reg"="x" %t, ptr "reg"="xsp" "writeback" %n, i64 "imm" %off) "enc"="11 111 0 00 00 0 off:s9 01 n:5 t:5" "asm"="str {t}, [{n}], #{off}" {
  store i64 %t, ptr %n
  %next = getelementptr i8, ptr %n, i64 %off
  ret ptr %next
}

define ptr @STRPpost(ptr "reg"="x" %t, ptr "reg"="xsp" "writeback" %n, i64 "imm" %off) "enc"="11 111 0 00 00 0 off:s9 01 n:5 t:5" "asm"="str {t}, [{n}], #{off}" "nodecode" {
  store ptr %t, ptr %n
  %next = getelementptr i8, ptr %n, i64 %off
  ret ptr %next
}

; Register offsets, shifted by the size.
define i32 @LDRWroX(ptr "reg"="xsp" %n, i64 "reg"="x" %m) "enc"="10 111 0 00 01 1 m:5 011 1 10 n:5 d:5" "asm"="ldr {d}, [{n}, {m}, lsl #2]" {
  %o = shl i64 %m, 2
  %p = getelementptr i8, ptr %n, i64 %o
  %v = load i32, ptr %p
  ret i32 %v
}

define i64 @LDRXroX(ptr "reg"="xsp" %n, i64 "reg"="x" %m) "enc"="11 111 0 00 01 1 m:5 011 1 10 n:5 d:5" "asm"="ldr {d}, [{n}, {m}, lsl #3]" {
  %o = shl i64 %m, 3
  %p = getelementptr i8, ptr %n, i64 %o
  %v = load i64, ptr %p
  ret i64 %v
}

define ptr @LDRProX(ptr "reg"="xsp" %n, i64 "reg"="x" %m) "enc"="11 111 0 00 01 1 m:5 011 1 10 n:5 d:5" "asm"="ldr {d}, [{n}, {m}, lsl #3]" "nodecode" {
  %o = shl i64 %m, 3
  %p = getelementptr i8, ptr %n, i64 %o
  %v = load ptr, ptr %p
  ret ptr %v
}

define i8 @LDRBroX(ptr "reg"="xsp" %n, i64 "reg"="x" %m) "enc"="00 111 0 00 01 1 m:5 011 0 10 n:5 d:5" "asm"="ldrb {d}, [{n}, {m}]" "zext"="8" {
  %p = getelementptr i8, ptr %n, i64 %m
  %v = load i8, ptr %p
  ret i8 %v
}

define i32 @LDRSBWroX(ptr "reg"="xsp" %n, i64 "reg"="x" %m) "enc"="00 111 0 00 11 1 m:5 011 0 10 n:5 d:5" "asm"="ldrsb {d}, [{n}, {m}]" {
  %p = getelementptr i8, ptr %n, i64 %m
  %v = load i8, ptr %p
  %r = sext i8 %v to i32
  ret i32 %r
}

define i32 @LDRWroW(ptr "reg"="xsp" %n, i32 "reg"="w" %m) "enc"="10 111 0 00 01 1 m:5 110 1 10 n:5 d:5" "asm"="ldr {d}, [{n}, {m}, sxtw #2]" {
  %e = sext i32 %m to i64
  %o = shl i64 %e, 2
  %p = getelementptr i8, ptr %n, i64 %o
  %v = load i32, ptr %p
  ret i32 %v
}

; Register offsets with sign extension of the loaded value: ldrsw, ldrsh,
; ldrsb into X, and halfwords.
define i64 @LDRSWroX(ptr "reg"="xsp" %n, i64 "reg"="x" %m) "enc"="10 111 0 00 10 1 m:5 011 1 10 n:5 d:5" "asm"="ldrsw {d}, [{n}, {m}, lsl #2]" {
  %o = shl i64 %m, 2
  %p = getelementptr i8, ptr %n, i64 %o
  %v = load i32, ptr %p
  %r = sext i32 %v to i64
  ret i64 %r
}

define i64 @LDRSWroW(ptr "reg"="xsp" %n, i32 "reg"="w" %m) "enc"="10 111 0 00 10 1 m:5 110 1 10 n:5 d:5" "asm"="ldrsw {d}, [{n}, {m}, sxtw #2]" {
  %e = sext i32 %m to i64
  %o = shl i64 %e, 2
  %p = getelementptr i8, ptr %n, i64 %o
  %v = load i32, ptr %p
  %r = sext i32 %v to i64
  ret i64 %r
}

define i16 @LDRHroX(ptr "reg"="xsp" %n, i64 "reg"="x" %m) "enc"="01 111 0 00 01 1 m:5 011 1 10 n:5 d:5" "asm"="ldrh {d}, [{n}, {m}, lsl #1]" "zext"="16" {
  %o = shl i64 %m, 1
  %p = getelementptr i8, ptr %n, i64 %o
  %v = load i16, ptr %p
  ret i16 %v
}

define i32 @LDRSHWroX(ptr "reg"="xsp" %n, i64 "reg"="x" %m) "enc"="01 111 0 00 11 1 m:5 011 1 10 n:5 d:5" "asm"="ldrsh {d}, [{n}, {m}, lsl #1]" {
  %o = shl i64 %m, 1
  %p = getelementptr i8, ptr %n, i64 %o
  %v = load i16, ptr %p
  %r = sext i16 %v to i32
  ret i32 %r
}

define i64 @LDRSHXroX(ptr "reg"="xsp" %n, i64 "reg"="x" %m) "enc"="01 111 0 00 10 1 m:5 011 1 10 n:5 d:5" "asm"="ldrsh {d}, [{n}, {m}, lsl #1]" {
  %o = shl i64 %m, 1
  %p = getelementptr i8, ptr %n, i64 %o
  %v = load i16, ptr %p
  %r = sext i16 %v to i64
  ret i64 %r
}

define i64 @LDRSBXroX(ptr "reg"="xsp" %n, i64 "reg"="x" %m) "enc"="00 111 0 00 10 1 m:5 011 0 10 n:5 d:5" "asm"="ldrsb {d}, [{n}, {m}]" {
  %p = getelementptr i8, ptr %n, i64 %m
  %v = load i8, ptr %p
  %r = sext i8 %v to i64
  ret i64 %r
}

define void @STRHroX(i16 "reg"="w" %t, ptr "reg"="xsp" %n, i64 "reg"="x" %m) "enc"="01 111 0 00 00 1 m:5 011 1 10 n:5 t:5" "asm"="strh {t}, [{n}, {m}, lsl #1]" {
  %o = shl i64 %m, 1
  %p = getelementptr i8, ptr %n, i64 %o
  store i16 %t, ptr %p
  ret void
}

define void @STRWroX(i32 "reg"="w" %t, ptr "reg"="xsp" %n, i64 "reg"="x" %m) "enc"="10 111 0 00 00 1 m:5 011 1 10 n:5 t:5" "asm"="str {t}, [{n}, {m}, lsl #2]" {
  %o = shl i64 %m, 2
  %p = getelementptr i8, ptr %n, i64 %o
  store i32 %t, ptr %p
  ret void
}

define void @STRXroX(i64 "reg"="x" %t, ptr "reg"="xsp" %n, i64 "reg"="x" %m) "enc"="11 111 0 00 00 1 m:5 011 1 10 n:5 t:5" "asm"="str {t}, [{n}, {m}, lsl #3]" {
  %o = shl i64 %m, 3
  %p = getelementptr i8, ptr %n, i64 %o
  store i64 %t, ptr %p
  ret void
}

define void @STRBroX(i8 "reg"="w" %t, ptr "reg"="xsp" %n, i64 "reg"="x" %m) "enc"="00 111 0 00 00 1 m:5 011 0 10 n:5 t:5" "asm"="strb {t}, [{n}, {m}]" {
  %p = getelementptr i8, ptr %n, i64 %m
  store i8 %t, ptr %p
  ret void
}

define void @STRWroW(i32 "reg"="w" %t, ptr "reg"="xsp" %n, i32 "reg"="w" %m) "enc"="10 111 0 00 00 1 m:5 110 1 10 n:5 t:5" "asm"="str {t}, [{n}, {m}, sxtw #2]" {
  %e = sext i32 %m to i64
  %o = shl i64 %e, 2
  %p = getelementptr i8, ptr %n, i64 %o
  store i32 %t, ptr %p
  ret void
}

; ===========================================================================
; Atomics: acquire loads, release stores and fences. (Weaker atomic loads and
; stores are plain ones, which are single-copy atomic when aligned.)

define i8 @LDARB(ptr "reg"="xsp" %n) "enc"="00 001000 1 1 0 11111 1 11111 n:5 d:5" "asm"="ldarb {d}, [{n}]" {
  %v = load atomic i8, ptr %n acquire, align 1
  ret i8 %v
}

define void @STLRB(i8 "reg"="w" %t, ptr "reg"="xsp" %n) "enc"="00 001000 1 0 0 11111 1 11111 n:5 t:5" "asm"="stlrb {t}, [{n}]" {
  store atomic i8 %t, ptr %n release, align 1
  ret void
}

define i16 @LDARH(ptr "reg"="xsp" %n) "enc"="01 001000 1 1 0 11111 1 11111 n:5 d:5" "asm"="ldarh {d}, [{n}]" {
  %v = load atomic i16, ptr %n acquire, align 2
  ret i16 %v
}

define void @STLRH(i16 "reg"="w" %t, ptr "reg"="xsp" %n) "enc"="01 001000 1 0 0 11111 1 11111 n:5 t:5" "asm"="stlrh {t}, [{n}]" {
  store atomic i16 %t, ptr %n release, align 2
  ret void
}

define i32 @LDARW(ptr "reg"="xsp" %n) "enc"="10 001000 1 1 0 11111 1 11111 n:5 d:5" "asm"="ldar {d}, [{n}]" {
  %v = load atomic i32, ptr %n acquire, align 4
  ret i32 %v
}

define void @STLRW(i32 "reg"="w" %t, ptr "reg"="xsp" %n) "enc"="10 001000 1 0 0 11111 1 11111 n:5 t:5" "asm"="stlr {t}, [{n}]" {
  store atomic i32 %t, ptr %n release, align 4
  ret void
}

define i64 @LDARX(ptr "reg"="xsp" %n) "enc"="11 001000 1 1 0 11111 1 11111 n:5 d:5" "asm"="ldar {d}, [{n}]" {
  %v = load atomic i64, ptr %n acquire, align 8
  ret i64 %v
}

define void @STLRX(i64 "reg"="x" %t, ptr "reg"="xsp" %n) "enc"="11 001000 1 0 0 11111 1 11111 n:5 t:5" "asm"="stlr {t}, [{n}]" {
  store atomic i64 %t, ptr %n release, align 8
  ret void
}

define ptr @LDARP(ptr "reg"="xsp" %n) "enc"="11 001000 1 1 0 11111 1 11111 n:5 d:5" "asm"="ldar {d}, [{n}]" "nodecode" {
  %v = load atomic ptr, ptr %n acquire, align 8
  ret ptr %v
}

define void @STLRP(ptr "reg"="x" %t, ptr "reg"="xsp" %n) "enc"="11 001000 1 0 0 11111 1 11111 n:5 t:5" "asm"="stlr {t}, [{n}]" "nodecode" {
  store atomic ptr %t, ptr %n release, align 8
  ret void
}

define void @DMBISH() "enc"="11010101000000110011 1011 1 01 11111" "asm"="dmb ish" {
  fence seq_cst
  ret void
}

define void @DMBISHLD() "enc"="11010101000000110011 1001 1 01 11111" "asm"="dmb ishld" {
  fence acquire
  ret void
}

