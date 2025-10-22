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
# Size [0x40-0x4F] [4-byte]
.equ SB_OFF_BBM_SIZE, 0x40
.equ SB_OFF_IBM_SIZE, 0x44
.equ SB_OFF_IT_SIZE, 0x48

# Block Count [0x50-0x5F] [2-byte]
.equ SB_OFF_BBM_BC, 0x50
.equ SB_OFF_IBM_BC, 0x52
.equ SB_OFF_IT_BC, 0x54

# LBA [0x60-0x6F] [4-byte]
.equ SB_OFF_BBM_LBA, 0x60
.equ SB_OFF_IBM_LBA, 0x64
.equ SB_OFF_IT_LBA, 0x68
.equ SB_OFF_NORM_LBA, 0x6C

# Disk immutable cache [0x70-0xBF] [10-byte]
.equ SB_OFF_DI_SB, 0x70
.equ SB_OFF_DI_BBM, 0x80
.equ SB_OFF_DI_IBM, 0x90
.equ SB_OFF_DI_IT, 0xA0

.equ SB_OFF_DI_SECT_CNT, 0x00 # [2-byte]
.equ SB_OFF_DI_MEM, 0x02 # [4-byte]
.equ SB_OFF_DI_LBA, 0x06 # [4-byte]
