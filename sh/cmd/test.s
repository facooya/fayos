# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025-2026 Facooya and Fanone Facooya

.section .text
.code16
.global cmd_test

# cmd_test()
cmd_test:
	push %si

	mov $file_line_cv, %si
	mov (%si), %ax
	push %ax
	call dbg_reg
	add $0x02, %sp
	call dbg_a
	mov 0x02(%si), %ax
	push %ax
	call dbg_reg
	add $0x02, %sp
	mov 0x04(%si), %ax
	push %ax
	call dbg_reg
	add $0x02, %sp
	mov 0x06(%si), %ax
	push %ax
	call dbg_reg
	add $0x02, %sp

	pop %si
	ret
