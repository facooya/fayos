# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Video put string

.section .text
.code16
.global vga_puts

# vga_puts(*str)
vga_puts:
	push %bp
	mov %sp, %bp
	push %si
	push %ax

	mov 0x04(%bp), %si

.lp:
	mov (%si), %al
	test %al, %al
	jz .end

	call vga_putc

	add $0x01, %si
	jmp .lp

.end:
	pop %ax
	pop %si
	pop %bp
	ret
