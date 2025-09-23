# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Clear current cursor line

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

	# get column
	mov $VGA_COL, %bx
	mov (%bx), %cx
	push %cx # [s.0:col]

	# get current line [line_idx=curs_pos/col]
	xor %dx, %dx
	div %cx
	mov %ax, %cx # line_idx

	# [line_start_pos=col*line_idx]
	pop %ax # [s.0:col]
	mul %cx
	add %ax, %di
	add %ax, %di

	push %ax
	call vga_set_curs
	add $0x02, %sp

	# get col
	mov $VGA_COL, %bx
	mov (%bx), %cx

.lp:
	# (count == 0) ? {end}
	test %cx, %cx
	jz .done

	# write
	mov $CHR_SP, %al # space
	mov %al, %es:(%di)
	add $0x01, %di

	# conf
	mov $VGA_COLOR_NORM, %al
	mov %al, %es:(%di)
	add $0x01, %di

	sub $0x01, %cx
	jmp .lp

.done:
	pop %bx
	pop %di
	pop %es
	ret
