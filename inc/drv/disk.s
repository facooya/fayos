# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# [Disk] Constants

.equ DLBA_OFF_BBM, 0x00
.equ DLBA_OFF_IBM, 0x04
.equ DLBA_OFF_IT, 0x08

.equ DISK_SB_SECT_CNT, 0x01
.equ DISK_SB_LBA, 0x00000001
.equ DISK_BLK_SECT_CNT, 0x08

.equ DISK_SB_MEM, 0x00000600
.equ DISK_BBM_MEM, 0x0000A000
.equ DISK_IBM_MEM, 0x0000B000
.equ DISK_IT_MEM, 0x0000C000
.equ DISK_ROOT_MEM, 0x0000D000

# Disk packet immutable
.equ DPI_SIZE, 0x0A
.equ DPI_OFF_SB, 0x00
.equ DPI_OFF_BBM, DPI_OFF_SB+DPI_SIZE
.equ DPI_OFF_IBM, DPI_OFF_BBM+DPI_SIZE
.equ DPI_OFF_IT, DPI_OFF_IBM+DPI_SIZE

.equ DP_OFF_SECT_CNT, 0x00 # [2-byte]
.equ DP_OFF_MEM, 0x02 # [4-byte]
.equ DP_OFF_LBA, 0x06 # [4-byte]
