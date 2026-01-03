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
	call vga_outc
	mov %dl, %al
	call vga_outc

	mov (%si), %dx
	add $0x30, %dh
	add $0x30, %dl
	mov %dh, %al
	call vga_outc
	mov %dl, %al
	call vga_outc

	call dbg_line
	mov $CHR_CR, %al
	call vga_outc
	mov $CHR_LF, %al
	call vga_outc

	pop %dx
	pop %ax
	pop %si
	pop %bp
	ret
