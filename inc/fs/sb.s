# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# [Superblock] Constants

# Header [0x00-0x1F]
.equ SB_OFF_MAG, 0x00 # [4-byte]
.equ SB_MAG, 0xDEC0C0FA

# Disk info [0x20-0x3F]
.equ SB_OFF_TOT_SECT, 0x20 # [4-byte]

# LBA info [0x40-0x6F]
# Size [0x40-0x4F] [2-byte]
.equ SB_OFF_BBM_SIZE, 0x40
.equ SB_OFF_IBM_SIZE, 0x42
.equ SB_OFF_IT_SIZE, 0x44 # [4-byte]

# Block Count [0x50-0x5F] [2-byte]
.equ SB_OFF_BBM_BC, 0x50
.equ SB_OFF_IBM_BC, 0x52
.equ SB_OFF_IT_BC, 0x54

# LBA [0x60-0x6F] [2-byte]
.equ SB_OFF_BBM_LBA, 0x60
.equ SB_OFF_IBM_LBA, 0x62
.equ SB_OFF_IT_LBA, 0x64
.equ SB_OFF_NORM_LBA, 0x66

# calculate [0x70-0x7F] [2-byte]
.equ SB_TOT_BLK_CNT, 0x70
.equ SB_TOT_INUM_CNT, 0x72

# Disk immutable cache [0x80-0xAF] [8-byte]
.equ SB_DPI_SIZE, 0x08
.equ SB_OFF_DPI_SB, 0x80
.equ SB_OFF_DPI_BBM, SB_OFF_DPI_SB+SB_DPI_SIZE
.equ SB_OFF_DPI_IBM, SB_OFF_DPI_BBM+SB_DPI_SIZE
.equ SB_OFF_DPI_IT, SB_OFF_DPI_IBM+SB_DPI_SIZE

# rate
.equ RATIO_BIT_BYTE, 0x08
.equ RATIO_SC_BLK, 0x08
.equ RATIO_BC_INUM, 0x01
