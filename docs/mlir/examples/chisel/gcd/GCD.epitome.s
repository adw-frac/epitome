	.build_version macos, 11, 0
	.section __TEXT,__text,regular,pure_instructions
	.p2align 2
	.globl _GCD_main
_GCD_main:
	.cfi_startproc
	sub sp, sp, #32
	.cfi_def_cfa_offset 32
	stp x29, x30, [sp, #16]
	stp x19, x20, [sp, #0]
	.cfi_offset x29, -16
	.cfi_offset x30, -8
	.cfi_offset x19, -32
	.cfi_offset x20, -24
	add x29, sp, #16
	adrp x0, _arcRuntimeModel_GCD@GOTPAGE
	ldr x0, [x0, _arcRuntimeModel_GCD@GOTPAGEOFF]
	mov x1, xzr
	bl _arcRuntimeIR_allocInstance
	mov x19, x0
	mov x0, x19
	bl _arcRuntimeIR_onInitialized
	add x20, x19, #16
	ldr x0, [x20, #0]
LBB0_1:
	cmn x0, #1
	b.eq LBB0_3
	str x0, [x19, #0]
	mov x0, x19
	bl _arcRuntimeIR_onEval
	mov x0, x19
	bl _GCD_eval
	ldr x0, [x20, #0]
	b LBB0_1
LBB0_3:
	mov x0, x19
	bl _arcRuntimeIR_deleteInstance
	ldp x29, x30, [sp, #16]
	ldp x19, x20, [sp, #0]
	add sp, sp, #32
	ret
	.cfi_endproc

	.p2align 2
	.globl _GCD_eval
_GCD_eval:
	.cfi_startproc
	mov x1, #-1
	str x1, [x0, #16]
	ldrb w1, [x0, #24]
	add x2, x0, #36
	ldrb w3, [x2, #0]
	and w4, w1, #0x1
	strb w4, [x2, #0]
	eor w2, w3, w1
	and w1, w2, w1
	tbz w1, #0, LBB1_2
	add x1, x0, #32
	ldrh w2, [x1, #0]
	add x3, x0, #34
	ldrh w4, [x3, #0]
	cmp w2, w4
	cset w5, hi
	add x6, x0, #30
	ldrb w7, [x6, #0]
	ldrh w8, [x0, #26]
	sub w4, w2, w4
	tst w5, #0x1
	csel w4, w4, w2, ne
	tst w7, #0x1
	csel w4, w8, w4, ne
	strh w4, [x1, #0]
	ldrh w1, [x3, #0]
	ldrb w4, [x6, #0]
	ldrh w6, [x0, #28]
	sub w2, w1, w2
	tst w5, #0x1
	csel w1, w1, w2, ne
	tst w4, #0x1
	csel w1, w6, w1, ne
	strh w1, [x3, #0]
LBB1_2:
	ldrh w1, [x0, #32]
	strh w1, [x0, #38]
	ldrh w1, [x0, #34]
	cmp w1, wzr
	cset w1, eq
	strb w1, [x0, #40]
	ret
	.cfi_endproc

	.section __TEXT,__const
	.p2align 0
__arc_mod_name_GCD:
	.ascii "GCD\000"

	.section __DATA,__data
	.globl _arcRuntimeModel_GCD
	.p2align 3
_arcRuntimeModel_GCD:
	.quad 1
	.quad 41
	.quad __arc_mod_name_GCD
	.space 8

