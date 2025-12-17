# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya

.include "drv/vga.s"
.section .text
.code16
.global vga_get_curs

# vga_get_curs()
# <ret> ax = pos
# ax / column = y
# ax % column = x
vga_get_curs:
	xor %ax, %ax

	# high
	mov $VGA_CURS_IDX_REG, %dx
	mov $VGA_CURS_IDX_HI, %al
	out %al, %dx
	mov $VGA_CURS_DATA_REG, %dx
	in %dx, %al
	mov %al, %ah

	# low
	mov $VGA_CURS_IDX_REG, %dx
	mov $VGA_CURS_IDX_LO, %al
	out %al, %dx
	mov $VGA_CURS_DATA_REG, %dx
	in %dx, %al
	ret
