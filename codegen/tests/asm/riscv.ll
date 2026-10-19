; Inline assembly for RISC-V, as clang would write it from C (clang here has
; no RISC-V target to write it): each constraint and modifier kind, early
; clobbers, tied and fixed registers, numeric labels, clobbers, memory.
; riscv.ref.c is the same in C, for the expected output.

define i64 @add_r(i64 %a, i64 %b) {
  %r = call i64 asm "add $0, $1, $2", "=r,r,r"(i64 %a, i64 %b)
  ret i64 %r
}

define i32 @addw_r(i32 %a, i32 %b) {
  %r = call i32 asm "addw $0, $1, $2", "=r,r,r"(i32 %a, i32 %b)
  ret i32 %r
}

; ${2:i}: addi for an immediate.
define i64 @add_I(i64 %a) {
  %r = call i64 asm "add${2:i} $0, $1, $2", "=r,r,I"(i64 %a, i64 -2048)
  ret i64 %r
}

define i64 @add_reg_or_imm(i64 %a, i64 %b) {
  %r = call i64 asm "add${2:i} $0, $1, $2", "=r,r,rI"(i64 %a, i64 %b)
  ret i64 %r
}

define i64 @shift_K(i64 %a) {
  %r = call i64 asm "slli $0, $1, $2", "=r,r,K"(i64 %a, i64 31)
  ret i64 %r
}

; ${2:z}: the zero register for a constant zero.
define i64 @or_zero(i64 %a) {
  %r = call i64 asm "or $0, $1, ${2:z}", "=r,r,rJ"(i64 %a, i64 0)
  ret i64 %r
}

define i32 @tied(i32 %a) {
  %r = call i32 asm "addiw $0, $0, 1", "=r,0"(i32 %a)
  ret i32 %r
}

define i32 @load(ptr %p) {
  %r = call i32 asm "lw $0, $1", "=r,*m"(ptr elementtype(i32) %p)
  ret i32 %r
}

define void @store(ptr %p, i32 %v) {
  call void asm sideeffect "sw $1, $0", "=*m,r"(ptr elementtype(i32) %p, i32 %v)
  ret void
}

define i64 @amo(ptr %p) {
  %r = call i64 asm "ld $0, $1", "=r,*A"(ptr elementtype(i64) %p)
  ret i64 %r
}

define double @fadd(double %a, double %b) {
  %r = call double asm "fadd.d $0, $1, $2", "=f,f,f"(double %a, double %b)
  ret double %r
}

define float @fmul(float %a, float %b) {
  %r = call float asm "fmul.s $0, $1, $2", "=f,f,f"(float %a, float %b)
  ret float %r
}

define i64 @early(i64 %a, i64 %b) {
  %r = call i64 asm "li $0, 1\0Aadd $0, $0, $1\0Aadd $0, $0, $2", "=&r,r,r"(i64 %a, i64 %b)
  ret i64 %r
}

define i64 @sum_to(i64 %n) {
  %r = call { i64, i64 } asm "1: beqz $1, 2f\0Aadd $0, $0, $1\0Aaddi $1, $1, -1\0Aj 1b\0A2:", "=r,=r,0,1"(i64 0, i64 %n)
  %s = extractvalue { i64, i64 } %r, 0
  ret i64 %s
}

define i64 @pair(ptr %p) {
  %r = call { i64, i64 } asm "ld $0, 0($2)\0Ald $1, 8($2)", "=r,=r,r"(ptr %p)
  %a = extractvalue { i64, i64 } %r, 0
  %b = extractvalue { i64, i64 } %r, 1
  %t = mul i64 %a, 10
  %s = add i64 %t, %b
  ret i64 %s
}

; Registers by name, as clang writes them ({x10} is a0).
define i64 @fixed(i64 %a) {
  %r = call i64 asm "add a0, a0, a0", "={x10},{x10}"(i64 %a)
  ret i64 %r
}

define i64 @clobber(i64 %a) {
  %r = call i64 asm "mv t0, $1\0Aaddi $0, t0, 3", "=r,r,~{x5}"(i64 %a)
  ret i64 %r
}

; Writes s1, which the caller expects kept: the frame must save it.
define i64 @saved(i64 %a) {
  call void asm sideeffect "li s1, 5", "~{x9}"()
  %r = add i64 %a, 1
  ret i64 %r
}

define void @barrier() {
  call void asm sideeffect "", "~{memory}"()
  ret void
}

; ${:uid}, unique to each block: twice in one function.
define i64 @uid(i64 %a) {
  %x = call i64 asm "mv $0, $1\0Aj .Lskip${:uid}\0Ali $0, 0\0A.Lskip${:uid}:", "=r,r"(i64 %a)
  %b = add i64 %a, 1
  %y = call i64 asm "mv $0, $1\0Aj .Lskip${:uid}\0Ali $0, 0\0A.Lskip${:uid}:", "=r,r"(i64 %b)
  %r = add i64 %x, %y
  ret i64 %r
}
