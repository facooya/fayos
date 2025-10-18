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
	mov $de_hist+0x02, %si

	push %si
	call f_open
	add $0x02, %sp

	call mem_alloc
	push %dx
	call dbg_reg
	add $0x02, %sp
	push %ax
	call dbg_reg
	add $0x02, %sp

	push $0xD000
	push $0x1000
	call mem_free
	add $0x04, %sp

	ret
