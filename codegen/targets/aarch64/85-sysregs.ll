; The AArch64 description: system registers by name, for inline assembly
; (`mrs x0, cntvct_el0`): those code at EL0 reads (timers, the
; floating-point control and status, the thread pointers, random numbers,
; the ID registers the kernel emulates), each as Arm's MRS and MSR
; encode them (op0 = 3). The generic form, s3_<op1>_c<n>_c<m>_<op2>, is
; 80-asm.ll's. Written by hand from Arm's register descriptions.

define void @MRS_nzcv(i64 "reg"="x" %xt) "enc"="1101010100111 011 0100 0010 000 xt:5" "asm"="mrs {xt}, nzcv" "asmonly" {
  ret void
}

define void @MSR_nzcv(i64 "reg"="x" %xt) "enc"="1101010100011 011 0100 0010 000 xt:5" "asm"="msr nzcv, {xt}" "asmonly" {
  ret void
}

define void @MRS_daif(i64 "reg"="x" %xt) "enc"="1101010100111 011 0100 0010 001 xt:5" "asm"="mrs {xt}, daif" "asmonly" {
  ret void
}

define void @MSR_daif(i64 "reg"="x" %xt) "enc"="1101010100011 011 0100 0010 001 xt:5" "asm"="msr daif, {xt}" "asmonly" {
  ret void
}

define void @MRS_fpcr(i64 "reg"="x" %xt) "enc"="1101010100111 011 0100 0100 000 xt:5" "asm"="mrs {xt}, fpcr" "asmonly" {
  ret void
}

define void @MSR_fpcr(i64 "reg"="x" %xt) "enc"="1101010100011 011 0100 0100 000 xt:5" "asm"="msr fpcr, {xt}" "asmonly" {
  ret void
}

define void @MRS_fpsr(i64 "reg"="x" %xt) "enc"="1101010100111 011 0100 0100 001 xt:5" "asm"="mrs {xt}, fpsr" "asmonly" {
  ret void
}

define void @MSR_fpsr(i64 "reg"="x" %xt) "enc"="1101010100011 011 0100 0100 001 xt:5" "asm"="msr fpsr, {xt}" "asmonly" {
  ret void
}

define void @MRS_dit(i64 "reg"="x" %xt) "enc"="1101010100111 011 0100 0010 101 xt:5" "asm"="mrs {xt}, dit" "asmonly" {
  ret void
}

define void @MSR_dit(i64 "reg"="x" %xt) "enc"="1101010100011 011 0100 0010 101 xt:5" "asm"="msr dit, {xt}" "asmonly" {
  ret void
}

define void @MRS_ssbs(i64 "reg"="x" %xt) "enc"="1101010100111 011 0100 0010 110 xt:5" "asm"="mrs {xt}, ssbs" "asmonly" {
  ret void
}

define void @MSR_ssbs(i64 "reg"="x" %xt) "enc"="1101010100011 011 0100 0010 110 xt:5" "asm"="msr ssbs, {xt}" "asmonly" {
  ret void
}

define void @MRS_tco(i64 "reg"="x" %xt) "enc"="1101010100111 011 0100 0010 111 xt:5" "asm"="mrs {xt}, tco" "asmonly" {
  ret void
}

define void @MSR_tco(i64 "reg"="x" %xt) "enc"="1101010100011 011 0100 0010 111 xt:5" "asm"="msr tco, {xt}" "asmonly" {
  ret void
}

define void @MRS_ctr_el0(i64 "reg"="x" %xt) "enc"="1101010100111 011 0000 0000 001 xt:5" "asm"="mrs {xt}, ctr_el0" "asmonly" {
  ret void
}

define void @MRS_dczid_el0(i64 "reg"="x" %xt) "enc"="1101010100111 011 0000 0000 111 xt:5" "asm"="mrs {xt}, dczid_el0" "asmonly" {
  ret void
}

define void @MRS_rndr(i64 "reg"="x" %xt) "enc"="1101010100111 011 0010 0100 000 xt:5" "asm"="mrs {xt}, rndr" "asmonly" {
  ret void
}

define void @MRS_rndrrs(i64 "reg"="x" %xt) "enc"="1101010100111 011 0010 0100 001 xt:5" "asm"="mrs {xt}, rndrrs" "asmonly" {
  ret void
}

define void @MRS_tpidr_el0(i64 "reg"="x" %xt) "enc"="1101010100111 011 1101 0000 010 xt:5" "asm"="mrs {xt}, tpidr_el0" "asmonly" {
  ret void
}

define void @MSR_tpidr_el0(i64 "reg"="x" %xt) "enc"="1101010100011 011 1101 0000 010 xt:5" "asm"="msr tpidr_el0, {xt}" "asmonly" {
  ret void
}

define void @MRS_tpidrro_el0(i64 "reg"="x" %xt) "enc"="1101010100111 011 1101 0000 011 xt:5" "asm"="mrs {xt}, tpidrro_el0" "asmonly" {
  ret void
}

define void @MRS_cntfrq_el0(i64 "reg"="x" %xt) "enc"="1101010100111 011 1110 0000 000 xt:5" "asm"="mrs {xt}, cntfrq_el0" "asmonly" {
  ret void
}

define void @MRS_cntpct_el0(i64 "reg"="x" %xt) "enc"="1101010100111 011 1110 0000 001 xt:5" "asm"="mrs {xt}, cntpct_el0" "asmonly" {
  ret void
}

define void @MRS_cntvct_el0(i64 "reg"="x" %xt) "enc"="1101010100111 011 1110 0000 010 xt:5" "asm"="mrs {xt}, cntvct_el0" "asmonly" {
  ret void
}

define void @MRS_cntpctss_el0(i64 "reg"="x" %xt) "enc"="1101010100111 011 1110 0000 101 xt:5" "asm"="mrs {xt}, cntpctss_el0" "asmonly" {
  ret void
}

define void @MRS_cntvctss_el0(i64 "reg"="x" %xt) "enc"="1101010100111 011 1110 0000 110 xt:5" "asm"="mrs {xt}, cntvctss_el0" "asmonly" {
  ret void
}

define void @MRS_midr_el1(i64 "reg"="x" %xt) "enc"="1101010100111 000 0000 0000 000 xt:5" "asm"="mrs {xt}, midr_el1" "asmonly" {
  ret void
}

define void @MRS_mpidr_el1(i64 "reg"="x" %xt) "enc"="1101010100111 000 0000 0000 101 xt:5" "asm"="mrs {xt}, mpidr_el1" "asmonly" {
  ret void
}

define void @MRS_revidr_el1(i64 "reg"="x" %xt) "enc"="1101010100111 000 0000 0000 110 xt:5" "asm"="mrs {xt}, revidr_el1" "asmonly" {
  ret void
}

define void @MRS_id_aa64isar0_el1(i64 "reg"="x" %xt) "enc"="1101010100111 000 0000 0110 000 xt:5" "asm"="mrs {xt}, id_aa64isar0_el1" "asmonly" {
  ret void
}

define void @MRS_id_aa64isar1_el1(i64 "reg"="x" %xt) "enc"="1101010100111 000 0000 0110 001 xt:5" "asm"="mrs {xt}, id_aa64isar1_el1" "asmonly" {
  ret void
}

define void @MRS_id_aa64isar2_el1(i64 "reg"="x" %xt) "enc"="1101010100111 000 0000 0110 010 xt:5" "asm"="mrs {xt}, id_aa64isar2_el1" "asmonly" {
  ret void
}

define void @MRS_id_aa64pfr0_el1(i64 "reg"="x" %xt) "enc"="1101010100111 000 0000 0100 000 xt:5" "asm"="mrs {xt}, id_aa64pfr0_el1" "asmonly" {
  ret void
}

define void @MRS_id_aa64pfr1_el1(i64 "reg"="x" %xt) "enc"="1101010100111 000 0000 0100 001 xt:5" "asm"="mrs {xt}, id_aa64pfr1_el1" "asmonly" {
  ret void
}

define void @MRS_id_aa64mmfr0_el1(i64 "reg"="x" %xt) "enc"="1101010100111 000 0000 0111 000 xt:5" "asm"="mrs {xt}, id_aa64mmfr0_el1" "asmonly" {
  ret void
}

define void @MRS_id_aa64mmfr1_el1(i64 "reg"="x" %xt) "enc"="1101010100111 000 0000 0111 001 xt:5" "asm"="mrs {xt}, id_aa64mmfr1_el1" "asmonly" {
  ret void
}

define void @MRS_id_aa64mmfr2_el1(i64 "reg"="x" %xt) "enc"="1101010100111 000 0000 0111 010 xt:5" "asm"="mrs {xt}, id_aa64mmfr2_el1" "asmonly" {
  ret void
}

define void @MRS_id_aa64zfr0_el1(i64 "reg"="x" %xt) "enc"="1101010100111 000 0000 0100 100 xt:5" "asm"="mrs {xt}, id_aa64zfr0_el1" "asmonly" {
  ret void
}

define void @MRS_id_aa64dfr0_el1(i64 "reg"="x" %xt) "enc"="1101010100111 000 0000 0101 000 xt:5" "asm"="mrs {xt}, id_aa64dfr0_el1" "asmonly" {
  ret void
}

define void @MRS_currentel(i64 "reg"="x" %xt) "enc"="1101010100111 000 0100 0010 010 xt:5" "asm"="mrs {xt}, currentel" "asmonly" {
  ret void
}
