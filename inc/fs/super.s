# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Superblock constants

# Header [0x00-0x1F]
.equ S_MAG_OFF, 0x00 # [4-byte]

# Disk Parameter [0x20-0x3F]
.equ DP_BUF_OFF, 0x20
.equ DP_LBA_SIZE_OFF, 0x30 # [4-byte]

# LBA info by DP [0x40-0x6F]
# BB: Block Bitmap
# IB: Inum Bitmap
# IT: Inode Table
# *S: Size
# *BC: Block Count

# Size [0x40-0x4F] [4-byte]
.equ BBS_OFF, 0x40
.equ IBS_OFF, 0x44
.equ ITS_OFF, 0x48

# Block Count [0x50-0x5F] [2-byte]
.equ BBBC_OFF, 0x50
.equ IBBC_OFF, 0x52
.equ ITBC_OFF, 0x54

# LBA [0x60-0x6F] [4-byte]
.equ BB_LBA_OFF, 0x60
.equ IB_LBA_OFF, 0x64
.equ IT_LBA_OFF, 0x68
.equ NORM_LBA_OFF, 0x6C

# Immutable values
.equ S_MAG, 0xDEC0C0FA
.equ ROOT_INUM, 0x00000001

# DAP
.equ S_SECTOR_COUNT, 0x01
.equ S_SECT_CNT, 0x01
.equ S_OFF_MEM, 0x0600
.equ S_SEG_MEM, 0x00
.equ S_LBA, 0x00000001

# First
.equ FST_LBA, 0x40
