# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025-2026 Facooya and Fanone Facooya

.section .text
.code16
.global cmd_test

# cmd_test()
cmd_test:
	push %si

	mov $disp_down_cbuf, %si
	add $0x02, %si
	push %si
	call vga_outs
	add $0x02, %sp

	mov $disp_down_cbuf, %si
	mov (%si), %ax
	push %ax
	call dbg_reg
	add $0x02, %sp

	pop %si
	ret
