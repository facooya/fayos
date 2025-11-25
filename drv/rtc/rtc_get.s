# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# [Real Time Clock] Get time

.include "chr.s"
.include "drv/rtc.s"
.section .text
.code16
.global rtc_get

# rtc_get()
# <ret> rtc_date
rtc_get:
	push %di
	mov $rtc_date, %di

.uip__lp:
	mov $RTC_REG_A, %al
	out %al, $RTC_PORT_ADDR
	in $RTC_PORT_DATA, %al
	test $RTC_REG_A_BIT_UIP, %al
	jnz .uip__lp

	# sec
	mov $RTC_SEC, %al
	out %al, $RTC_PORT_ADDR
	in $RTC_PORT_DATA, %al
	mov %al, (%di)
	inc %di

	# min
	mov $RTC_MIN, %al
	out %al, $RTC_PORT_ADDR
	in $RTC_PORT_DATA, %al
	mov %al, (%di)
	inc %di

	# hour
	mov $RTC_HOUR, %al
	out %al, $RTC_PORT_ADDR
	in $RTC_PORT_DATA, %al
	mov %al, (%di)
	inc %di

	# week
	mov $RTC_WEEK, %al
	out %al, $RTC_PORT_ADDR
	in $RTC_PORT_DATA, %al
	mov %al, (%di)
	inc %di

	# day
	mov $RTC_DAY, %al
	out %al, $RTC_PORT_ADDR
	in $RTC_PORT_DATA, %al
	mov %al, (%di)
	inc %di

	# month
	mov $RTC_MONTH, %al
	out %al, $RTC_PORT_ADDR
	in $RTC_PORT_DATA, %al
	mov %al, (%di)
	inc %di

	# year
	mov $RTC_YEAR, %al
	out %al, $RTC_PORT_ADDR
	in $RTC_PORT_DATA, %al
	mov %al, (%di)

	pop %di
	ret
