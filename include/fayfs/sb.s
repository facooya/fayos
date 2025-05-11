# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Superblock

# Magic number
.equ SB_MAG_LO_OFF, 0x00
.equ SB_MAG_HI_OFF, SB_MAG_LO_OFF+0x02
.equ SB_MAG_LO, 0xFAC0
.equ SB_MAG_HI, 0xC0DE

# Superblock LBA
.equ SB_LBA_LO_OFF, 0x04
.equ SB_LBA_HI_OFF, SB_LBA_LO_OFF+0x02
.equ SB_LBA_LO, 0x02
.equ SB_LBA_HI, 0x00

# Inode table LBA
.equ I_LBA_LO_OFF, 0x08
.equ I_LBA_HI_OFF, I_LBA_LO_OFF+0x02
.equ I_LBA_LO, 0x10
.equ I_LBA_HI, 0x00

# Root inode number
.equ ROOT_I_NUM_LO_OFF, 0x0C
.equ ROOT_I_NUM_HI_OFF, ROOT_I_NUM_LO_OFF+0x02
.equ ROOT_I_NUM_LO, 0x02
.equ ROOT_I_NUM_HI, 0x00

# First alloc LBA
.equ FST_LBA_LO_OFF, 0x10
.equ FST_LBA_HI_OFF, FST_LBA_LO_OFF+0x02
.equ FST_LBA_LO, 0x80
.equ FST_LBA_HI, 0x00

# First inode number
.equ FST_I_NUM_LO_OFF, 0x14
.equ FST_I_NUM_HI_OFF, FST_I_NUM_LO_OFF+0x02
.equ FST_I_NUM_LO, 0x11
.equ FST_I_NUM_HI, 0x00

# First inode block
.equ FST_I_BLK_LO_OFF, 0x18
.equ FST_I_BLK_HI_OFF, FST_I_BLK_LO_OFF+0x02
.equ FST_I_BLK_LO, 0x01
.equ FST_I_BLK_HI, 0x00

# Inode size
.equ I_SIZE_OFF, 0x1C
.equ I_SIZE, 0x20

# Next inode number
.equ NEXT_I_NUM_LO_OFF, 0x40
.equ NEXT_I_NUM_HI_OFF, NEXT_I_NUM_LO_OFF+0x02
.equ NEXT_I_NUM_LO, 0x11
.equ NEXT_I_NUM_HI, 0x00

# Next block number
.equ NEXT_I_BLK_LO_OFF, 0x44
.equ NEXT_I_BLK_HI_OFF, NEXT_I_BLK_LO_OFF+0x02
.equ NEXT_I_BLK_LO, 0x01
.equ NEXT_I_BLK_HI, 0x00
