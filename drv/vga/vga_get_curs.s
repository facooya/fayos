# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya

.include "drv/vga.inc"
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
	mov $VGA_PORT_CURS_CMD, %dx
	mov $VGA_CMD_CURS_POS_HI, %al
	out %al, %dx
	mov $VGA_PORT_CURS_DATA, %dx
	in %dx, %al
	mov %al, %ah

	# low
	mov $VGA_PORT_CURS_CMD, %dx
	mov $VGA_CMD_CURS_POS_LO, %al
	out %al, %dx
	mov $VGA_PORT_CURS_DATA, %dx
	in %dx, %al
	ret
