	.build_version macos, 11, 0
	.section __TEXT,__text,regular,pure_instructions
	.p2align 2
	.globl ___epitome_sme_matmul_f32
___epitome_sme_matmul_f32:
	.cfi_startproc
	sub sp, sp, #96
	.cfi_def_cfa_offset 96
	stp x29, x30, [sp, #80]
	str x19, [sp, #0]
	stp d8, d9, [sp, #8]
	stp d10, d11, [sp, #24]
	stp d12, d13, [sp, #40]
	stp d14, d15, [sp, #56]
	.cfi_offset x29, -16
	.cfi_offset x30, -8
	.cfi_offset x19, -96
	.cfi_offset d8, -88
	.cfi_offset d9, -80
	.cfi_offset d10, -72
	.cfi_offset d11, -64
	.cfi_offset d12, -56
	.cfi_offset d13, -48
	.cfi_offset d14, -40
	.cfi_offset d15, -32
	add x29, sp, #80
	smstart
	ptrue p0.s
	whilelt p1.s, xzr, x7
	mov x7, xzr
LBB0_1:
	mul x8, x7, x1
	add x19, x0, x8, lsl #2
	mov w8, w7
	mov w12, w8
	ld1w {za0h.s[w12, 0]}, p1/z, [x19]
	add x7, x7, #1
	cmp x7, #16
	b.lt LBB0_1
	cmp x6, xzr
	b.le LBB0_8
	mov x7, xzr
LBB0_4:
	mul x8, x7, x3
	add x8, x2, x8, lsl #2
	mul x9, x7, x5
	add x9, x4, x9, lsl #2
	ld1w {z0.s}, p0/z, [x8]
	ld1w {z1.s}, p1/z, [x9]
	fmopa za0.s, p0/m, p1/m, z0.s, z1.s
	add x7, x7, #1
	cmp x7, x6
	b.lt LBB0_4
	mov x2, xzr
LBB0_6:
	mul x3, x2, x1
	add x19, x0, x3, lsl #2
	mov w3, w2
	mov w12, w3
	st1w {za0h.s[w12, 0]}, p1, [x19]
	add x2, x2, #1
	cmp x2, #16
	b.lt LBB0_6
	smstop
	ldp x29, x30, [sp, #80]
	ldr x19, [sp, #0]
	ldp d8, d9, [sp, #8]
	ldp d10, d11, [sp, #24]
	ldp d12, d13, [sp, #40]
	ldp d14, d15, [sp, #56]
	add sp, sp, #96
	ret
LBB0_8:
	mov x2, xzr
	b LBB0_6
	.cfi_endproc

	.p2align 2
	.globl _matmul
_matmul:
	.cfi_startproc
	sub sp, sp, #144
	.cfi_def_cfa_offset 144
	stp x29, x30, [sp, #128]
	stp x19, x20, [sp, #0]
	stp x21, x22, [sp, #16]
	stp x23, x24, [sp, #32]
	stp x25, x26, [sp, #48]
	stp d8, d9, [sp, #64]
	stp d10, d11, [sp, #80]
	stp d12, d13, [sp, #96]
	stp d14, d15, [sp, #112]
	.cfi_offset x29, -16
	.cfi_offset x30, -8
	.cfi_offset x19, -144
	.cfi_offset x20, -136
	.cfi_offset x21, -128
	.cfi_offset x22, -120
	.cfi_offset x23, -112
	.cfi_offset x24, -104
	.cfi_offset x25, -96
	.cfi_offset x26, -88
	.cfi_offset d8, -80
	.cfi_offset d9, -72
	.cfi_offset d10, -64
	.cfi_offset d11, -56
	.cfi_offset d12, -48
	.cfi_offset d13, -40
	.cfi_offset d14, -32
	.cfi_offset d15, -24
	add x29, sp, #128
	mov x19, x0
	mov x20, x1
	mov x21, x2
	mov x0, #1280
	bl _malloc
	mov x22, x0
	mov x0, xzr
LBB1_1:
	mov x1, #20
	mul x1, x0, x1
	mov x2, xzr
LBB1_2:
	add x3, x1, x2
	str wzr, [x22, x3, lsl #2]
	add x2, x2, #1
	cmp x2, #20
	b.lt LBB1_2
	add x0, x0, #1
	cmp x0, #16
	b.lt LBB1_1
	mov x0, #256
	bl _malloc
	mov x1, xzr
LBB1_5:
	lsl x2, x1, #4
	mov x3, xzr
LBB1_6:
	add x4, x1, x3, lsl #2
	ldr s0, [x19, x4, lsl #2]
	add x4, x2, x3
	str s0, [x0, x4, lsl #2]
	add x3, x3, #1
	cmp x3, #16
	b.lt LBB1_6
	add x1, x1, #1
	cmp x1, #4
	b.lt LBB1_5
	mov x1, xzr
LBB1_9:
	mov x2, #20
	mul x19, x1, x2
	add x23, x0, x1, lsl #2
	mov x2, xzr
LBB1_10:
	mov x3, #20
	sub x3, x3, x2
	mov x4, #16
	cmp x3, #16
	csel x24, x3, x4, lt
	add x3, x19, x2
	add x25, x22, x3, lsl #2
	add x26, x20, x2, lsl #2
	smstart
	ptrue p0.s
	whilelt p1.s, xzr, x24
	mov x3, xzr
LBB1_11:
	mov x4, #20
	mul x4, x3, x4
	add x24, x25, x4, lsl #2
	mov w4, w3
	mov w12, w4
	ld1w {za0h.s[w12, 0]}, p1/z, [x24]
	add x3, x3, #1
	cmp x3, #16
	b.lt LBB1_11
	mov x3, xzr
LBB1_13:
	lsl x4, x3, #4
	add x4, x23, x4, lsl #2
	mov x5, #20
	mul x5, x3, x5
	add x5, x26, x5, lsl #2
	ld1w {z0.s}, p0/z, [x4]
	ld1w {z1.s}, p1/z, [x5]
	fmopa za0.s, p0/m, p1/m, z0.s, z1.s
	add x3, x3, #1
	cmp x3, #4
	b.lt LBB1_13
	mov x3, xzr
LBB1_15:
	mov x4, #20
	mul x4, x3, x4
	add x24, x25, x4, lsl #2
	mov w4, w3
	mov w12, w4
	st1w {za0h.s[w12, 0]}, p1, [x24]
	add x3, x3, #1
	cmp x3, #16
	b.lt LBB1_15
	smstop
	add x2, x2, #16
	cmp x2, #20
	b.lt LBB1_10
	add x1, x1, #16
	cmp x1, #16
	b.lt LBB1_9
	bl _free
	mov x2, #1280
	mov x0, x21
	mov x1, x22
	bl _memcpy
	mov x0, x22
	ldp x29, x30, [sp, #128]
	ldp x19, x20, [sp, #0]
	ldp x21, x22, [sp, #16]
	ldp x23, x24, [sp, #32]
	ldp x25, x26, [sp, #48]
	ldp d8, d9, [sp, #64]
	ldp d10, d11, [sp, #80]
	ldp d12, d13, [sp, #96]
	ldp d14, d15, [sp, #112]
	add sp, sp, #144
	b _free
	.cfi_endproc

