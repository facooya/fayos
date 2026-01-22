# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025-2026 Facooya and Fanone Facooya

.include "int.inc"
.section .text
.code16
.global pic_init
.global ivt_init

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
	mov $ICW3_PIC2_IDX, %al
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
	mov $IMR_IRQ_ALL, %al
	out %al, $PIC1_PORT_DATA
	out %al, $IO_WAIT
	out %al, $PIC2_PORT_DATA
	out %al, $IO_WAIT

	# enable irq 1
	in $PIC1_PORT_DATA, %al
	and $~IMR_IRQ1, %al
	out %al, $PIC1_PORT_DATA
	out %al, $IO_WAIT

	# enable irq 2
	in $PIC1_PORT_DATA, %al
	and $~IMR_IRQ2, %al
	out %al, $PIC1_PORT_DATA
	out %al, $IO_WAIT

	# enable irq 8
	in $PIC2_PORT_DATA, %al
	and $~IMR_IRQ8, %al
	out %al, $PIC2_PORT_DATA
	out %al, $IO_WAIT

	# enable irq 14
	in $PIC2_PORT_DATA, %al
	and $~IMR_IRQ14, %al
	out %al, $PIC2_PORT_DATA
	out %al, $IO_WAIT
	# }
	ret

# ivt_init()
ivt_init:
	push %es

	xor %ax, %ax
	mov %ax, %es

	# irq 1
	movw %cs, %es:(IVT_ENT_IRQ1+0x02)
	movw $isr_ps2, %es:(IVT_ENT_IRQ1)

	# irq 8
	movw %cs, %es:(IVT_ENT_IRQ8+0x02)
	movw $isr_rtc, %es:(IVT_ENT_IRQ8)

	# irq 14
	movw %cs, %es:(IVT_ENT_IRQ14+0x02)
	movw $isr_ata, %es:(IVT_ENT_IRQ14)

	pop %es
	ret
