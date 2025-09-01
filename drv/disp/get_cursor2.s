# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Get cursor position

# reference link
# http://wiki.osdev.org/Text_Mode_Cursor#Get_Cursor_Position

.section .text
.code16
.global get_cursor2

# get_cursor2()
# <ret> ax = pos
# <info>
# ax / width = y
# ax % width = x
get_cursor2:
	xor %ax, %ax

	# high
	mov $0x0E, %al
	mov $0x03D4, %dx
	out %al, %dx
	mov $0x03D5, %dx
	in %dx, %al
	mov %al, %ah

	# low
	mov $0x0F, %al
	mov $0x03D4, %dx
	out %al, %dx
	mov $0x03D5, %dx
	in %dx, %al
	ret
