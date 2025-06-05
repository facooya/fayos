# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Right shift

.section .text
.code16
.global cli_rsh

# cli_rsh()
# <INFO>
# di = &raw_buf
# <REQ>
# si = raw.data
cli_rsh:
	push %di

	mov %al, %ah # cpy ascii

	mov $raw_buf, %di
	mov (%di), %dx # raw.len
	add $0x02, %di # skip len
	add %dx, %di # raw.data.last+1

# {task}
# <REQ>
# di = raw.data.last+1
# (*di == invalid)
.rsh:
	sub $0x01, %di # skip invalid
	# (*di == valid)

.rsh__lp:
	# right shift
	mov (%di), %al
	mov %al, 0x01(%di)

	# {end} (&raw.data.origin == &raw.data)
	cmp %di, %si
	je .rsh__end

	# {lp}
	sub $0x01, %di # raw.data
	jmp .rsh__lp

.rsh__end:
	# ah = ascii
	mov %ah, (%si) # raw.data.origin

	call sys_get_cursor

	push %dx # cursor.pos
	push %si # raw.data.origin
	call outs
	add $0x02, %sp
	pop %dx # cursor.pos

	# update cursor pos
	add $0x01, %dl # cursor.x
	call sys_set_cursor

	pop %di
	ret
