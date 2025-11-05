# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# [Keyboard] Key carriage return

.section .text
.code16
.global kbd_key_cr

# kbd_key_cr()
# <req> cl_lbuf
# <ret> cl_lbuf
kbd_key_cr:
	call exec_cmd

	push $ps1
	call vga_puts
	add $0x02, %sp

	call vga_init_curs

	xor %ax, %ax
	mov (cl_lbuf), %cx
	add $0x02, %cx
	push %cx # (size)
	push %ax # (value)
	push $cl_lbuf # (&off)
	push %ax # (&seg)
	call mem_set
	add $0x08, %sp

	mov $cl_lbuf, %si
	add $0x02, %si # skip len
	ret
