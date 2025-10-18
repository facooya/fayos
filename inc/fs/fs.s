# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# [File System] Constants

.equ FS_ROOT_INUM, 0x00000001
.equ FS_START_LBA, 0x40

.equ F_LIST_SIZE, 0x08
.equ F_LIST_OFF_FLG, 0x00
.equ F_LIST_OFF_MEM, 0x02
.equ F_LIST_OFF_IND_LIST_NUM, 0x06

.macro FS_INIT_INUM
	mov $(FS_ROOT_INUM&0xFFFF), %ax
	mov %ax, (root_inum)
	mov %ax, (inum)
	mov $(FS_ROOT_INUM>>0x10), %ax
	mov %ax, (root_inum+0x02)
	mov %ax, (inum+0x02)
.endm
