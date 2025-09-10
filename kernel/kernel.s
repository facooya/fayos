# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Fayos kernel

# reference link
# http://wiki.osdev.org/8259_PIC

.section .data
.kmsg_welcome: .asciz "\nWelcome to Fayos\r\n"

.section .text
.code16
.global _start

# _start()
_start:
	call ._pic_init

	# enable irq 1
	in $0x21, %al
	and $0xFD, %al
	out %al, $0x21

	# interrupt handler
	xor %ax, %ax
	mov %ax, %es

	# irq 0
	mov $interrupt, %es:(0x00C0)
	mov %cs, %es:(0x00C2)

	# irq 1
	mov $int_kbd, %es:(0x00C4)
	mov %cs, %es:(0x00C6)

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

._io_wait:
	out %al, $0x80
	ret

# 0x20 PIC1
# 0xA0 PIC2
._pic_init:
	# init
	mov $0x11, %al # ICW1_INIT+ICW1_ICW4
	out %al, $0x20
	call ._io_wait
	out %al, $0xA0
	call ._io_wait

	# IRQ remap
	mov $0x30, %al # master PIC
	out %al, $0x21
	call ._io_wait
	mov $0x38, %al # slave PIC
	out %al, $0xA1
	call ._io_wait

	# connect
	mov $0x04, %al
	out %al, $0x21
	call ._io_wait
	mov $0x02, %al
	out %al, $0xA1
	call ._io_wait

	mov $0x01, %al # ICW4_8086
	out %al, $0x21
	call ._io_wait
	out %al, $0xA1
	call ._io_wait

	mov $0xFF, %al
	out %al, $0x21
	out %al, $0xA1
	ret

# kernel_main()
# <req> (*si == raw_buf.data)
kernel_main:
	sti
	hlt
	jmp kernel_main
