# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# [Real Time Clock] Constants

.equ RTC_PORT_ADDR, 0x70
.equ RTC_PORT_DATA, 0x71

# NMI: Non-Maskable Interrupt
.equ RTC_REG_A, 0x0A
.equ RTC_REG_B, 0x0B
.equ RTC_REG_C, 0x0C
.equ RTC_REG_NMI_A, 0x8A
.equ RTC_REG_NMI_B, 0x8B
.equ RTC_REG_NMI_C, 0x8C

.equ RTC_ADDR_SEC, 0x00
.equ RTC_ADDR_MIN, 0x02
.equ RTC_ADDR_HOUR, 0x04
.equ RTC_ADDR_DAY, 0x07
.equ RTC_ADDR_MONTH, 0x08
.equ RTC_ADDR_YEAR, 0x09
