# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya

.section .text
.code16
.global kbd_hdl_left

# kbd_hdl_left()
# <req> si = cl_sbuf+i
# <req> curs
# <ret> si = {norm:cl_sbuf+i-1}, {skip:cl_sbuf+i}
kbd_hdl_left:
	call vga_get_curs

	# (curs.x == curs.min) ? {done}
	cmp (curs), %ax
	je .done

	# left curs
	sub $0x01, %ax
	push %ax
	call vga_set_curs
	add $0x02, %sp

	# ptr
	sub $0x01, %si # cl.data

.done:
	ret
