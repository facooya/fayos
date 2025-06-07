# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Cursor library

.section .data
.global cursor

cursor: # docs/kernel/kernel.txt [s_cur]
	.byte 0x00 # min
	.byte 0x00 # max

.section .text
.code16
.global get_cursor
.global set_cursor
.global read_cursor
.global write_cursor
.global init_cursor

# ENTRY
# get_cursor()
# ret: dh = y
# ret: dl = x
get_cursor:
	push %bx
	call sys_get_cursor
	pop %bx
	ret

# ENTRY
# set_cursor()
# pre: dh = y
# pre: dl = x
set_cursor:
	push %bx
	call sys_set_cursor
	pop %bx
	ret

# ENTRY
# read_cursor()
# ret: dh = min
# ret: dl = max
read_cursor:
	# prol
	push %si

	# init
	mov $cursor, %si

	# body
	mov (%si), %dh
	mov 1(%si), %dl

	# epil
	pop %si
	ret

# ENTRY
# write_cursor()
# pre: dh = min
# pre: dl = max
write_cursor:
	# prol
	push %si

	# init
	mov $cursor, %si

	# body
	mov %dh, (%si)
	mov %dl, 1(%si)

	# epil
	pop %si
	ret

# ENTRY
# init_cursor()
init_cursor:
	push %bx
	call sys_get_cursor

	# pre
	mov %dl, %dh

	call write_cursor

	pop %bx
	ret
