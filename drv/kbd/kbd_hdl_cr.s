# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya

.section .text
.code16
.global kbd_hdl_cr

# kbd_hdl_cr()
# <req> cl_sbuf
# <ret> cl_sbuf
kbd_hdl_cr:
	call exec_cmd

	push $ps1
	call vga_puts
	add $0x02, %sp

	call vga_init_curs

	xor %ax, %ax
	mov (cl_sbuf), %cx
	add $0x02, %cx
	push %cx # (size)
	push %ax # (value)
	push $cl_sbuf # (&off)
	push %ax # (&seg)
	call mem_set
	add $0x08, %sp

	mov $cl_sbuf, %si
	add $0x02, %si # skip len
	ret
