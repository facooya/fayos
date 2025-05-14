# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Inode

# Information
.equ I_FILE_SIZE_OFF, 0x00 # 2
.equ I_FILE_TYPE_OFF, 0x02 # 1
.equ I_BLK_LEN_OFF, 0x03 # 1

# Block array 7
.equ I_BLK_LO_OFF, 0x04
.equ I_BLK_HI_OFF, I_BLK_LO_OFF+0x02
