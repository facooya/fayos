# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya

.include "drv/vga.s"
.include "chr.s"
.section .text
.code16
.global vga_clr_line

# vga_clr_line()
vga_clr_line:
	push %es
	push %di
	push %bx

	mov $VGA_SEG, %ax
	mov %ax, %es
	xor %di, %di

	call vga_get_curs

	mov (VGA_COL), %cx

	# get current line [line_idx=curs_pos/col]
	xor %dx, %dx
	div %cx
	mov %ax, %cx # line_idx

	# [line_start_pos=col*line_idx]
	mov (VGA_COL), %ax
	mul %cx
	add %ax, %di
	add %ax, %di

	push %ax
	call vga_set_curs
	add $0x02, %sp

	mov (VGA_COL), %cx
	mov $((VGA_COLOR_NORM<<0x08)|CHR_SP), %ax
	rep stosw

.done:
	pop %bx
	pop %di
	pop %es
	ret
