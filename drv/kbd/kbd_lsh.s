# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Left shift

.section .text
.code16
.global kbd_lsh

# kbd_lsh(*data)
# <ret> [disp]
kbd_lsh:
	push %bp
	mov %sp, %bp
	push %si
	push %di

	mov 0x04(%bp), %si # data

	# cpy
	mov %si, %di
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

.lp: # [d_lsh.1]
	# left shift
	mov (%di), %al # data
	mov %al, -0x01(%di)

	# {end} (str.len == 0)
	test %cx, %cx
	jz .end

	# {lp}
	add $0x01, %di # data
	sub $0x01, %cx # len
	jmp .lp

.end:
	# left curs [d_lsh.2]
	call vga_get_curs
	sub $0x01, %ax # curs.x
	push %ax # [s.1:curs_pos]
	push %ax
	call vga_set_curs
	add $0x02, %sp

	push %si
	call vga_puts
	add $0x02, %sp

	# overwrite [d_lsh.4]
	mov $0x20, %al # space
	call vga_putc

	# left curs [d_lsh.5]
	pop %ax # [s.1:curs_pos]
	push %ax
	call vga_set_curs
	add $0x02, %sp

.done:
	pop %di
	pop %si
	pop %bp
	ret
