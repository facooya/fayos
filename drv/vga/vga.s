# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Video Graphic Array

.include "drv/vga.s"
.section .data
.global vga_size
.global vga_last_row_off
vga_size: .word 0x00
vga_last_row_off: .word 0x00

.section .text
.code16
.global vga_init

# vga_init()
vga_init:
	xor %ax, %ax
	mov (VGA_ROW), %al
	mov (VGA_COL), %cx

	xor %dx, %dx
	mul %cx
	mov %ax, (vga_last_row_off)

	add %cx, %ax
	mov %ax, (vga_size)
	ret
