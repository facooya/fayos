# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya

.section .text
.code16
.global kbd_hdl_right

# kbd_hdl_right()
# <req> si = cl_sbuf+i
# <req> curs
# <ret> si = {norm:&cl_sbuf+i+1}, {skip:&cl_sbuf+i}
kbd_hdl_right:
	call vga_get_curs

	# (curs.x == curs.max) ? {done}
	cmp (curs+0x02), %ax
	je .done

	# right curs
	inc %ax
	push %ax
	call vga_set_curs
	add $0x02, %sp

	# ptr
	inc %si # <ret>

.done:
	ret
