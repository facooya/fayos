# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Clear bit

.section .text
.code16
.global clear_bit

# clear_bit(mem, bitnum)
clear_bit:
	push %bp
	mov %sp, %bp
	push %bx

	mov 0x04(%bp), %bx # mem

	mov 0x06(%bp), %ax # bitnum
	xor %dx, %dx
	mov $0x10, %cx
	div %cx

	# calc bitset
	add %ax, %bx
	add %ax, %bx
	mov (%bx), %ax
	btr %dx, %ax
	mov %ax, (%bx)

# {DONE}
.done:
	pop %bx
	pop %bp
	ret
