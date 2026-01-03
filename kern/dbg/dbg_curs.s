# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# [Debug] Cursor structure

.include "chr.inc"
.section .text
.code16
.global dbg_curs

# dbg_curs()
dbg_curs:
	push %si
	
	mov $curs, %si

	mov $CHR_CR, %al
	call vga_outc
	mov $CHR_LF, %al
	call vga_outc
	call dbg_line
	mov $CHR_CR, %al
	call vga_outc
	mov $CHR_LF, %al
	call vga_outc

	mov (%si), %al
	add $0x30, %al
	call vga_outc

	mov 0x01(%si), %al
	add $0x30, %al
	call vga_outc

	mov $CHR_CR, %al
	call vga_outc
	mov $CHR_LF, %al
	call vga_outc
	call dbg_line
	mov $CHR_CR, %al
	call vga_outc
	mov $CHR_LF, %al
	call vga_outc

	pop %si
	ret
