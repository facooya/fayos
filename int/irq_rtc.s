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

.section .text
.code16
.global irq_rtc

# irq 0x08
irq_rtc:
	push %ax

	xchg %bx, %bx

	# (init_flag != 0) ? {skip}
	mov (init_flag), %ax
	test %ax, %ax
	jnz .skip

	# clr int
	mov $RTC_REG_NMI_C, %al
	out %al, $RTC_PORT_ADDR
	in $RTC_PORT_DATA, %al

	mov (rtc_tick), %ax
	cmp $0x0400, %ax
	jne .tick

	mov (sec), %ax
	inc %ax
	mov %ax, (sec)
	call dbg_a
	xor %ax, %ax
	mov %ax, (rtc_tick)
	jmp .done

.tick:
	inc %ax
	mov %ax, (rtc_tick)
	jmp .done

.skip:
	mov $RTC_REG_NMI_C, %al
	out %al, $RTC_PORT_ADDR
	in $RTC_PORT_DATA, %al
	jmp .done

.done:
	mov $EOI, %al
	out %al, $PIC2_PORT_CMD
	out %al, $PIC1_PORT_CMD

	pop %ax
	iret
