# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Inode

# Immutable
.equ I_SIZE, 0x20

# Information
.equ I_FILE_SIZE_OFF, 0x00 # 2
.equ I_FILE_TYPE_OFF, 0x02 # 1
.equ I_BLK_LEN_OFF, 0x03 # 1

# Block array 7
.equ I_BLK_0_LO_OFF, 0x04
.equ I_BLK_0_HI_OFF, I_BLK_0_LO_OFF+0x02

.equ I_BLK_1_LO_OFF, I_BLK_0_HI_OFF+0x02
.equ I_BLK_1_HI_OFF, I_BLK_1_LO_OFF+0x02

.equ I_BLK_2_LO_OFF, I_BLK_1_HI_OFF+0x02
.equ I_BLK_2_HI_OFF, I_BLK_2_LO_OFF+0x02

.equ I_BLK_3_LO_OFF, I_BLK_2_HI_OFF+0x02
.equ I_BLK_3_HI_OFF, I_BLK_3_LO_OFF+0x02

.equ I_BLK_4_LO_OFF, I_BLK_3_HI_OFF+0x02
.equ I_BLK_4_HI_OFF, I_BLK_4_LO_OFF+0x02

.equ I_BLK_5_LO_OFF, I_BLK_4_HI_OFF+0x02
.equ I_BLK_5_HI_OFF, I_BLK_5_LO_OFF+0x02

.equ I_BLK_6_LO_OFF, I_BLK_5_HI_OFF+0x02
.equ I_BLK_6_HI_OFF, I_BLK_6_LO_OFF+0x02
