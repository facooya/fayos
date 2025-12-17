# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya

.include "drv/vga.s"
.section .text
.code16
.global vga_init

# vga_init()
vga_init:
	xor %ax, %ax
	mov (VGA_ADDR_ROW), %al
	mov (VGA_ADDR_COL), %cx

	xor %dx, %dx
	mul %cx
	mov %ax, (vga_last_row_off)

	add %cx, %ax
	mov %ax, (vga_size)
	ret
