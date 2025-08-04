# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Left shift

.section .text
.code16
.global kbd_lsh

# kbd_lsh()
# <req> *si = raw.data (updated)
# <ret> *si = raw.data
kbd_lsh:
	push %di
	jmp .lsh

.lsh:
	# cpy
	mov %si, %di # raw.data
	add $0x01, %di

	# {{{ len
	push %es

	xor %ax, %ax
	mov %ax, %es

	push %di
	push %es
	call strlen
	add $0x04, %sp

	pop %es

	mov %ax, %cx # len
	# }}}

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
	call get_cursor
	sub $0x01, %dl # cursor.x
	call set_cursor

	# [d_lsh.3]
	push %si
	call outs
	add $0x02, %sp

	# overwrite [d_lsh.4]
	call outsp

	# left cursor [d_lsh.5]
	call set_cursor

.done:
	pop %di
	ret
