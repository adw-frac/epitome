; The AArch64 description: load and store pairs. The conventions are in
; 00-base.ll. This file is written by gen_from_mrs.py.
;
; Encodings in this file are taken from Arm's A-profile Architecture Machine
; Readable Specification (AARCHMRS, 2026-09_rel), under this license:
;
; Copyright 2010-2026 Arm Limited or its affiliates.
;
; Redistribution and use in source and binary forms, with or without
; modification, are permitted provided that the following conditions are met:
;
; 1. Redistributions of source code must retain the above copyright notice,
;    this list of conditions and the following disclaimer.
; 2. Redistributions in binary form must reproduce the above copyright
;    notice, this list of conditions and the following disclaimer in the
;    documentation and/or other materials provided with the distribution.
; 3. Neither the name of the copyright holder nor the names of its
;    contributors may be used to endorse or promote products derived from
;    this software without specific prior written permission.
;
; THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
; AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
; IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
; ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
; LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
; CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
; SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
; INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
; CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
; ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
; POSSIBILITY OF SUCH DAMAGE.

; ===========================================================================
; Load and store pairs: two registers to or from two neighbouring slots,
; at an offset scaled by their size, before or after stepping the base. A
; load's second register is its second result ("result2"). They are not
; patterns: frames use them by role, to save and restore registers.

define { i32, i32 } @LDPWi(ptr "reg"="xsp" %n, i64 "imm" %off) "enc"="0010100101 imm7:s7=off/4 d2:5 n:5 d:5" "asm"="ldp {d}, {d2}, [{n}, #{off}]" "result2" "nomatch" {
  %p = getelementptr i8, ptr %n, i64 %off
  %a = load i32, ptr %p
  %q = getelementptr i8, ptr %p, i64 4
  %b = load i32, ptr %q
  %r0 = insertvalue { i32, i32 } poison, i32 %a, 0
  %r1 = insertvalue { i32, i32 } %r0, i32 %b, 1
  ret { i32, i32 } %r1
}

define void @STPWi(i32 "reg"="w" %t, i32 "reg"="w" %t2, ptr "reg"="xsp" %n, i64 "imm" %off) "enc"="0010100100 imm7:s7=off/4 t2:5 n:5 t:5" "asm"="stp {t}, {t2}, [{n}, #{off}]" "nomatch" {
  %p = getelementptr i8, ptr %n, i64 %off
  store i32 %t, ptr %p
  %q = getelementptr i8, ptr %p, i64 4
  store i32 %t2, ptr %q
  ret void
}

define { i32, i32, ptr } @LDPWpre(ptr "reg"="xsp" "writeback" %n, i64 "imm" %off) "enc"="0010100111 imm7:s7=off/4 d2:5 n:5 d:5" "asm"="ldp {d}, {d2}, [{n}, #{off}]!" "result2" "nomatch" {
  %p = getelementptr i8, ptr %n, i64 %off
  %a = load i32, ptr %p
  %q = getelementptr i8, ptr %p, i64 4
  %b = load i32, ptr %q
  %r0 = insertvalue { i32, i32, ptr } poison, i32 %a, 0
  %r1 = insertvalue { i32, i32, ptr } %r0, i32 %b, 1
  %r2 = insertvalue { i32, i32, ptr } %r1, ptr %p, 2
  ret { i32, i32, ptr } %r2
}

define ptr @STPWpre(i32 "reg"="w" %t, i32 "reg"="w" %t2, ptr "reg"="xsp" "writeback" %n, i64 "imm" %off) "enc"="0010100110 imm7:s7=off/4 t2:5 n:5 t:5" "asm"="stp {t}, {t2}, [{n}, #{off}]!" "nomatch" {
  %p = getelementptr i8, ptr %n, i64 %off
  store i32 %t, ptr %p
  %q = getelementptr i8, ptr %p, i64 4
  store i32 %t2, ptr %q
  ret ptr %p
}

define { i32, i32, ptr } @LDPWpost(ptr "reg"="xsp" "writeback" %n, i64 "imm" %off) "enc"="0010100011 imm7:s7=off/4 d2:5 n:5 d:5" "asm"="ldp {d}, {d2}, [{n}], #{off}" "result2" "nomatch" {
  %a = load i32, ptr %n
  %q = getelementptr i8, ptr %n, i64 4
  %b = load i32, ptr %q
  %r0 = insertvalue { i32, i32, ptr } poison, i32 %a, 0
  %r1 = insertvalue { i32, i32, ptr } %r0, i32 %b, 1
  %next = getelementptr i8, ptr %n, i64 %off
  %r2 = insertvalue { i32, i32, ptr } %r1, ptr %next, 2
  ret { i32, i32, ptr } %r2
}

define ptr @STPWpost(i32 "reg"="w" %t, i32 "reg"="w" %t2, ptr "reg"="xsp" "writeback" %n, i64 "imm" %off) "enc"="0010100010 imm7:s7=off/4 t2:5 n:5 t:5" "asm"="stp {t}, {t2}, [{n}], #{off}" "nomatch" {
  store i32 %t, ptr %n
  %q = getelementptr i8, ptr %n, i64 4
  store i32 %t2, ptr %q
  %next = getelementptr i8, ptr %n, i64 %off
  ret ptr %next
}

define { i64, i64 } @LDPXi(ptr "reg"="xsp" %n, i64 "imm" %off) "enc"="1010100101 imm7:s7=off/8 d2:5 n:5 d:5" "asm"="ldp {d}, {d2}, [{n}, #{off}]" "result2" "role"="load.pair.x" "nomatch" {
  %p = getelementptr i8, ptr %n, i64 %off
  %a = load i64, ptr %p
  %q = getelementptr i8, ptr %p, i64 8
  %b = load i64, ptr %q
  %r0 = insertvalue { i64, i64 } poison, i64 %a, 0
  %r1 = insertvalue { i64, i64 } %r0, i64 %b, 1
  ret { i64, i64 } %r1
}

define void @STPXi(i64 "reg"="x" %t, i64 "reg"="x" %t2, ptr "reg"="xsp" %n, i64 "imm" %off) "enc"="1010100100 imm7:s7=off/8 t2:5 n:5 t:5" "asm"="stp {t}, {t2}, [{n}, #{off}]" "role"="store.pair.x" "nomatch" {
  %p = getelementptr i8, ptr %n, i64 %off
  store i64 %t, ptr %p
  %q = getelementptr i8, ptr %p, i64 8
  store i64 %t2, ptr %q
  ret void
}

define { i64, i64, ptr } @LDPXpre(ptr "reg"="xsp" "writeback" %n, i64 "imm" %off) "enc"="1010100111 imm7:s7=off/8 d2:5 n:5 d:5" "asm"="ldp {d}, {d2}, [{n}, #{off}]!" "result2" "nomatch" {
  %p = getelementptr i8, ptr %n, i64 %off
  %a = load i64, ptr %p
  %q = getelementptr i8, ptr %p, i64 8
  %b = load i64, ptr %q
  %r0 = insertvalue { i64, i64, ptr } poison, i64 %a, 0
  %r1 = insertvalue { i64, i64, ptr } %r0, i64 %b, 1
  %r2 = insertvalue { i64, i64, ptr } %r1, ptr %p, 2
  ret { i64, i64, ptr } %r2
}

define ptr @STPXpre(i64 "reg"="x" %t, i64 "reg"="x" %t2, ptr "reg"="xsp" "writeback" %n, i64 "imm" %off) "enc"="1010100110 imm7:s7=off/8 t2:5 n:5 t:5" "asm"="stp {t}, {t2}, [{n}, #{off}]!" "nomatch" {
  %p = getelementptr i8, ptr %n, i64 %off
  store i64 %t, ptr %p
  %q = getelementptr i8, ptr %p, i64 8
  store i64 %t2, ptr %q
  ret ptr %p
}

define { i64, i64, ptr } @LDPXpost(ptr "reg"="xsp" "writeback" %n, i64 "imm" %off) "enc"="1010100011 imm7:s7=off/8 d2:5 n:5 d:5" "asm"="ldp {d}, {d2}, [{n}], #{off}" "result2" "nomatch" {
  %a = load i64, ptr %n
  %q = getelementptr i8, ptr %n, i64 8
  %b = load i64, ptr %q
  %r0 = insertvalue { i64, i64, ptr } poison, i64 %a, 0
  %r1 = insertvalue { i64, i64, ptr } %r0, i64 %b, 1
  %next = getelementptr i8, ptr %n, i64 %off
  %r2 = insertvalue { i64, i64, ptr } %r1, ptr %next, 2
  ret { i64, i64, ptr } %r2
}

define ptr @STPXpost(i64 "reg"="x" %t, i64 "reg"="x" %t2, ptr "reg"="xsp" "writeback" %n, i64 "imm" %off) "enc"="1010100010 imm7:s7=off/8 t2:5 n:5 t:5" "asm"="stp {t}, {t2}, [{n}], #{off}" "nomatch" {
  store i64 %t, ptr %n
  %q = getelementptr i8, ptr %n, i64 8
  store i64 %t2, ptr %q
  %next = getelementptr i8, ptr %n, i64 %off
  ret ptr %next
}

define { float, float } @LDPSi(ptr "reg"="xsp" %n, i64 "imm" %off) "enc"="0010110101 imm7:s7=off/4 d2:5 n:5 d:5" "asm"="ldp {d}, {d2}, [{n}, #{off}]" "result2" "nomatch" {
  %p = getelementptr i8, ptr %n, i64 %off
  %a = load float, ptr %p
  %q = getelementptr i8, ptr %p, i64 4
  %b = load float, ptr %q
  %r0 = insertvalue { float, float } poison, float %a, 0
  %r1 = insertvalue { float, float } %r0, float %b, 1
  ret { float, float } %r1
}

define void @STPSi(float "reg"="s" %t, float "reg"="s" %t2, ptr "reg"="xsp" %n, i64 "imm" %off) "enc"="0010110100 imm7:s7=off/4 t2:5 n:5 t:5" "asm"="stp {t}, {t2}, [{n}, #{off}]" "nomatch" {
  %p = getelementptr i8, ptr %n, i64 %off
  store float %t, ptr %p
  %q = getelementptr i8, ptr %p, i64 4
  store float %t2, ptr %q
  ret void
}

define { float, float, ptr } @LDPSpre(ptr "reg"="xsp" "writeback" %n, i64 "imm" %off) "enc"="0010110111 imm7:s7=off/4 d2:5 n:5 d:5" "asm"="ldp {d}, {d2}, [{n}, #{off}]!" "result2" "nomatch" {
  %p = getelementptr i8, ptr %n, i64 %off
  %a = load float, ptr %p
  %q = getelementptr i8, ptr %p, i64 4
  %b = load float, ptr %q
  %r0 = insertvalue { float, float, ptr } poison, float %a, 0
  %r1 = insertvalue { float, float, ptr } %r0, float %b, 1
  %r2 = insertvalue { float, float, ptr } %r1, ptr %p, 2
  ret { float, float, ptr } %r2
}

define ptr @STPSpre(float "reg"="s" %t, float "reg"="s" %t2, ptr "reg"="xsp" "writeback" %n, i64 "imm" %off) "enc"="0010110110 imm7:s7=off/4 t2:5 n:5 t:5" "asm"="stp {t}, {t2}, [{n}, #{off}]!" "nomatch" {
  %p = getelementptr i8, ptr %n, i64 %off
  store float %t, ptr %p
  %q = getelementptr i8, ptr %p, i64 4
  store float %t2, ptr %q
  ret ptr %p
}

define { float, float, ptr } @LDPSpost(ptr "reg"="xsp" "writeback" %n, i64 "imm" %off) "enc"="0010110011 imm7:s7=off/4 d2:5 n:5 d:5" "asm"="ldp {d}, {d2}, [{n}], #{off}" "result2" "nomatch" {
  %a = load float, ptr %n
  %q = getelementptr i8, ptr %n, i64 4
  %b = load float, ptr %q
  %r0 = insertvalue { float, float, ptr } poison, float %a, 0
  %r1 = insertvalue { float, float, ptr } %r0, float %b, 1
  %next = getelementptr i8, ptr %n, i64 %off
  %r2 = insertvalue { float, float, ptr } %r1, ptr %next, 2
  ret { float, float, ptr } %r2
}

define ptr @STPSpost(float "reg"="s" %t, float "reg"="s" %t2, ptr "reg"="xsp" "writeback" %n, i64 "imm" %off) "enc"="0010110010 imm7:s7=off/4 t2:5 n:5 t:5" "asm"="stp {t}, {t2}, [{n}], #{off}" "nomatch" {
  store float %t, ptr %n
  %q = getelementptr i8, ptr %n, i64 4
  store float %t2, ptr %q
  %next = getelementptr i8, ptr %n, i64 %off
  ret ptr %next
}

define { double, double } @LDPDi(ptr "reg"="xsp" %n, i64 "imm" %off) "enc"="0110110101 imm7:s7=off/8 d2:5 n:5 d:5" "asm"="ldp {d}, {d2}, [{n}, #{off}]" "result2" "role"="load.pair.d" "nomatch" {
  %p = getelementptr i8, ptr %n, i64 %off
  %a = load double, ptr %p
  %q = getelementptr i8, ptr %p, i64 8
  %b = load double, ptr %q
  %r0 = insertvalue { double, double } poison, double %a, 0
  %r1 = insertvalue { double, double } %r0, double %b, 1
  ret { double, double } %r1
}

define void @STPDi(double "reg"="d" %t, double "reg"="d" %t2, ptr "reg"="xsp" %n, i64 "imm" %off) "enc"="0110110100 imm7:s7=off/8 t2:5 n:5 t:5" "asm"="stp {t}, {t2}, [{n}, #{off}]" "role"="store.pair.d" "nomatch" {
  %p = getelementptr i8, ptr %n, i64 %off
  store double %t, ptr %p
  %q = getelementptr i8, ptr %p, i64 8
  store double %t2, ptr %q
  ret void
}

define { double, double, ptr } @LDPDpre(ptr "reg"="xsp" "writeback" %n, i64 "imm" %off) "enc"="0110110111 imm7:s7=off/8 d2:5 n:5 d:5" "asm"="ldp {d}, {d2}, [{n}, #{off}]!" "result2" "nomatch" {
  %p = getelementptr i8, ptr %n, i64 %off
  %a = load double, ptr %p
  %q = getelementptr i8, ptr %p, i64 8
  %b = load double, ptr %q
  %r0 = insertvalue { double, double, ptr } poison, double %a, 0
  %r1 = insertvalue { double, double, ptr } %r0, double %b, 1
  %r2 = insertvalue { double, double, ptr } %r1, ptr %p, 2
  ret { double, double, ptr } %r2
}

define ptr @STPDpre(double "reg"="d" %t, double "reg"="d" %t2, ptr "reg"="xsp" "writeback" %n, i64 "imm" %off) "enc"="0110110110 imm7:s7=off/8 t2:5 n:5 t:5" "asm"="stp {t}, {t2}, [{n}, #{off}]!" "nomatch" {
  %p = getelementptr i8, ptr %n, i64 %off
  store double %t, ptr %p
  %q = getelementptr i8, ptr %p, i64 8
  store double %t2, ptr %q
  ret ptr %p
}

define { double, double, ptr } @LDPDpost(ptr "reg"="xsp" "writeback" %n, i64 "imm" %off) "enc"="0110110011 imm7:s7=off/8 d2:5 n:5 d:5" "asm"="ldp {d}, {d2}, [{n}], #{off}" "result2" "nomatch" {
  %a = load double, ptr %n
  %q = getelementptr i8, ptr %n, i64 8
  %b = load double, ptr %q
  %r0 = insertvalue { double, double, ptr } poison, double %a, 0
  %r1 = insertvalue { double, double, ptr } %r0, double %b, 1
  %next = getelementptr i8, ptr %n, i64 %off
  %r2 = insertvalue { double, double, ptr } %r1, ptr %next, 2
  ret { double, double, ptr } %r2
}

define ptr @STPDpost(double "reg"="d" %t, double "reg"="d" %t2, ptr "reg"="xsp" "writeback" %n, i64 "imm" %off) "enc"="0110110010 imm7:s7=off/8 t2:5 n:5 t:5" "asm"="stp {t}, {t2}, [{n}], #{off}" "nomatch" {
  store double %t, ptr %n
  %q = getelementptr i8, ptr %n, i64 8
  store double %t2, ptr %q
  %next = getelementptr i8, ptr %n, i64 %off
  ret ptr %next
}

define { <2 x i64>, <2 x i64> } @LDPQi(ptr "reg"="xsp" %n, i64 "imm" %off) "enc"="1010110101 imm7:s7=off/16 d2:5 n:5 d:5" "asm"="ldp {d}, {d2}, [{n}, #{off}]" "result2" "nomatch" {
  %p = getelementptr i8, ptr %n, i64 %off
  %a = load <2 x i64>, ptr %p
  %q = getelementptr i8, ptr %p, i64 16
  %b = load <2 x i64>, ptr %q
  %r0 = insertvalue { <2 x i64>, <2 x i64> } poison, <2 x i64> %a, 0
  %r1 = insertvalue { <2 x i64>, <2 x i64> } %r0, <2 x i64> %b, 1
  ret { <2 x i64>, <2 x i64> } %r1
}

define void @STPQi(<2 x i64> "reg"="q" %t, <2 x i64> "reg"="q" %t2, ptr "reg"="xsp" %n, i64 "imm" %off) "enc"="1010110100 imm7:s7=off/16 t2:5 n:5 t:5" "asm"="stp {t}, {t2}, [{n}, #{off}]" "nomatch" {
  %p = getelementptr i8, ptr %n, i64 %off
  store <2 x i64> %t, ptr %p
  %q = getelementptr i8, ptr %p, i64 16
  store <2 x i64> %t2, ptr %q
  ret void
}

define { <2 x i64>, <2 x i64>, ptr } @LDPQpre(ptr "reg"="xsp" "writeback" %n, i64 "imm" %off) "enc"="1010110111 imm7:s7=off/16 d2:5 n:5 d:5" "asm"="ldp {d}, {d2}, [{n}, #{off}]!" "result2" "nomatch" {
  %p = getelementptr i8, ptr %n, i64 %off
  %a = load <2 x i64>, ptr %p
  %q = getelementptr i8, ptr %p, i64 16
  %b = load <2 x i64>, ptr %q
  %r0 = insertvalue { <2 x i64>, <2 x i64>, ptr } poison, <2 x i64> %a, 0
  %r1 = insertvalue { <2 x i64>, <2 x i64>, ptr } %r0, <2 x i64> %b, 1
  %r2 = insertvalue { <2 x i64>, <2 x i64>, ptr } %r1, ptr %p, 2
  ret { <2 x i64>, <2 x i64>, ptr } %r2
}

define ptr @STPQpre(<2 x i64> "reg"="q" %t, <2 x i64> "reg"="q" %t2, ptr "reg"="xsp" "writeback" %n, i64 "imm" %off) "enc"="1010110110 imm7:s7=off/16 t2:5 n:5 t:5" "asm"="stp {t}, {t2}, [{n}, #{off}]!" "nomatch" {
  %p = getelementptr i8, ptr %n, i64 %off
  store <2 x i64> %t, ptr %p
  %q = getelementptr i8, ptr %p, i64 16
  store <2 x i64> %t2, ptr %q
  ret ptr %p
}

define { <2 x i64>, <2 x i64>, ptr } @LDPQpost(ptr "reg"="xsp" "writeback" %n, i64 "imm" %off) "enc"="1010110011 imm7:s7=off/16 d2:5 n:5 d:5" "asm"="ldp {d}, {d2}, [{n}], #{off}" "result2" "nomatch" {
  %a = load <2 x i64>, ptr %n
  %q = getelementptr i8, ptr %n, i64 16
  %b = load <2 x i64>, ptr %q
  %r0 = insertvalue { <2 x i64>, <2 x i64>, ptr } poison, <2 x i64> %a, 0
  %r1 = insertvalue { <2 x i64>, <2 x i64>, ptr } %r0, <2 x i64> %b, 1
  %next = getelementptr i8, ptr %n, i64 %off
  %r2 = insertvalue { <2 x i64>, <2 x i64>, ptr } %r1, ptr %next, 2
  ret { <2 x i64>, <2 x i64>, ptr } %r2
}

define ptr @STPQpost(<2 x i64> "reg"="q" %t, <2 x i64> "reg"="q" %t2, ptr "reg"="xsp" "writeback" %n, i64 "imm" %off) "enc"="1010110010 imm7:s7=off/16 t2:5 n:5 t:5" "asm"="stp {t}, {t2}, [{n}], #{off}" "nomatch" {
  store <2 x i64> %t, ptr %n
  %q = getelementptr i8, ptr %n, i64 16
  store <2 x i64> %t2, ptr %q
  %next = getelementptr i8, ptr %n, i64 %off
  ret ptr %next
}

define { i64, i64 } @LDPSWi(ptr "reg"="xsp" %n, i64 "imm" %off) "enc"="0110100101 imm7:s7=off/4 d2:5 n:5 d:5" "asm"="ldpsw {d}, {d2}, [{n}, #{off}]" "result2" "nomatch" {
  %p = getelementptr i8, ptr %n, i64 %off
  %a = load i32, ptr %p
  %q = getelementptr i8, ptr %p, i64 4
  %b = load i32, ptr %q
  %sa = sext i32 %a to i64
  %sb = sext i32 %b to i64
  %r0 = insertvalue { i64, i64 } poison, i64 %sa, 0
  %r1 = insertvalue { i64, i64 } %r0, i64 %sb, 1
  ret { i64, i64 } %r1
}

define { i64, i64, ptr } @LDPSWpre(ptr "reg"="xsp" "writeback" %n, i64 "imm" %off) "enc"="0110100111 imm7:s7=off/4 d2:5 n:5 d:5" "asm"="ldpsw {d}, {d2}, [{n}, #{off}]!" "result2" "nomatch" {
  %p = getelementptr i8, ptr %n, i64 %off
  %a = load i32, ptr %p
  %q = getelementptr i8, ptr %p, i64 4
  %b = load i32, ptr %q
  %sa = sext i32 %a to i64
  %sb = sext i32 %b to i64
  %r0 = insertvalue { i64, i64, ptr } poison, i64 %sa, 0
  %r1 = insertvalue { i64, i64, ptr } %r0, i64 %sb, 1
  %r2 = insertvalue { i64, i64, ptr } %r1, ptr %p, 2
  ret { i64, i64, ptr } %r2
}

define { i64, i64, ptr } @LDPSWpost(ptr "reg"="xsp" "writeback" %n, i64 "imm" %off) "enc"="0110100011 imm7:s7=off/4 d2:5 n:5 d:5" "asm"="ldpsw {d}, {d2}, [{n}], #{off}" "result2" "nomatch" {
  %a = load i32, ptr %n
  %q = getelementptr i8, ptr %n, i64 4
  %b = load i32, ptr %q
  %sa = sext i32 %a to i64
  %sb = sext i32 %b to i64
  %r0 = insertvalue { i64, i64, ptr } poison, i64 %sa, 0
  %r1 = insertvalue { i64, i64, ptr } %r0, i64 %sb, 1
  %next = getelementptr i8, ptr %n, i64 %off
  %r2 = insertvalue { i64, i64, ptr } %r1, ptr %next, 2
  ret { i64, i64, ptr } %r2
}

