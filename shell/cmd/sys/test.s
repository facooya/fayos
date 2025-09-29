# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Command test - temporary debug and test runtime

.section .data
.blknum: .long 0x01

.section .text
.code16
.global cmd_test

# cmd_test()
cmd_test:
	mov $0xFFFF, %cx

.lp:
	test %cx, %cx
	jz .done
	push %cx

	call vga_clr_line

	pop %cx
	dec %cx
	jmp .lp

.done:
	call dbg_a
	ret
