# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya

.include "drv/vga.s"
.section .text
.code16
.global vga_set_curs

# vga_set_curs(pos)
vga_set_curs:
	push %bp
	mov %sp, %bp

	# high
	mov $VGA_CURS_IDX_REG, %dx
	mov $VGA_CURS_IDX_HI, %al
	out %al, %dx
	mov $VGA_CURS_DATA_REG, %dx
	mov 0x04(%bp), %ax
	mov %ah, %al
	out %al, %dx

	# low
	mov $VGA_CURS_IDX_REG, %dx
	mov $VGA_CURS_IDX_LO, %al
	out %al, %dx
	mov $VGA_CURS_DATA_REG, %dx
	mov 0x04(%bp), %ax
	out %al, %dx

	pop %bp
	ret
