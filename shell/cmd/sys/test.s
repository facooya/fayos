# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Command test - temporary debug and test runtime

.section .data
.str: .asciz "Hello world Hello World 2 Hello world 3 Hello world 4 Hello world 5 Hello world 6 Hello world 7\r\n"

.section .text
.code16
.global cmd_test

# cmd_test()
cmd_test:
	push $.str
	call vga_puts
	add $0x02, %sp

	ret
