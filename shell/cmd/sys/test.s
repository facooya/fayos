# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Command test - temporary debug and test runtime

.section .data
.str: .asciz "Hello world\r\nHello World 2\r\n"

.section .text
.code16
.global cmd_test

# cmd_test()
cmd_test:
	#mov $0xFFFF, %cx
	mov $0x0F, %cx

.lp:
	test %cx, %cx
	jz .done
	push %cx

	push $.str
	call vga_puts
	add $0x02, %sp

	pop %cx
	dec %cx
	jmp .lp

.done:
	call dbg_a
	ret
