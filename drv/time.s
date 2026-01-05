# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025-2026 Facooya and Fanone Facooya

.include "drv/rtc.inc"
.section .text
.code16
.global time_upd

# time_upd()
# <mod> rtc_date
time_upd:
	push %si

	xor %ax, %ax
	mov $rtc_date, %si

	# (sec < 60) ? {done} : {zero}
	mov RTC_DATE_SEC(%si), %al
	cmp $0x3C, %al
	jl 99f
	mov %ah, RTC_DATE_SEC(%si)

	# upd min
	mov RTC_DATE_MIN(%si), %al
	inc %al
	mov %al, RTC_DATE_MIN(%si)

	# (min < 60) ? {done} : {zero}
	cmp $0x3C, %al
	jl 99f
	mov %ah, RTC_DATE_MIN(%si)

	# upd hour
	mov RTC_DATE_HOUR(%si), %al
	inc %al
	mov %al, RTC_DATE_HOUR(%si)

	# (hour < 24) ? {done} : {zero}
	cmp $0x18, %al
	jl 99f
	mov %ah, RTC_DATE_HOUR(%si)

	# TODO: call rtc_upd_day

99:
	pop %si
	ret
