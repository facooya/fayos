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
	jmp .conf

	# set bit 1, bit 2
	#mov $RTC_REG_B, %al
	#out %al, $RTC_PORT_ADDR
	#mov $0x06, %al
	#out %al, $RTC_PORT_DATA

.chk_uip:
	mov $RTC_REG_A, %al
	out %al, $RTC_PORT_ADDR
	in $RTC_PORT_DATA, %al
	test $(0x01<<0x07), %al
	jnz .chk_uip

	# sec
	mov $RTC_ADDR_SEC, %al
	out %al, $RTC_PORT_ADDR
	in $RTC_PORT_DATA, %al
	mov %al, %bh

	# min
	mov $RTC_ADDR_MIN, %al
	out %al, $RTC_PORT_ADDR
	in $RTC_PORT_DATA, %al
	mov %al, %bl

	# hour
	mov $RTC_ADDR_HOUR, %al
	out %al, $RTC_PORT_ADDR
	in $RTC_PORT_DATA, %al
	mov %al, %ch

	# day
	mov $RTC_ADDR_DAY, %al
	out %al, $RTC_PORT_ADDR
	in $RTC_PORT_DATA, %al
	mov %al, %cl

	# month
	mov $RTC_ADDR_MONTH, %al
	out %al, $RTC_PORT_ADDR
	in $RTC_PORT_DATA, %al
	mov %al, %dh

	# year
	mov $RTC_ADDR_YEAR, %al
	out %al, $RTC_PORT_ADDR
	in $RTC_PORT_DATA, %al
	mov %al, %dl

	push %bx
	call dbg_reg
	add $0x02, %sp
	push %cx
	call dbg_reg
	add $0x02, %sp
	push %dx
	call dbg_reg
	add $0x02, %sp

.conf:
	# {
	mov $RTC_REG_NMI_B, %al
	out %al, $RTC_PORT_ADDR
	in $RTC_PORT_DATA, %al
	push %ax

	mov $RTC_REG_NMI_A, %al
	out %al, $RTC_PORT_ADDR
	in $RTC_PORT_DATA, %al
	and $0xF0, %al
	or $0x06, %al
	or $0x02, %al
	mov %al, %bl
	mov $RTC_REG_NMI_A, %al
	out %al, $RTC_PORT_ADDR
	mov %bl, %al
	out %al, $RTC_PORT_DATA

	pop %ax
	or $0x40, %al
	and $0x7F, %al
	mov %al, %bl
	mov $RTC_REG_NMI_B, %al
	out %al, $RTC_PORT_ADDR
	mov %bl, %al
	out %al, $RTC_PORT_DATA

	mov $RTC_REG_NMI_C, %al
	out %al, $RTC_PORT_ADDR
	in $RTC_PORT_DATA, %al
	# }

.done:
	pop %bx
	ret
