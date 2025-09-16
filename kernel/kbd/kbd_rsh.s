# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Right shift

.section .text
.code16
.global kbd_rsh

# kbd_rsh()
# <req> *si = raw.data (pre-update)
# <req> al = ascii
# <ret> *si = raw.data
kbd_rsh:
	push %di
	jmp .rsh

# {task}
.rsh:
	# cpy
	mov %al, %ah # ascii
	mov %si, %di # raw.data
	sub $0x01, %di # restore origin

	# {{{ len
	push %ax
	push %es

	xor %ax, %ax
	mov %ax, %es

	push %di
	push %es
	call strlen
	add $0x04, %sp

	mov %ax, %cx # len
	add %ax, %di # raw.data.end
	sub $0x01, %di # raw.data.last

	pop %es
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

	call get_cursor2

	push %ax # [s.0:curs_pos]
	push %di # raw.data
	call vga_puts
	add $0x02, %sp
	pop %ax # [s.0:curs_pos]

	# restore cursor.pos
	add $0x01, %ax # cursor.x
	push %ax
	call set_cursor2
	add $0x02, %sp

	pop %di
	ret
