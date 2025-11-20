# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# [Bitmap] Set bit number

.section .text
.code16
.global bm_set

# bm_set(ub16 *seg, ub16 *off, ub16 bm_num)
bm_set:
	push %bp
	mov %sp, %bp
	push %es
	push %si
	push %bx

	mov 0x04(%bp), %ax # (*seg)
	mov %ax, %es
	mov 0x06(%bp), %bx # (*off)
	mov 0x08(%bp), %ax # (bm_num)

	xor %dx, %dx
	mov $0x10, %cx
	div %cx

	# calc bitset
	add %ax, %bx
	add %ax, %bx
	mov %es:(%bx), %ax
	bts %dx, %ax
	mov %ax, %es:(%bx)

# {DONE}
.done:
	pop %bx
	pop %si
	pop %es
	pop %bp
	ret
