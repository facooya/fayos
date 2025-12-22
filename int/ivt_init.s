# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya

.include "int.s"
.section .text
.code16
.global ivt_init

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
