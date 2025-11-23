# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# [Interrupt] Real Time Clock

.include "drv/rtc.s"
.section .text
.code16
.global irq_rtc

# irq 0x08 || int $0x28
irq_rtc:
	push %ax

	call dbg_a

	# clr int
	mov $RTC_REG_NMI_C, %al
	out %al, $RTC_PORT_ADDR
	in $RTC_PORT_DATA, %al

	mov $0x20, %al
	out %al, $0x20
	out %al, $0xA0

	pop %ax
	iret
