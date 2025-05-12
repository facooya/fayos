# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Inode

# I_BLK_LEN_OFF

# Blocks
.equ I_BLK_LO_OFF, 0x00
.equ I_BLK_HI_OFF, I_BLK_LO_OFF+0x02

# File type
.equ I_FILE_TYPE_OFF, 0x1C
