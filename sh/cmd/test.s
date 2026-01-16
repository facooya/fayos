# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025-2026 Facooya and Fanone Facooya

.include "drv/vga.inc"
.section .text
.code16
.global cmd_test

# cmd_test()
cmd_test:
	push %es
	push %si
	push %di
	push %bx

	call vga_hide_curs
	call vga_show_curs

	pop %bx
	pop %di
	pop %si
	pop %es
	ret

.section .data
_test_data: .asciz "test data"
