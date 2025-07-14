# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Superblock

# Immutable [0x00-0x1F]
# Magic number
.equ SB_MAG_LO_OFF, 0x00
.equ SB_MAG_HI_OFF, SB_MAG_LO_OFF+0x02
.equ SB_MAG_LO, 0xFAC0
.equ SB_MAG_HI, 0xC0DE

# Superblock LBA
.equ SB_LBA_OFF, 0x04
.equ SB_LBA, 0x01

# First LBA
.equ FST_LBA_OFF, 0x06
.equ FST_LBA, 0x40

# First block
.equ FST_BLK_OFF, 0x08
.equ FST_BLK, 0x01

# First inum
.equ FST_INUM_OFF, 0x0A
.equ FST_INUM, 0x01

# Inode size
.equ I_SIZE_OFF, 0x0C
.equ I_SIZE, 0x20

# Read disk parameters [0x20-0x3E]
.equ DP_BUF_OFF, 0x20
.equ DP_LBA_SIZE_LO_OFF, 0x30
.equ DP_LBA_SIZE_HI_OFF, DP_LBA_SIZE_LO_OFF+0x02

# Mutable LBA by disk size [0x40-0x6F]
# BB: Block Bitmap
# IB: Inum Bitmap
# IT: Inode Table
# *S: Size
# *BC: Block Count

# size [0x40-0x4F]
.equ BBS_LO_OFF, 0x40
.equ BBS_HI_OFF, BBS_LO_OFF+0x02

.equ IBS_LO_OFF, 0x44
.equ IBS_HI_OFF, IBS_LO_OFF+0x02

.equ ITS_LO_OFF, 0x48
.equ ITS_HI_OFF, ITS_LO_OFF+0x02

# block count [0x50-0x5F]
.equ BBBC_OFF, 0x50
.equ IBBC_OFF, 0x52
.equ ITBC_OFF, 0x54

# LBA [0x60-0x6F]
.equ BB_LBA_LO_OFF, 0x60
.equ BB_LBA_HI_OFF, BB_LBA_LO_OFF+0x02

.equ IB_LBA_LO_OFF, 0x64
.equ IB_LBA_HI_OFF, IB_LBA_LO_OFF+0x02

.equ IT_LBA_LO_OFF, 0x68
.equ IT_LBA_HI_OFF, IT_LBA_LO_OFF+0x02

.equ NORM_LBA_LO_OFF, 0x6C
.equ NORM_LBA_HI_OFF, NORM_LBA_LO_OFF+0x02

# TODO!!!: remove
# Next inode number
.equ NEXT_I_NUM_LO_OFF, 0x70
.equ NEXT_I_NUM_HI_OFF, NEXT_I_NUM_LO_OFF+0x02
.equ NEXT_I_NUM_LO, 0x02
.equ NEXT_I_NUM_HI, 0x00

# Next block number
.equ NEXT_I_BLK_LO_OFF, 0x74
.equ NEXT_I_BLK_HI_OFF, NEXT_I_BLK_LO_OFF+0x02
.equ NEXT_I_BLK_LO, 0x02
.equ NEXT_I_BLK_HI, 0x00
