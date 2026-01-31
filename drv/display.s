# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025-2026 Facooya and Fanone Facooya

.include "chr.inc"
.include "drv/vga.inc"
.section .text
.code16
.global disp_shl_cl
.global disp_shr_cl

# disp_shl_cl(ub8 *data)
disp_shl_cl:
	push %bp
	mov %sp, %bp
	push %si

	mov 0x04(%bp), %si # (*data)

	# { size
	push %si
	push %ds
	call mem_size
	add $0x04, %sp

	mov %ax, %cx # size
	jcxz 99f
	# }

1: # shift left
	mov (%si), %al
	mov %al, -0x01(%si)
	inc %si
	loop 1b

	xor %al, %al
	mov %al, -0x01(%si)

	# { upd disp
	call vga_get_curs
	push %ax # [s.0: curs_pos]

	mov 0x04(%bp), %si
	dec %si
	push %si
	call vga_outs
	add $0x02, %sp

	# overwrite last chr
	push $CHR_SP # (chr)
	call vga_outc
	add $0x02, %sp

	pop %ax # [s.0: curs_pos]
	push %ax # (curs_pos)
	call vga_set_curs
	add $0x02, %sp
	# }

99:
	pop %si
	pop %bp
	ret

# disp_shr_cl(ub8 *data, ub8 chr)
disp_shr_cl:
	push %bp
	mov %sp, %bp
	push %si
	push %di

	mov 0x04(%bp), %si # (*data)
	mov 0x06(%bp), %ax # (chr)

	# cpy
	mov %al, %ah # chr
	mov %si, %di # data
	dec %di # restore origin

	# { size
	push %ax

	push %di
	push %ds
	call mem_size
	add $0x04, %sp

	mov %ax, %cx # size
	add %ax, %di # data.end
	dec %di # data.last

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
	# ah = chr
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
