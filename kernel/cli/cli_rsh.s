# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Right shift

.section .text
.code16
.global cli_rsh

# cli_rsh()
# <REQ>
# si = raw.data (pre-update)
# al = ascii
cli_rsh:
	push %di
	jmp .rsh

# {task}
.rsh:
	# cpy
	mov %al, %ah # ascii
	mov %si, %di # raw.data
	sub $0x01, %di # restore origin

	# {{{
	push %ax

	# strlen(&str)
	push %di
	call strlen
	add $0x02, %sp

	mov %ax, %cx # str.len
	add %ax, %di # raw.data.end
	sub $0x01, %di # raw.data.last

	pop %ax
	# }}}

.rsh__lp:
	# right shift
	mov (%di), %al
	mov %al, 0x01(%di)

	# {end} (str.len == 0)
	test %cx, %cx
	je .rsh__end

	# {lp}
	sub $0x01, %di # raw.data
	sub $0x01, %cx
	jmp .rsh__lp

.rsh__end:
	# ah = ascii
	mov %si, %di # cpy
	sub $0x01, %di
	mov %ah, (%di) # raw.data

	call sys_get_cursor

	push %dx # cursor.pos
	push %di # raw.data
	call outs
	add $0x02, %sp
	pop %dx # cursor.pos

	# restore cursor.pos
	add $0x01, %dl # cursor.x
	call sys_set_cursor

	pop %di
	ret
