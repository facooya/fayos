# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Command test - temporary debug and test runtime

.section .data
.str: .asciz "Hello world\nHello World 2\r\nHello world 3\r\nHello world 4\r\n"

.section .text
.code16
.global cmd_test

# cmd_test()
cmd_test:
	mov $0x0A, %al
	call vga_putc
	push $.str
	call vga_puts
	add $0x02, %sp
	mov $0x0A, %al
	call vga_putc

	ret
