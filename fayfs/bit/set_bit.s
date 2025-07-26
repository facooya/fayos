# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Set bit

.section .text
.code16
.global set_bit

# set_bit(*mem, *bitnum)
set_bit:
	push %bp
	mov %sp, %bp
	push %si
	push %bx

	mov 0x04(%bp), %bx # *mem
	mov 0x06(%bp), %si # *bitnum

	mov (%si), %ax # bitnum_lo
	xor %dx, %dx
	mov $0x10, %cx
	div %cx

	# calc bitset
	add %ax, %bx
	add %ax, %bx
	mov (%bx), %ax
	bts %dx, %ax
	mov %ax, (%bx)

# {DONE}
.done:
	pop %bx
	pop %si
	pop %bp
	ret
