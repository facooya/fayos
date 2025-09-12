# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Interrupt vector table initialization

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
	mov $irq_kbd, %es:(0x0084)
	mov %cs, %es:(0x0086)

	pop %es
	ret
