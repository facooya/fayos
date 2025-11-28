# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# [Interrupt] Real Time Clock

.include "int.s"
.include "drv/rtc.s"
.section .data
.global sec
sec: .word 0x00
.tick: .word 0x00

.section .text
.code16
.global irq_rtc

# irq 0x08
irq_rtc:
	push %ax

	# clr int
	mov $RTC_REG_C, %al
	out %al, $RTC_PORT_ADDR
	in $RTC_PORT_DATA, %al

	mov (.tick), %ax
	inc %ax
	cmp $0x0400, %ax
	jne .pass

	mov (sec), %ax
	inc %ax
	mov %ax, (sec)
	call dbg_a
	xor %ax, %ax

.pass:
	mov %ax, (.tick)

	mov $EOI, %al
	out %al, $PIC2_PORT_CMD
	out %al, $PIC1_PORT_CMD

	pop %ax
	iret
