# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya

.section .text
.code16
.global ivt_init

# ivt_init()
ivt_init:
	push %es

	xor %ax, %ax
	mov %ax, %es

	# irq 0
	mov $interrupt, %es:(0x0080)
	mov %cs, %es:(0x0082)

	# irq 1
	mov $isr_ps2, %es:(0x0084)
	mov %cs, %es:(0x0086)

	# irq 8
	mov $isr_rtc, %es:(0x00A0)
	mov %cs, %es:(0x00A2)

	# irq 14
	mov $isr_ata, %es:(0x00B8)
	mov %cs, %es:(0x00BA)

	pop %es
	ret
