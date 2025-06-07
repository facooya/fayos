# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Left shift

.section .text
.code16
.global cli_lsh

# cli_lsh()
# <REQ>
# si = raw.data (updated)
cli_lsh:
	push %di
	jmp .lsh

.lsh:
	# cpy
	mov %si, %di # raw.data
	add $0x01, %di

	# strlen(&str)
	# <ret> ax = len
	push %di # raw.data
	call strlen
	add $0x02, %sp
	mov %ax, %cx # str.len

.lsh__lp: # [d_lsh.1]
	# left shift
	mov (%di), %al # raw.data
	mov %al, -0x01(%di)

	# {end} (str.len == 0)
	test %cx, %cx
	jz .lsh__end

	# {lp}
	add $0x01, %di # raw.data
	sub $0x01, %cx # raw.len
	jmp .lsh__lp

.lsh__end:
	# left cursor [d_lsh.2]
	call sys_get_cursor
	sub $0x01, %dl # cursor.x
	call sys_set_cursor

	# [d_lsh.3]
	push %si
	call outs
	add $0x02, %sp

	# overwrite [d_lsh.4]
	call outsp

	# left cursor [d_lsh.5]
	call sys_set_cursor

.done:
	pop %di
	ret
