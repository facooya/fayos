# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Right shift

.section .text
.code16
.global kbd_rsh

# kbd_rsh(*data, ascii)
# <ret> [disp]
kbd_rsh:
	push %bp
	mov %sp, %bp
	push %si
	push %di

	mov 0x04(%bp), %si
	mov 0x06(%bp), %ax

	# cpy
	mov %al, %ah # ascii
	mov %si, %di # data
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
	add %ax, %di # data.end
	sub $0x01, %di # data.last

	pop %es
	pop %ax
	# }}}

.lp:
	# right shift
	mov (%di), %al
	mov %al, 0x01(%di)

	# {end} (str.len == 0)
	test %cx, %cx
	je .end

	# {lp}
	sub $0x01, %di # data
	sub $0x01, %cx
	jmp .lp

.end:
	# ah = ascii
	mov %si, %di # cpy
	sub $0x01, %di
	mov %ah, (%di) # data

	call vga_get_curs

	push %ax # [s.0:curs_pos]
	push %di # data
	call vga_puts
	add $0x02, %sp
	pop %ax # [s.0:curs_pos]

	# restore curs.pos
	add $0x01, %ax # curs.x
	push %ax
	call vga_set_curs
	add $0x02, %sp

	pop %di
	pop %si
	pop %bp
	ret
