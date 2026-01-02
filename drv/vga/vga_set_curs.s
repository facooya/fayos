# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya

.include "drv/vga.inc"
.section .text
.code16
.global vga_set_curs

# vga_set_curs(pos)
vga_set_curs:
	push %bp
	mov %sp, %bp

	# high
	mov $VGA_PORT_CURS_CMD, %dx
	mov $VGA_CMD_CURS_POS_HI, %al
	out %al, %dx
	mov $VGA_PORT_CURS_DATA, %dx
	mov 0x04(%bp), %ax
	mov %ah, %al
	out %al, %dx

	# low
	mov $VGA_PORT_CURS_CMD, %dx
	mov $VGA_CMD_CURS_POS_LO, %al
	out %al, %dx
	mov $VGA_PORT_CURS_DATA, %dx
	mov 0x04(%bp), %ax
	out %al, %dx

	pop %bp
	ret
