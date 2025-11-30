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
	# { reg a
	mov $(RTC_REG_A|RTC_NMI), %al
	out %al, $RTC_PORT_ADDR
	in $RTC_PORT_DATA, %al

	mov %al, %ah # value
	and $RTC_REG_A_UIP, %ah
	or $RTC_REG_A_DV, %ah # 32.768 khz
	or $RTC_REG_A_RS, %ah # 1024 hz

	mov $(RTC_REG_A|RTC_NMI), %al
	out %al, $RTC_PORT_ADDR
	in $RTC_PORT_DATA, %al
	mov %ah, %al # value
	out %al, $RTC_PORT_DATA
	# }

	# { reg b
	mov $(RTC_REG_B|RTC_NMI), %al
	out %al, $RTC_PORT_ADDR
	in $RTC_PORT_DATA, %al

	mov %al, %ah # value
	or $RTC_REG_B_TF, %ah # 24h
	or $RTC_REG_B_DM, %ah # binary
	or $RTC_REG_B_PIE, %ah # enable

	mov $(RTC_REG_B|RTC_NMI), %al
	out %al, $RTC_PORT_ADDR
	in $RTC_PORT_DATA, %al
	mov %ah, %al # value
	out %al, $RTC_PORT_DATA
	# }

	# enable nmi
	mov $RTC_REG_D, %al
	out %al, $RTC_PORT_ADDR
	in $RTC_PORT_DATA, %al

.done:
	ret
