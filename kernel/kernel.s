# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Kernel for Fayos

.section .data
.global kernel_prompt
kernel_prompt: .asciz "fayos:/# "
.kmsg_welcome: .asciz "\nWelcome to Fayos kernel\r\n"

.section .text
.code16
.global _start

# _start()
_start:
	call init_super

	push $.kmsg_welcome
	call outs
	add $0x02, %sp

	call outnl

	push $kernel_prompt
	call outs
	add $0x02, %sp

	call init_cursor
	mov $raw_buf, %si
	add $0x02, %si

	# {main}
	jmp kernel_main

# kernel_main()
# <REQ>
# (*si == raw_buf.data)
kernel_main:
	# {main}
	call sys_read_key
	call cli_main

	# {lp}
	jmp kernel_main
