# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya

.include "chr.inc"
.section .text
.code16
.global kbd_hdl_bs

# kbd_hdl_bs()
# <mod> cl_sbuf, curs
# <ret> si = {norm:&cl_sbuf.data+i-1}, {skip:&cl_sbuf.data+i}
kbd_hdl_bs:
	# {
	call vga_get_curs
	# <ax = curs_pos>

	# (curs.x == curs.min) ? {done}
	cmp (curs), %ax
	je .done
	# <ret:skip>
	# }

	# { pre-update
	# dec curs max
	mov (curs+0x02), %ax # curs.max
	dec %ax
	mov %ax, (curs+0x02)

	# dec cl_sbuf
	dec %si # &cl_sbuf.data
	mov (cl_sbuf), %ax # cl_sbuf.size
	dec %ax
	mov %ax, (cl_sbuf)
	# }

	# (*(cl_sbuf+1) != null) ? {shl}
	mov 0x01(%si), %al
	test %al, %al
	jnz .call__shl_cl

	# {
	# left curs
	call vga_get_curs
	# <ax = curs_pos>
	dec %ax
	push %ax # [s.0:curs_pos]
	push %ax
	call vga_set_curs
	add $0x02, %sp

	# overwrite
	mov $CHR_SP, %al # space
	call vga_putc

	# left curs
	pop %ax # [s.0:curs_pos]
	push %ax
	call vga_set_curs
	add $0x02, %sp

	# store null
	xor %al, %al
	mov %al, (%si) # <ret>
	# }

.done:
	ret

.call__shl_cl:
	push %si
	call disp_shl_cl
	add $0x02, %sp
	jmp .done
