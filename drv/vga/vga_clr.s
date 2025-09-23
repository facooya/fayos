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

	xor %dx, %dx
	mov $VGA_ROW, %bx
	mov (%bx), %dl

	mov $VGA_COL, %bx
	mov (%bx), %ax

	mul %dx
	mov %ax, %cx # count

	xor %ax, %ax
	push %ax
	call vga_set_curs
	add $0x02, %sp

.lp:
	# (count == 0) ? {end}
	test %cx, %cx
	jz .end

	# clr
	mov $CHR_SP, %al
	mov %al, %es:(%di)
	add $0x01, %di

	# conf
	mov $VGA_COLOR_NORM, %al
	mov %al, %es:(%di)
	add $0x01, %di

	sub $0x01, %cx
	jmp .lp

.end:
	pop %bx
	pop %di
	pop %es
	ret
