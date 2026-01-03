# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025-2026 Facooya and Fanone Facooya

.include "drv/rtc.inc"
.section .text
.code16
.global rtc_init
.global rtc_get

# rtc_init()
rtc_init:
	# { reg a
	mov $(RTC_ADDR_REG_A|RTC_NMI), %al
	out %al, $RTC_PORT_ADDR
	in $RTC_PORT_DATA, %al

	mov %al, %ah # value
	and $RTC_REG_A_UIP, %ah
	or $RTC_REG_A_DV, %ah # 32.768 khz
	or $RTC_REG_A_RS, %ah # 1024 hz

	mov $(RTC_ADDR_REG_A|RTC_NMI), %al
	out %al, $RTC_PORT_ADDR
	in $RTC_PORT_DATA, %al
	mov %ah, %al # value
	out %al, $RTC_PORT_DATA
	# }

	# { reg b
	mov $(RTC_ADDR_REG_B|RTC_NMI), %al
	out %al, $RTC_PORT_ADDR
	in $RTC_PORT_DATA, %al

	mov %al, %ah # value
	or $RTC_REG_B_TF, %ah # 24h
	or $RTC_REG_B_DM, %ah # binary
	or $RTC_REG_B_PIE, %ah # enable

	mov $(RTC_ADDR_REG_B|RTC_NMI), %al
	out %al, $RTC_PORT_ADDR
	in $RTC_PORT_DATA, %al
	mov %ah, %al # value
	out %al, $RTC_PORT_DATA
	# }

	# enable nmi
	mov $RTC_ADDR_REG_D, %al
	out %al, $RTC_PORT_ADDR
	in $RTC_PORT_DATA, %al

	ret

# rtc_get()
# <mod> rtc_date
rtc_get:
	push %di
	mov $rtc_date, %di

1:
	mov $(RTC_ADDR_REG_A|RTC_NMI), %al
	out %al, $RTC_PORT_ADDR
	in $RTC_PORT_DATA, %al
	test $RTC_REG_A_UIP, %al
	jnz 1b

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
