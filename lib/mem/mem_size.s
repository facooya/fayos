# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# [Memory] Get size

.section .text
.code16
.global mem_size

# mem_size(*seg, *off)
# <ret> ax = size
mem_size:
	push %bp
	mov %sp, %bp
	push %es
	push %bx

	mov 0x04(%bp), %ax # (*seg)
	mov %ax, %es
	mov 0x06(%bp), %bx # (*off)
	xor %cx, %cx # size

.lp:
	# (chr == null) ? {done}
	mov %es:(%bx), %al
	test %al, %al
	jz .done

	inc %bx
	inc %cx # size
	jmp .lp

.done:
	mov %cx, %ax # <ret:size>

	pop %bx
	pop %es
	pop %bp
	ret
