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
# si = raw.data
cli_lsh:
	push %di

	# cpy
	mov %si, %di # raw.data
	mov (raw_buf), %cx # raw.len

	call sys_get_cursor

.lsh__lp: # [d_lsh.1]
	# left shift
	mov (%di), %al # raw.data
	mov %al, -0x01(%di)

	# {end} (raw.len == len)
	test %cx, %cx
	jz .lsh__end

	# {lp}
	add $0x01, %di # raw.data
	sub $0x01, %cx # raw.len
	jmp .lsh__lp

.lsh__end:
	# back cursor [d_lsh.2]
	sub $0x01, %dl # cursor.x
	call sys_set_cursor

	# [d_lsh.3]
	push %si
	call outs
	add $0x02, %sp

	# overwrite [d_lsh.4]
	call outsp

	# back cursor [d_lsh.5]
	call sys_set_cursor

.done:
	pop %di
	ret
