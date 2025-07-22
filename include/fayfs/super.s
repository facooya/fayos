# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Superblock constants

# Header [0x00-0x1F]
.equ S_MAG_LO_OFF, 0x00
.equ S_MAG_HI_OFF, S_MAG_LO_OFF+0x02

# Disk Parameter [0x20-0x3F]
.equ DP_BUF_OFF, 0x20
.equ DP_LBA_SIZE_LO_OFF, 0x30
.equ DP_LBA_SIZE_HI_OFF, DP_LBA_SIZE_LO_OFF+0x02

# LBA info by DP [0x40-0x6F]
# BB: Block Bitmap
# IB: Inum Bitmap
# IT: Inode Table
# *S: Size
# *BC: Block Count

# Size [0x40-0x4F]
.equ BBS_LO_OFF, 0x40
.equ BBS_HI_OFF, BBS_LO_OFF+0x02
.equ IBS_LO_OFF, 0x44
.equ IBS_HI_OFF, IBS_LO_OFF+0x02
.equ ITS_LO_OFF, 0x48
.equ ITS_HI_OFF, ITS_LO_OFF+0x02

# Block Count [0x50-0x5F]
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

# Immutable values
.equ S_MAG_LO, 0xC0FA
.equ S_MAG_HI, 0xDEC0

# DAP
.equ S_SECTOR_COUNT, 0x01
.equ S_OFF_MEM, 0x0600
.equ S_SEG_MEM, 0x00
.equ S_LBA_LO, 0x01
.equ S_LBA_HI, 0x00

# First
.equ FST_LBA, 0x40
