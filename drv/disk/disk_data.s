# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# [Disk] Data

.section .data
.global dpi # Disk Packet Immutable
.global dp # Disk Packet
dpi: .zero 0x100
dp: .zero 0x100
# 0:cur, 1:par, 2:tmp
# sect_cnt, mem, lba
