# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Clear all

.include "drv/vga.s"
.include "chr.s"
.section .text
.code16
.global vga_clr

# vga_clr()
vga_clr:
	push %es
	push %di
	push %bx

	mov $VGA_SEG, %ax
	mov %ax, %es
	xor %di, %di

	mov (vga_size), %cx

	mov $((VGA_COLOR_NORM<<0x08)|CHR_SP), %ax
	rep stosw

	xor %ax, %ax
	push %ax
	call vga_set_curs
	add $0x02, %sp

.end:
	pop %bx
	pop %di
	pop %es
	ret
