# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya

# port
.equ RTC_PORT_ADDR, 0x70
.equ RTC_PORT_DATA, 0x71

# { addr
.equ RTC_ADDR_REG_A, 0x0A
.equ RTC_ADDR_REG_B, 0x0B
.equ RTC_ADDR_REG_C, 0x0C
.equ RTC_ADDR_REG_D, 0x0D

.equ RTC_ADDR_SEC, 0x00
.equ RTC_ADDR_MIN, 0x02
.equ RTC_ADDR_HOUR, 0x04
.equ RTC_ADDR_WEEK, 0x06
.equ RTC_ADDR_DAY, 0x07
.equ RTC_ADDR_MONTH, 0x08
.equ RTC_ADDR_YEAR, 0x09

.equ RTC_NMI, (0x01<<0x07)
# }

# { reg
.equ RTC_REG_A_UIP, (0x01<<0x07)
.equ RTC_REG_A_DV, 0x20
.equ RTC_REG_A_RS, 0x06

.equ RTC_REG_B_TF, (0x01<<0x01)
.equ RTC_REG_B_DM, (0x01<<0x02)
.equ RTC_REG_B_PIE, (0x01<<0x06)
# }

# rtc_date
.equ RTC_DATE_SEC, 0x00
.equ RTC_DATE_MIN, 0x01
.equ RTC_DATE_HOUR, 0x02
.equ RTC_DATE_WEEK, 0x03
.equ RTC_DATE_DAY, 0x04
.equ RTC_DATE_MONTH, 0x05
.equ RTC_DATE_YEAR, 0x06
