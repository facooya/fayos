# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Cursor

.section .data
.global cursor
cursor:
	.word 0x00 # min_pos
	.word 0x00 # max_pos

.section .text
.code16
.global init_cursor2

# init_cursor2()
init_cursor2:
	call get_cursor2
	mov %ax, (cursor)
	mov %ax, (cursor+0x02)
	ret
