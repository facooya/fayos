# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Dentry constants, []: Byte

# INDEX NODE [64]
.equ IN_BN, 0x00 # [24] Block Number (Max: 6)
.equ IN_FS, 0x18 # [4] File Size
.equ IN_FT, 0x1C # [1] File Type
.equ IN_R, 0x1D # [3] Reserved for align

# DIRECTORY ENTRY [9-263] (12-264)
.equ DE_IN, 0x00 # [4] Index Node
.equ DE_RL, 0x04 # [2] Record Length
.equ DE_NL, 0x06 # [1] Name Length
.equ DE_FT, 0x07 # [1] File Type
.equ DE_N, 0x08 # [1-255] Name, [0-3] Padding

# SUPER BLOCK [12]
.equ SB_IC, 0x00 # [4] Inode Count
.equ SB_BC, 0x04 # [4] Block Count
.equ SB_IS, 0x08 # [1] Inode Size: 64
.equ SB_FI, 0x09 # [1] First Inode: 10
.equ SB_R, 0x00 # [2] Reserved for align
