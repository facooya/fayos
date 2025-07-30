# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Cursor

.section .data
.global cursor
cursor:
	.byte 0x00 # min
	.byte 0x00 # max

.section .text
.code16
.global init_cursor

# init_cursor()
init_cursor:
	push %bx
	call _sys_get_cursor
	mov %dl, (cursor)
	mov %dl, (cursor+0x01)
	pop %bx
	ret
