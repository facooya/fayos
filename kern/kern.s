# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025-2026 Facooya and Fanone Facooya

.include "chr.inc"
.include "drv/ps2.inc"
.section .text
.code16
.global _start

# _start()
_start:
	cli
	call pic_init
	call ivt_init
	call vga_init

	call ata_init
	call ps2_init
	call rtc_init
	call rtc_get
	sti

	xor %ax, %ax
	mov %ax, (init_flag)

	call sb_run

	push $_kmsg_welcome
	call vga_outs
	add $0x02, %sp

	mov $CHR_CR, %al
	call vga_outc
	mov $CHR_LF, %al
	call vga_outc

	call cwd_init
	call ps1_build

	push $ps1
	call vga_outs
	add $0x02, %sp

	call vga_init_curs
	mov $cl_sbuf, %si
	add $0x02, %si

	jmp .run

# run()
# <req> (*si == cl_sbuf.data)
.run:
	# (chr == null) ? {pass} : {kbd_run}
	mov (scancode), %al
	test %al, %al
	jz .pass

	call kbd_run

.pass:
	hlt
	jmp .run

.section .data
_kmsg_welcome: .asciz "\r\nWelcome to Fayos\r\n"
