# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# [Index Node] Constants

.equ IND_SIZE, 0x20

.equ IND_OFF_FILE_SIZE, 0x00
.equ IND_OFF_FILE_TYPE, 0x02
.equ IND_OFF_BLK_LEN, 0x03

.equ IND_OFF_BLK_0, 0x04
.equ IND_OFF_BLK_1, IND_OFF_BLK_0+0x04
.equ IND_OFF_BLK_2, IND_OFF_BLK_1+0x04
.equ IND_OFF_BLK_3, IND_OFF_BLK_2+0x04
.equ IND_OFF_BLK_4, IND_OFF_BLK_3+0x04
.equ IND_OFF_BLK_5, IND_OFF_BLK_4+0x04
.equ IND_OFF_BLK_6, IND_OFF_BLK_5+0x04
