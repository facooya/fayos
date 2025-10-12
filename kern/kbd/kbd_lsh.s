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
	call vga_get_curs
	sub $0x01, %ax # cursor.x
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

	# left cursor [d_lsh.5]
	pop %ax # [s.1:curs_pos]
	push %ax
	call vga_set_curs
	add $0x02, %sp

.done:
	pop %di
	ret
