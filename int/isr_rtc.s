# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya

.include "int.s"
.include "drv/rtc.s"
.section .text
.code16
.global isr_rtc

# isr 0x08
isr_rtc:
	push %ax

	# clr int
	mov $(RTC_ADDR_REG_C|RTC_NMI), %al
	out %al, $RTC_PORT_ADDR
	in $RTC_PORT_DATA, %al

	mov $RTC_ADDR_REG_D, %al
	out %al, $RTC_PORT_ADDR
	in $RTC_PORT_DATA, %al

	# (init_flag != 0) ? {skip}
	mov (init_flag), %ax
	test %ax, %ax
	jnz .done

	mov (rtc_tick), %ax
	cmp $0x0400, %ax
	jne .tick

	mov (rtc_date), %ax
	inc %ax
	mov %ax, (rtc_date)
	call rtc_upd_time

	xor %ax, %ax
	inc %ax
	mov %ax, (rtc_tick)
	jmp .done

.tick:
	inc %ax
	mov %ax, (rtc_tick)
	jmp .done

.done:
	mov $EOI, %al
	out %al, $PIC2_PORT_CMD
	out %al, $PIC1_PORT_CMD

	pop %ax
	iret
