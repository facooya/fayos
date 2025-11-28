# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# [Programmable Interrupt Controller] Initialize

# reference link
# http://wiki.osdev.org/8259_PIC

.include "int.s"
.section .text
.code16
.global pic_init

# pic_init()
pic_init:
	# init
	mov $(ICW1_INIT|ICW1_ICW4), %al # ICW1_INIT+ICW1_ICW4
	out %al, $PIC1_PORT_CMD
	out %al, $IO_WAIT
	out %al, $PIC2_PORT_CMD
	out %al, $IO_WAIT

	# IRQ remap 0x20-0x2F
	mov $ICW2_PIC1, %al
	out %al, $PIC1_PORT_DATA
	out %al, $IO_WAIT
	mov $ICW2_PIC2, %al
	out %al, $PIC2_PORT_DATA
	out %al, $IO_WAIT

	# connect
	mov $ICW3_PIC1, %al
	out %al, $PIC1_PORT_DATA
	out %al, $IO_WAIT
	mov $ICW3_PIC2, %al
	out %al, $PIC2_PORT_DATA
	out %al, $IO_WAIT

	mov $ICW4_8086, %al
	out %al, $PIC1_PORT_DATA
	out %al, $IO_WAIT
	out %al, $PIC2_PORT_DATA
	out %al, $IO_WAIT

	mov $0xFF, %al
	out %al, $PIC1_PORT_DATA
	out %al, $PIC2_PORT_DATA

	# enable irq 1
	in $PIC1_PORT_DATA, %al
	and $0xFD, %al
	out %al, $PIC1_PORT_DATA

	# { enable irq 8
	in $PIC2_PORT_DATA, %al
	and $~(0x01<<0x00), %al
	out %al, $PIC2_PORT_DATA

	in $PIC1_PORT_DATA, %al
	and $~(0x01<<0x02), %al
	out %al, $PIC1_PORT_DATA
	# }

	ret
