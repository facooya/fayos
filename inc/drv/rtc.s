# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# [Real Time Clock] Constants

.equ RTC_PORT_ADDR, 0x70
.equ RTC_PORT_DATA, 0x71

# NMI: Non-Maskable Interrupt
.equ RTC_NMI, (0x01<<0x07) # 0:enable, 1:disable

.equ RTC_REG_A, 0x0A
.equ RTC_REG_B, 0x0B
.equ RTC_REG_C, 0x0C
.equ RTC_REG_D, 0x0D # instead reg_c

.equ RTC_SEC, 0x00
.equ RTC_MIN, 0x02
.equ RTC_HOUR, 0x04
.equ RTC_WEEK, 0x06
.equ RTC_DAY, 0x07
.equ RTC_MONTH, 0x08
.equ RTC_YEAR, 0x09

# UIP: Update In Progress
.equ RTC_REG_A_UIP, (0x01<<0x07) # 0:safe, 1:updating
# DV: Divider
.equ RTC_REG_A_DV, 0x20 # b6-4: 0b010 [32.768 kHz]
# RS: Rate Selector
.equ RTC_REG_A_RS, 0x06 # b3-0: 0b0110 [1024 Hz]

# TF: Time Format
.equ RTC_REG_B_TF, (0x01<<0x01) # 0:12H, 1:24H
# DM: Data Mode, BCD: Binary Coded Decimal
.equ RTC_REG_B_DM, (0x01<<0x02) # 0:BCD, 1:Binary
# PIE: Piriodic Interrupt Enable
.equ RTC_REG_B_PIE, (0x01<<0x06) # 0:disable, 1:enable

# { Offset
.equ RTC_DATE_OFF_SEC, 0x00
.equ RTC_DATE_OFF_MIN, 0x01
.equ RTC_DATE_OFF_HOUR, 0x02
.equ RTC_DATE_OFF_WEEK, 0x03
.equ RTC_DATE_OFF_DAY, 0x04
.equ RTC_DATE_OFF_MONTH, 0x05
.equ RTC_DATE_OFF_YEAR, 0x06
# }
