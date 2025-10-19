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
