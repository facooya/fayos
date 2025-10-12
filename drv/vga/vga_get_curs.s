# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Get curs position

# reference link
# http://wiki.osdev.org/Text_Mode_Cursor#Get_Cursor_Position

.include "drv/vga.s"
.section .text
.code16
.global vga_get_curs

# vga_get_curs()
# <ret> ax = pos
# <info>
# ax / width = y
# ax % width = x
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
