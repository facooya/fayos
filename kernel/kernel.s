# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Fayos kernel

.section .data
.kmsg_welcome: .asciz "\nWelcome to Fayos\r\n"

.section .text
.code16
.global _start

# _start()
_start:
	# interrupt handler
	mov $interrupt, 0x00C0
	mov %cs, 0x00C2
	mov $int_kbd, 0x00C4
	mov %cs, 0x00C6

	call proc_super

	push $.kmsg_welcome
	call outs
	add $0x02, %sp

	call outnl

	call init_ps1
	call build_ps1

	push $ps1
	call outs
	add $0x02, %sp

	call init_cursor
	mov $raw_buf, %si
	add $0x02, %si

	# {main}
	call off_conf_byte_bit6
	call chk_scan_code_set
	jmp kernel_main

# kernel_main()
# <req> (*si == raw_buf.data)
kernel_main:
	call read_key
	call kbd_main

	# {lp}
	jmp kernel_main
