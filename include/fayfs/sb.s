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
.equ FST_LBA, 0x80

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
.equ DP_SIZE_OFF, 0x20
.equ DP_LBA_LO_SIZE_OFF, 0x30
.equ DP_LBA_HI_SIZE_OFF, DP_LBA_LO_SIZE_OFF+0x02

# Mutable LBA by disk size [0x40-0x4B]
.equ BLK_BITMAP_LBA_LO_OFF, 0x40
.equ BLK_BITMAP_LBA_HI_OFF, BLK_BITMAP_LBA_LO_OFF+0x02

.equ INUM_BITMAP_LBA_LO_OFF, 0x44
.equ INUM_BITMAP_LBA_HI_OFF, INUM_BITMAP_LBA_LO_OFF+0x02

.equ I_LBA_LO_OFF, 0x48
.equ I_LBA_HI_OFF, I_LBA_LO_OFF+0x02

# TODO!!!: remove
# Next inode number
.equ NEXT_I_NUM_LO_OFF, 0x40
.equ NEXT_I_NUM_HI_OFF, NEXT_I_NUM_LO_OFF+0x02
.equ NEXT_I_NUM_LO, 0x02
.equ NEXT_I_NUM_HI, 0x00

# Next block number
.equ NEXT_I_BLK_LO_OFF, 0x44
.equ NEXT_I_BLK_HI_OFF, NEXT_I_BLK_LO_OFF+0x02
.equ NEXT_I_BLK_LO, 0x02
.equ NEXT_I_BLK_HI, 0x00
