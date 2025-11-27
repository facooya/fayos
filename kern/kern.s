# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# [Kernel] Main

.include "chr.s"
.include "drv/ps2.s"
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

	push $.kmsg_welcome
	call vga_puts
	add $0x02, %sp

	mov $CHR_CR, %al
	call vga_putc
	mov $CHR_LF, %al
	call vga_putc

	call cwd_init
	call ps1_build

	push $ps1
	call vga_puts
	add $0x02, %sp

	call vga_init_curs
	mov $cl_sbuf, %si
	add $0x02, %si

	call ps2_init
	call rtc_init

	xor %ax, %ax
	mov %ax, (scan_code)

	jmp .run

# run()
# <req> (*si == cl_sbuf.data)
.run:
	sti

	# (chr == null) ? {pass} : {kbd_proc}
	mov (scan_code), %al
	test %al, %al
	jz .pass

	#mov (scan_code), %ax
	#push %ax
	#call dbg_reg
	#add $0x02, %sp

	call kbd_proc

.pass:
	hlt
	jmp .run
