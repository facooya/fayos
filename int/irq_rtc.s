# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# [Interrupt] Real Time Clock

.include "drv/rtc.s"
.section .data
.global sec
sec: .word 0x00
.tick: .word 0x00

.section .text
.code16
.global irq_rtc

# irq 0x08 || int $0x28
irq_rtc:
	push %ax

	mov (.tick), %ax
	inc %ax
	cmp $0x0400, %ax
	jne .pass
	call dbg_a

	mov (sec), %ax
	inc %ax
	mov %ax, (sec)
	xor %ax, %ax

.pass:
	mov %ax, (.tick)

	# clr int
	mov $RTC_REG_NMI_C, %al
	out %al, $RTC_PORT_ADDR
	in $RTC_PORT_DATA, %al

	mov $0x20, %al
	out %al, $0xA0
	out %al, $0x20

	pop %ax
	iret
