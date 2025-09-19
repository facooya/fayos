# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Interrupt handler

.section .data
.str: .asciz "hello\nworld\n"

.section .text
.code16
.global interrupt

# int $0x30
interrupt:
	push %es
	push %bx

	# {{{ column
	mov $0x044A, %bx
	mov (%bx), %ax

	push %ax
	call dbg_reg
	add $0x02, %sp
	# }}}

	# {{{ row
	mov $0x0484, %bx
	mov (%bx), %al

	push %ax
	call dbg_reg
	add $0x02, %sp
	# }}}

	mov $0x20, %al
	out %al, $0x20

	pop %bx
	pop %es
	iret
