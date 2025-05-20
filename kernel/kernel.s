# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Kernel for Fayos (docs/kernel/kernel.txt)

.section .data
.global kernel_prompt

kernel_prompt: .asciz "fayos:/# "
.kernel_ok_msg: .asciz "\nKernel ok\r\n"
.kernel_welcome_msg: .asciz "Welcome to Fayos kernel\r\n"

.section .text
.code16
.global _start

# _start()
_start:
	call init_sb

	push $.kernel_ok_msg
	call puts
	add $0x02, %sp

	push $.kernel_welcome_msg
	call puts
	add $0x02, %sp

	call outnl

	push $kernel_prompt
	call puts
	add $0x02, %sp

	call init_cursor
	mov $raw_buf, %si
	add $0x02, %si # TEST len

# .kernel_lp() - main loop
.kernel_lp:
	call sys_read_key

	call hdl_kbd

	jmp .kernel_lp
