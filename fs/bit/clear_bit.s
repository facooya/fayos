# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Clear bit

.section .text
.code16
.global clear_bit

# clear_bit(*seg, *off, *bitnum)
clear_bit:
	push %bp
	mov %sp, %bp
	push %es
	push %si
	push %bx

	mov 0x04(%bp), %ax
	mov %ax, %es # *seg
	mov 0x06(%bp), %bx # *off
	mov 0x08(%bp), %si # *bitnum

	mov (%si), %ax # bitnum_lo
	xor %dx, %dx
	mov $0x10, %cx
	div %cx

	# calc bitset
	add %ax, %bx
	add %ax, %bx
	mov %es:(%bx), %ax
	btr %dx, %ax
	mov %ax, %es:(%bx)

# {DONE}
.done:
	pop %bx
	pop %si
	pop %es
	pop %bp
	ret
