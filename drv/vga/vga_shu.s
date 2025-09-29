# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Viedo shift up by line

.include "drv/vga.s"
.section .text
.code16
.global vga_shu

# vga_shu()
vga_shu:
	push %es
	push %si
	push %di
	push %bx

	# TODO: vga size
	mov $VGA_COL, %bx
	mov (%bx), %cx
	xor %ax, %ax
	mov $VGA_ROW, %bx
	mov (%bx), %al
	mul %cx
	mov %ax, %cx # cpy_cnt

	push %cx # [s.f0:cpy_cnt]
	push %ax
	call vga_set_curs
	add $0x02, %sp
	pop %cx # [s.f0:cpy_cnt]

	# ignore top row # TODO: vga size
	mov $VGA_COL, %bx
	mov (%bx), %ax
	xor %si, %si
	add %ax, %si
	add %ax, %si
	xor %di, %di

	push %ds # [s.s0:vga_seg]
	mov $VGA_SEG, %ax
	mov %ax, %es
	mov %ax, %ds

	rep movsw
	pop %ds # [s.s0:vga_seg]

.end:
	call vga_clr_line

.done:
	pop %bx
	pop %di
	pop %si
	pop %es
	ret
