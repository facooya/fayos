# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Debug cursor

.include "chr.s"
.section .text
.code16
.global dbg_cursor

# dbg_cursor()
dbg_cursor:
	push %si
	
	mov $cursor, %si

	mov $CHR_CR, %al
	call vga_putc
	mov $CHR_LF, %al
	call vga_putc
	call dbg_line
	mov $CHR_CR, %al
	call vga_putc
	mov $CHR_LF, %al
	call vga_putc

	mov (%si), %al
	add $0x30, %al
	call vga_putc

	mov 0x01(%si), %al
	add $0x30, %al
	call vga_putc

	mov $CHR_CR, %al
	call vga_putc
	mov $CHR_LF, %al
	call vga_putc
	call dbg_line
	mov $CHR_CR, %al
	call vga_putc
	mov $CHR_LF, %al
	call vga_putc

	pop %si
	ret
