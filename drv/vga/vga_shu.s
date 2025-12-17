# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya

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

	mov (vga_last_row_off), %ax
	push %ax
	call vga_set_curs
	add $0x02, %sp

	# ignore top row
	mov (VGA_ADDR_COL), %ax
	xor %si, %si
	add %ax, %si
	add %ax, %si
	xor %di, %di

	mov (vga_last_row_off), %cx
	push %ds # [s.s0:vga_seg]
	mov $(VGA_MEM>>0x10), %ax
	mov %ax, %es
	mov %ax, %ds

	rep movsw
	pop %ds # [s.s0:vga_seg]

	call vga_clr_line

.done:
	pop %bx
	pop %di
	pop %si
	pop %es
	ret
