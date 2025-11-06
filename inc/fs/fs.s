# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# [File System] Constants

.equ FS_ROOT_INUM, 0x00000001
.equ FS_START_LBA, 0x40

.equ FT_SIZE, 0x0A
.equ FT_OFF_FLG, 0x00
.equ FT_OFF_MEM, 0x02
.equ FT_IND_PTR, 0x06

.equ F_TYPE_RM, 0xFF
.equ F_TYPE_DIR, 0x40
.equ F_TYPE_FILE, 0x80

# { File System Packet
.equ FSP_SIZE, 0x32
.equ FSP_OFF_DISK, 0x28

# Inode
.equ FSP_OFF_F_SIZE, 0x00
.equ FSP_OFF_F_TYPE, 0x02
.equ FSP_OFF_BLK_SIZE, 0x03
.equ FSP_OFF_BLK_0, 0x04
.equ FSP_OFF_BLK_1, FSP_OFF_BLK_0+0x04
.equ FSP_OFF_BLK_2, FSP_OFF_BLK_1+0x04
.equ FSP_OFF_BLK_3, FSP_OFF_BLK_2+0x04
.equ FSP_OFF_BLK_4, FSP_OFF_BLK_3+0x04
.equ FSP_OFF_BLK_5, FSP_OFF_BLK_4+0x04
.equ FSP_OFF_BLK_6, FSP_OFF_BLK_5+0x04

# Info
.equ FSP_OFF_IND_PTR, 0x20
.equ FSP_OFF_INUM, 0x24

# Disk
.equ FSP_OFF_DISK_SECT_CNT, 0x28
.equ FSP_OFF_DISK_MEM, 0x2A
.equ FSP_OFF_DISK_LBA, 0x2E

# Access
.equ FSP_OFF_CUR, 0x00
.equ FSP_OFF_PAR, FSP_SIZE
.equ FSP_OFF_TMP, FSP_SIZE*0x02
.equ FSP_OFF_DIR, FSP_SIZE*0x03
.equ FSP_OFF_BASE, FSP_SIZE*0x04
.equ FSP_OFF_ROOT, FSP_SIZE*0x05
.equ FSP_OFF_HIST, FSP_SIZE*0x06
# }

.macro FS_INIT_INUM
	mov $(FS_ROOT_INUM&0xFFFF), %ax
	mov %ax, (root_inum)
	mov %ax, (inum)
	mov $(FS_ROOT_INUM>>0x10), %ax
	mov %ax, (root_inum+0x02)
	mov %ax, (inum+0x02)
.endm
