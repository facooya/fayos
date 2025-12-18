# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya

.section .text
.code16
.global kbd_hdl_right

# kbd_hdl_right()
kbd_hdl_right:
	call vga_get_curs

	# {end.done} (curs.x == curs.max)
	cmp (curs+0x02), %ax
	je .done

	# right curs
	add $0x01, %ax
	push %ax
	call vga_set_curs
	add $0x02, %sp

	# ptr
	add $0x01, %si # raw.data

.done:
	ret
