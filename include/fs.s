# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Dentry constants, []: Byte

# INDEX NODE OFFSET [64]
.equ IN_BN, 0x00 # [24] Block Number (Max: 6)
.equ IN_FS, 0x18 # [4] File Size
.equ IN_FT, 0x1C # [1] File Type
.equ IN_R, 0x1D # [3] Reserved for align

# DIRECTORY ENTRY OFFSET [9-263] (12-264)
.equ DE_IN, 0x00 # [4] Index Node
.equ DE_RL, 0x04 # [2] Record Length
.equ DE_NL, 0x06 # [1] Name Length
.equ DE_FT, 0x07 # [1] File Type
.equ DE_N, 0x08 # [1-255] Name, [0-3] Padding

# SUPER BLOCK OFFSET [28]
# .equ SB_TOTAL_IN, 0x00 # [4] Inode Count
# .equ SB_TOTAL_BLK, 0x04 # [4] Block Count

# First Inode: 0x02
.equ SB_IN_LO, 0x00 # [2] Inode Low
.equ SB_IN_HI, 0x02 # [2] Inode High

# First Block: 0x01
.equ SB_BLK_LO, 0x04 # [2] Block Low
.equ SB_BLK_HI, 0x06 # [2] Block High

# First LBA: 0x80
.equ SB_LBA_LO, 0x08 # [2] LBA Low
.equ SB_LBA_HI, 0x0A # [2] LBA High

# Inode Table LBA: 0x10
.equ SB_IT_LBA_LO, 0x0C # [2] Table LBA Low
.equ SB_IT_LBA_HI, 0x0E # [2] Table LBA High

.equ SB_IN_SIZE, 0x10 # [1] Inode Size: 0x40
.equ SB_R, 0x11 # [3] Reserved for align
