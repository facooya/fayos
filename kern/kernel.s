# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Fayos kernel

.include "chr.s"
.section .data
.kmsg_welcome: .asciz "\r\nWelcome to Fayos\r\n"

.section .text
.code16
.global _start

# _start()
_start:
	call pic_init
	call ivt_init
	call vga_init

	call proc_super

	push $.kmsg_welcome
	call vga_puts
	add $0x02, %sp

	mov $CHR_CR, %al
	call vga_putc
	mov $CHR_LF, %al
	call vga_putc

	call init_ps1
	call build_ps1

	push $ps1
	call vga_puts
	add $0x02, %sp

	call vga_init_curs
	mov $raw_buf, %si
	add $0x02, %si

	# {main}
	call ps2_init
	jmp kernel_main

# kernel_main()
# <req> (*si == raw_buf.data)
kernel_main:
	sti
	hlt
	jmp kernel_main
