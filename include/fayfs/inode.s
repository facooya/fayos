# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Inode

# Immutable
.equ I_SIZE, 0x20

# Information
.equ I_FILE_SIZE_OFF, 0x00
.equ I_FILE_TYPE_OFF, 0x02
.equ I_BLK_LEN_OFF, 0x03

# Block array 7
.equ I_BLK_0_OFF, 0x04
.equ I_BLK_1_OFF, I_BLK_0_OFF+0x04
.equ I_BLK_2_OFF, I_BLK_1_OFF+0x04
.equ I_BLK_3_OFF, I_BLK_2_OFF+0x04
.equ I_BLK_4_OFF, I_BLK_3_OFF+0x04
.equ I_BLK_5_OFF, I_BLK_4_OFF+0x04
.equ I_BLK_6_OFF, I_BLK_5_OFF+0x04
