# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2026 Facooya and Fanone Facooya

.include "chr.inc"
.section .text
.code16
.global disp_shl_cl
.global disp_shr_cl

# disp_shl_cl(ub8 *data)
disp_shl_cl:
	push %bp
	mov %sp, %bp
	push %si
	push %di

	mov 0x04(%bp), %si # (*data)

	# cpy
	mov %si, %di
	inc %di

	# { size
	push %es # [s.f0:extra]
	xor %ax, %ax
	mov %ax, %es

	push %di
	push %es
	call mem_size
	add $0x04, %sp
	pop %es # [s.f0:extra]

	mov %ax, %cx # size
	# }

1:
	# left shift
	mov (%di), %al # data
	mov %al, -0x01(%di)

	# (str.size == 0) ? {end}
	test %cx, %cx
	jz 9f

	inc %di # data
	dec %cx # size
	jmp 1b

9:
	# left curs
	call vga_get_curs
	dec %ax
	push %ax # [s.1:curs_pos]
	push %ax
	call vga_set_curs
	add $0x02, %sp

	push %si
	call vga_outs
	add $0x02, %sp

	# overwrite
	mov $CHR_SP, %al
	call vga_outc

	# left curs
	pop %ax # [s.1:curs_pos]
	push %ax
	call vga_set_curs
	add $0x02, %sp

	pop %di
	pop %si
	pop %bp
	ret

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

1:
	# right shift
	mov (%di), %al
	mov %al, 0x01(%di)

	# (size == 0) ? {end}
	test %cx, %cx
	je 9f

	dec %di # data
	dec %cx # size
	jmp 1b

9:
	# ah = ascii
	mov %si, %di # cpy
	dec %di
	mov %ah, (%di) # data

	call vga_get_curs
	# <ax = curs_pos>

	push %ax # [s.0:curs_pos]
	push %di # data
	call vga_outs
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
