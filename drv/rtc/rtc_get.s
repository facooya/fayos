# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya

.include "chr.s"
.include "drv/rtc.s"
.section .text
.code16
.global rtc_get

# rtc_get()
# <mod> rtc_date
rtc_get:
	push %di
	mov $rtc_date, %di

.uip__lp:
	mov $(RTC_ADDR_REG_A|RTC_NMI), %al
	out %al, $RTC_PORT_ADDR
	in $RTC_PORT_DATA, %al
	test $RTC_REG_A_UIP, %al
	jnz .uip__lp

	# sec
	mov $(RTC_ADDR_SEC|RTC_NMI), %al
	out %al, $RTC_PORT_ADDR
	in $RTC_PORT_DATA, %al
	mov %al, (%di)
	inc %di

	# min
	mov $(RTC_ADDR_MIN|RTC_NMI), %al
	out %al, $RTC_PORT_ADDR
	in $RTC_PORT_DATA, %al
	mov %al, (%di)
	inc %di

	# hour
	mov $(RTC_ADDR_HOUR|RTC_NMI), %al
	out %al, $RTC_PORT_ADDR
	in $RTC_PORT_DATA, %al
	mov %al, (%di)
	inc %di

	# week
	mov $(RTC_ADDR_WEEK|RTC_NMI), %al
	out %al, $RTC_PORT_ADDR
	in $RTC_PORT_DATA, %al
	mov %al, (%di)
	inc %di

	# day
	mov $(RTC_ADDR_DAY|RTC_NMI), %al
	out %al, $RTC_PORT_ADDR
	in $RTC_PORT_DATA, %al
	mov %al, (%di)
	inc %di

	# month
	mov $(RTC_ADDR_MONTH|RTC_NMI), %al
	out %al, $RTC_PORT_ADDR
	in $RTC_PORT_DATA, %al
	mov %al, (%di)
	inc %di

	# year
	mov $(RTC_ADDR_YEAR|RTC_NMI), %al
	out %al, $RTC_PORT_ADDR
	in $RTC_PORT_DATA, %al
	mov %al, (%di)

	# enable nmi
	mov $RTC_ADDR_REG_D, %al
	out %al, $RTC_PORT_ADDR
	in $RTC_PORT_DATA, %al

	pop %di
	ret
