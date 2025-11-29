# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# [Real Time Clock] Initialization

.include "drv/rtc.s"
.section .text
.code16
.global rtc_init

# rtc_init()
rtc_init:
	push %bx

	# set bit 1, bit 2
	mov $(RTC_REG_B|RTC_NMI), %al
	out %al, $RTC_PORT_ADDR
	mov $0x06, %al
	out %al, $RTC_PORT_DATA

	# {
	mov $(RTC_REG_B|RTC_NMI), %al
	out %al, $RTC_PORT_ADDR
	in $RTC_PORT_DATA, %al
	push %ax

	mov $(RTC_REG_A|RTC_NMI), %al
	out %al, $RTC_PORT_ADDR
	in $RTC_PORT_DATA, %al
	and $0xF0, %al
	or $0x06, %al
	or $0x02, %al
	mov %al, %bl
	mov $(RTC_REG_A|RTC_NMI), %al
	out %al, $RTC_PORT_ADDR
	mov %bl, %al
	out %al, $RTC_PORT_DATA

	pop %ax
	or $0x40, %al
	and $0x7F, %al
	mov %al, %bl
	mov $(RTC_REG_B|RTC_NMI), %al
	out %al, $RTC_PORT_ADDR
	mov %bl, %al
	out %al, $RTC_PORT_DATA

	# nmi enable
	mov $RTC_REG_D, %al
	out %al, $RTC_PORT_ADDR
	in $RTC_PORT_DATA, %al
	# }

.done:
	pop %bx
	ret
