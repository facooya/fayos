# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# String length

.section .text
.code16
.global strlen

# strlen(*seg, *off)
# <ret> ax = length
strlen:
	push %bp
	mov %sp, %bp
	push %es
	push %bx

	mov 0x04(%bp), %ax
	mov %ax, %es
	mov 0x06(%bp), %bx
	xor %cx, %cx # len

.lp:
	mov %es:(%bx), %al

	# {end.done} (byte == null)
	test %al, %al
	jz .done

	# {lp}
	add $0x01, %bx
	add $0x01, %cx # len
	jmp .lp

.done:
	mov %cx, %ax # ret

	pop %bx
	pop %es
	pop %bp
	ret
