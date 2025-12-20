# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya

.section .text
.code16
.global disp_shr_cl

# disp_shr_cl(ub8 *data, ub8 ascii)
disp_shr_cl:
	push %bp
	mov %sp, %bp
	push %si
	push %di

	mov 0x04(%bp), %si # (*data)
	mov 0x06(%bp), %ax # (ascii)

	# cpy
	mov %al, %ah # ascii
	mov %si, %di # data
	dec %di # restore origin

	# { size
	push %ax
	push %es

	xor %ax, %ax
	mov %ax, %es

	push %di
	push %es
	call mem_size
	add $0x04, %sp

	mov %ax, %cx # size
	add %ax, %di # data.end
	dec %di # data.last

	pop %es
	pop %ax
	# }

.lp:
	# right shift
	mov (%di), %al
	mov %al, 0x01(%di)

	# (size == 0) ? {end}
	test %cx, %cx
	je .end

	dec %di # data
	dec %cx # size
	jmp .lp

.end:
	# ah = ascii
	mov %si, %di # cpy
	dec %di
	mov %ah, (%di) # data

	call vga_get_curs
	# <ax = curs_pos>

	push %ax # [s.0:curs_pos]
	push %di # data
	call vga_puts
	add $0x02, %sp
	pop %ax # [s.0:curs_pos]

	# restore curs.pos
	inc %ax
	push %ax
	call vga_set_curs
	add $0x02, %sp

	pop %di
	pop %si
	pop %bp
	ret
