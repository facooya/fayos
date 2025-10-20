# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# [Kernel] Main

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

	call sb_run
	call disk_init

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
	mov $cl_lbuf, %si
	add $0x02, %si

	call ps2_init
	jmp .run

# run()
# <req> (*si == cl_lbuf.data)
.run:
	sti
	hlt
	jmp .run
