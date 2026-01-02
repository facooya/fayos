# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Debug number - show number value

.include "chr.inc"
.section .text
.code16
.global dbg_num

# dbg_num(*num)
# <req> *num [4-byte]
dbg_num:
	push %bp
	mov %sp, %bp
	push %si
	push %ax
	push %dx

	call dbg_line

	mov 0x04(%bp), %si
	mov 0x02(%si), %dx
	add $0x30, %dh
	add $0x30, %dl
	mov %dh, %al
	call vga_putc
	mov %dl, %al
	call vga_putc

	mov (%si), %dx
	add $0x30, %dh
	add $0x30, %dl
	mov %dh, %al
	call vga_putc
	mov %dl, %al
	call vga_putc

	call dbg_line
	mov $CHR_CR, %al
	call vga_putc
	mov $CHR_LF, %al
	call vga_putc

	pop %dx
	pop %ax
	pop %si
	pop %bp
	ret
