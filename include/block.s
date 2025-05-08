# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Block constants

# DENTRY
# .equ DE_SIZE, 0x0A

# .equ DE_MN, 0x00 # Magic Number (0xFADE)
# .equ DE_FNS, 0x02 # File Name Size
# .equ DE_FNP, 0x03 # File Name Padding
# .equ DE_LBAL, 0x04 # LBA Low
# .equ DE_LBAH, 0x06 # LBA High
# .equ DE_EL, 0x08 # Entry Level
# .equ DE_FT, 0x09 # File Type

# DENTRY
.equ DE_IN, 0x00 # [32] Index Node
.equ DE_RL, 0x04 # [16] Record Length
.equ DE_NL, 0x06 # [8] Name Length
.equ DE_FT, 0x07 # [8] File Type
.equ DE_N, 0x00 # Name

# METADATA
# .equ MD_SIZE, 0x06 # Size

# .equ MD_LBAL, 0x00 # LBA Low
# .equ MD_LBAH, 0x02 # LBA High
# .equ MD_MN, 0x04 # Magic Number (0xFADA)
