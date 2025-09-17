# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Set cursor position

# reference link
# http://wiki.osdev.org/Text_Mode_Cursor#Get_Cursor_Position

.section .text
.code16
.global vga_set_curs

# vga_set_curs(pos)
vga_set_curs:
	push %bp
	mov %sp, %bp

	# high
	mov $0x0E, %al
	mov $0x03D4, %dx
	out %al, %dx
	mov $0x03D5, %dx
	mov 0x04(%bp), %ax
	mov %ah, %al
	out %al, %dx

	# low
	mov $0x0F, %al
	mov $0x03D4, %dx
	out %al, %dx
	mov $0x03D5, %dx
	mov 0x04(%bp), %ax
	out %al, %dx

	pop %bp
	ret
