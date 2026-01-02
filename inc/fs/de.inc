# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# [Directory Entry] Constants

# Structure
.equ DE_SIZE, 0x06
.equ DE_ALIGN_2, 0x01
.equ DE_MASK, 0xFFFE # 0b1110

# Offset
.equ DE_OFF_INUM, 0x00
.equ DE_OFF_REC_SIZE, 0x02
.equ DE_OFF_F_TYPE, 0x04
.equ DE_OFF_NAME_SIZE, 0x05
.equ DE_OFF_NAME, 0x06

# Dots - S: single, D: double
.equ DE_S_DOT_NAME, 0x2E
.equ DE_S_DOT_INFO, 0x4001
.equ DE_D_DOT_NAME, 0x2E2E
.equ DE_D_DOT_INFO, 0x4002
