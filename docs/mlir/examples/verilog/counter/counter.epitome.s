	.build_version macos, 11, 0
	.section __TEXT,__text,regular,pure_instructions
	.p2align 2
	.globl _counter_main
_counter_main:
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
	adrp x0, _arcRuntimeModel_counter@GOTPAGE
	ldr x0, [x0, _arcRuntimeModel_counter@GOTPAGEOFF]
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
	bl _counter_eval
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
	.globl _counter_eval
_counter_eval:
	.cfi_startproc
	mov x1, #-1
	str x1, [x0, #16]
	ldrb w1, [x0, #24]
	add x2, x0, #27
	ldrb w3, [x2, #0]
	and w4, w1, #0x1
	strb w4, [x2, #0]
	eor w2, w3, w1
	and w1, w2, w1
	tbz w1, #0, LBB1_2
	add x1, x0, #28
	ldrb w2, [x1, #0]
	ldrb w3, [x0, #25]
	ldrb w4, [x0, #26]
	add w5, w2, #1
	eor w6, w3, #0x1
	and w6, w4, w6
	tst w6, #0x1
	csel w5, w5, wzr, ne
	orr w3, w3, w4
	tst w3, #0x1
	csel w2, w5, w2, ne
	strb w2, [x1, #0]
	ldrb w1, [x0, #28]
	strb w1, [x0, #29]
	ret
LBB1_2:
	ldrb w1, [x0, #28]
	strb w1, [x0, #29]
	ret
	.cfi_endproc

	.section __TEXT,__const
	.p2align 0
__arc_mod_name_counter:
	.ascii "counter\000"

	.section __DATA,__data
	.globl _arcRuntimeModel_counter
	.p2align 3
_arcRuntimeModel_counter:
	.quad 1
	.quad 30
	.quad __arc_mod_name_counter
	.space 8

