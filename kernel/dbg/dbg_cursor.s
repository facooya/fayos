# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Debug cursor

.section .text
.code16
.global dbg_cursor

# dbg_cursor()
dbg_cursor:
	push %si
	
	mov $cursor, %si

	call outnl
	call dbg_line
	call outnl

	mov (%si), %al
	add $0x30, %al
	call outc

	mov 0x01(%si), %al
	add $0x30, %al
	call outc

	call outnl
	call dbg_line
	call outnl

	pop %si
	ret
