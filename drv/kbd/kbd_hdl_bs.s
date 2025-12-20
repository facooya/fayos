# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya

.section .text
.code16
.global kbd_hdl_bs

# kbd_hdl_bs()
# <mod> cl_sbuf, curs
# <ret> si = &cl_sbuf-1
kbd_hdl_bs:
	# (curs.x == curs.min) ? {done}
	call vga_get_curs
	cmp (curs), %ax
	je .done

	# { pre-update
	# dec curs max
	mov (curs+0x02), %ax # curs.max
	sub $0x01, %ax
	mov %ax, (curs+0x02)

	# dec cl_sbuf
	sub $0x01, %si # cl.data
	mov (cl_sbuf), %ax # cl.size
	sub $0x01, %ax
	mov %ax, (cl_sbuf)
	# }

	# (raw.data+1 != null) ? {shl}
	mov 0x01(%si), %al
	test %al, %al
	jnz .call__shl_cl

	# {{{ [d_nsh]
	# left curs [d_nsh.1]
	call vga_get_curs
	sub $0x01, %ax # curs.x
	push %ax # [s.0:curs_pos]
	push %ax
	call vga_set_curs
	add $0x02, %sp

	# overwrite [d_nsh.2]
	mov $0x20, %al # space
	call vga_putc

	# left curs [d_nsh.3]
	pop %ax # [s.0:curs_pos]
	push %ax
	call vga_set_curs
	add $0x02, %sp

	# {step} store null [d_nsh.4]
	xor %al, %al
	mov %al, (%si) # raw.data
	# }}}

.done:
	ret

.call__shl_cl:
	push %si
	call disp_shl_cl
	add $0x02, %sp
	jmp .done
