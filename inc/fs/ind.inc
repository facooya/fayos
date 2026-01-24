# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025-2026 Facooya and Fanone Facooya

.equ IND_SIZE, 0x20
.equ IND_MAX_BLK, 0x0E

.equ IND_OFF_F_SIZE, 0x00 # [2-byte]
.equ IND_OFF_F_TYPE, 0x02 # [1-byte]
.equ IND_OFF_BLK_CNT, 0x03 # [1-byte]

.equ IND_OFF_BLK, 0x04 # [2-byte] * 14
