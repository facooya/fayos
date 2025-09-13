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
.global get_cursor
.global set_cursor
.global init_cursor
.global init_cursor2

# get_cursor()
# <ret> cx = scan_line
# <ret> dx = current_pos
get_cursor:
	push %bx
	call _sys_get_cursor
	pop %bx
	ret

# set_cursor()
# <req> dx = pos
set_cursor:
	push %bx
	call _sys_set_cursor
	pop %bx
	ret

# init_cursor()
init_cursor:
	push %bx
	call _sys_get_cursor
	mov %dl, (cursor)
	mov %dl, (cursor+0x01)
	pop %bx
	ret

# init_cursor2()
init_cursor2:
	call get_cursor2
	mov %ax, (cursor)
	mov %ax, (cursor+0x02)
	ret
