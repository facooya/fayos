# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# [Disk] Data

.section .data
.global dnum
.global dflg
.global dio

dnum: .word 0x00 # dnum * 0x0A = dio_off
dflg: .word 0x00 # usage
dio: .zero 0x100
# 0x00: sb
# 0x01: bb
# 0x02: ib
# 0x03: it
#
# size: 0x0A
# .word sect_cnt
# .word seg
# .word off
# .word lba_hi
# .word lba_lo
