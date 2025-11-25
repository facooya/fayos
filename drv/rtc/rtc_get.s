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
# <ret> date_zbuf
rtc_get:
	push %di
	mov $date_zbuf, %di

.uip__lp:
	mov $RTC_REG_A, %al
	out %al, $RTC_PORT_ADDR
	in $RTC_PORT_DATA, %al
	test $RTC_REG_A_BIT_UIP, %al
	jnz .uip__lp

	# year
	mov $RTC_ADDR_YEAR, %al
	out %al, $RTC_PORT_ADDR
	in $RTC_PORT_DATA, %al
	call ._save
	mov $CHR_SL, %al
	mov %al, (%di)
	inc %di

	# month
	mov $RTC_ADDR_MONTH, %al
	out %al, $RTC_PORT_ADDR
	in $RTC_PORT_DATA, %al
	call ._save
	mov $CHR_SL, %al
	mov %al, (%di)
	inc %di

	# day
	mov $RTC_ADDR_DAY, %al
	out %al, $RTC_PORT_ADDR
	in $RTC_PORT_DATA, %al
	call ._save
	mov $CHR_SP, %al
	mov %al, (%di)
	inc %di

	# hour
	mov $RTC_ADDR_HOUR, %al
	out %al, $RTC_PORT_ADDR
	in $RTC_PORT_DATA, %al
	call ._save
	mov $CHR_COL, %al
	mov %al, (%di)
	inc %di

	# min
	mov $RTC_ADDR_MIN, %al
	out %al, $RTC_PORT_ADDR
	in $RTC_PORT_DATA, %al
	call ._save
	mov $CHR_COL, %al
	mov %al, (%di)
	inc %di

	# sec
	mov $RTC_ADDR_SEC, %al
	out %al, $RTC_PORT_ADDR
	in $RTC_PORT_DATA, %al
	call ._save

	# last
	xor %ax, %ax
	mov %al, (%di)

.done:
	pop %di
	ret

._save:
	mov %al, %ah
	and $0xF0, %al
	shr $0x04, %al
	add $0x30, %al
	mov %al, (%di)
	inc %di

	mov %ah, %al
	and $0x0F, %al
	add $0x30, %al
	mov %al, (%di)
	inc %di
	ret
