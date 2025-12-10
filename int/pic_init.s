# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya

.include "int.s"
.section .text
.code16
.global pic_init

# pic_init()
pic_init:
	# init
	mov $(ICW1_INIT|ICW1_ICW4), %al
	out %al, $PIC1_PORT_CMD
	out %al, $IO_WAIT
	out %al, $PIC2_PORT_CMD
	out %al, $IO_WAIT

	# irq remap
	mov $ICW2_PIC1, %al
	out %al, $PIC1_PORT_DATA
	out %al, $IO_WAIT
	mov $ICW2_PIC2, %al
	out %al, $PIC2_PORT_DATA
	out %al, $IO_WAIT

	# connect
	mov $ICW3_PIC1_PIC2, %al
	out %al, $PIC1_PORT_DATA
	out %al, $IO_WAIT
	mov $ICW3_PIC2_ID, %al
	out %al, $PIC2_PORT_DATA
	out %al, $IO_WAIT

	# cpu mode
	mov $ICW4_8086, %al
	out %al, $PIC1_PORT_DATA
	out %al, $IO_WAIT
	out %al, $PIC2_PORT_DATA
	out %al, $IO_WAIT

	# { ocw 1
	# disable irq all
	mov $IMR_INIT, %al
	out %al, $PIC1_PORT_DATA
	out %al, $IO_WAIT
	out %al, $PIC2_PORT_DATA
	out %al, $IO_WAIT

	# enable irq 1
	in $PIC1_PORT_DATA, %al
	and $~IMR_BIT_IRQ1, %al
	out %al, $PIC1_PORT_DATA
	out %al, $IO_WAIT

	# enable irq 2
	in $PIC1_PORT_DATA, %al
	and $~IMR_BIT_IRQ2, %al
	out %al, $PIC1_PORT_DATA
	out %al, $IO_WAIT

	# enable irq 8
	in $PIC2_PORT_DATA, %al
	and $~IMR_BIT_IRQ8, %al
	out %al, $PIC2_PORT_DATA
	out %al, $IO_WAIT

	# enable irq 14
	in $PIC2_PORT_DATA, %al
	and $~IMR_BIT_IRQ14, %al
	out %al, $PIC2_PORT_DATA
	out %al, $IO_WAIT
	# }

	ret
