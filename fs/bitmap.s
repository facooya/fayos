# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya

.section .text
.code16
.global bm_alloc
.global bm_set
.global bm_clr

# [public] bm_alloc(ub16 *seg, ub16 *off)
# <ret: ax=bit_num>
bm_alloc:
	push %bp
	mov %sp, %bp
	push %es
	push %si
	push %bx

	mov 0x04(%bp), %ax # (*seg)
	mov %ax, %es
	mov 0x06(%bp), %bx # (*off)
	xor %dx, %dx # word cnt

1:
	# (block_bitmap != full) ? {end}
	mov %es:(%bx), %ax
	cmp $0xFFFF, %ax
	jne 1f

	add $0x02, %bx
	inc %dx # word cnt
	jmp 1b

1:
	xor %cx, %cx # bit cnt
	push %dx # [s.l0:word_cnt]

1:
	mov $(0x01<<0x00), %dx
	shl %cl, %dx

	# (bit != set) ? {end}
	test %dx, %ax
	jz 1f

	inc %cx # bit cnt
	jmp 1b

1:
	pop %dx # [s.l0:word_cnt]

	# calc bitnum
	push %cx # bit cnt
	mov %dx, %ax # word cnt
	xor %dx, %dx
	mov $0x10, %cx
	mul %cx
	pop %cx # bit cnt
	add %cx, %ax # <ret:bit_num>

	pop %si
	pop %bx
	pop %es
	pop %bp
	ret

# bm_set(ub16 *seg, ub16 *off, ub16 bit_num)
bm_set:
	push %bp
	mov %sp, %bp
	push %es
	push %si
	push %bx

	mov 0x04(%bp), %ax # (*seg)
	mov %ax, %es
	mov 0x06(%bp), %bx # (*off)
	mov 0x08(%bp), %ax # (bit_num)

	xor %dx, %dx
	mov $0x10, %cx
	div %cx

	# calc bitset
	add %ax, %bx
	add %ax, %bx
	mov %es:(%bx), %ax

	xor %cx, %cx
	mov %dx, %cx
	mov $(0x01<<0x00), %dx
	shl %cl, %dx

	or %dx, %ax
	mov %ax, %es:(%bx)

	pop %bx
	pop %si
	pop %es
	pop %bp
	ret

# bm_clr(ub16 *seg, ub16 *off, ub16 bit_num)
bm_clr:
	push %bp
	mov %sp, %bp
	push %es
	push %si
	push %bx

	mov 0x04(%bp), %ax # (*seg)
	mov %ax, %es
	mov 0x06(%bp), %bx # (*off)
	mov 0x08(%bp), %ax # (bit_num)

	xor %dx, %dx
	mov $0x10, %cx
	div %cx

	# calc bitset
	add %ax, %bx
	add %ax, %bx
	mov %es:(%bx), %ax

	xor %cx, %cx
	mov %dx, %cx
	mov $(0x01<<0x00), %dx
	shl %cl, %dx

	not %dx
	and %dx, %ax
	mov %ax, %es:(%bx)

	pop %bx
	pop %si
	pop %es
	pop %bp
	ret
