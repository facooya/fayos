# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# [File System] Initial file-system-packet

.include "drv/disk.s"
.include "fs/fs.s"
.section .text
.code16
.global fsp_init

# fsp_init()
fsp_init:
	push %di

	mov $fsp+FSP_OFF_CUR, %di
	push $(FS_ROOT_INUM&0xFFFF)
	push $(FS_ROOT_INUM>>0x10)
	push %di
	call ind_read
	add $0x06, %sp

	mov $DISK_BLK_SECT_CNT, FSP_OFF_DISK_SECT_CNT(%di)
	mov $DISK_CUR_MEM+0x02, FSP_OFF_DISK_MEM+0x02(%di)
	mov $DISK_CUR_MEM, FSP_OFF_DISK_MEM(%di)

	push FSP_OFF_IND_BLK_0(%di)
	push FSP_OFF_IND_BLK_0+0x02(%di)
	call fs_blk_to_lba
	add $0x04, %sp
	mov %dx, FSP_OFF_DISK_LBA+0x02(%di)
	mov %ax, FSP_OFF_DISK_LBA(%di)

	xor %ax, %ax
	push $FSP_SIZE
	push %di
	push %ax
	push $fsp+FSP_OFF_PAR
	push %ax
	call mem_cpy
	add $0x0A, %sp
	mov $DISK_PAR_MEM+0x02, FSP_OFF_DISK_MEM+0x02(%di)
	mov $DISK_PAR_MEM, FSP_OFF_DISK_MEM(%di)
	add $FSP_SIZE, %di

	xor %ax, %ax
	push $FSP_SIZE
	push %di
	push %ax
	push $fsp+FSP_OFF_TMP
	push %ax
	call mem_cpy
	add $0x0A, %sp
	mov $DISK_TMP_MEM+0x02, FSP_OFF_DISK_MEM+0x02(%di)
	mov $DISK_TMP_MEM, FSP_OFF_DISK_MEM(%di)
	add $FSP_SIZE, %di

	xor %ax, %ax
	push $FSP_SIZE
	push %di
	push %ax
	push $fsp+FSP_OFF_PATH
	push %ax
	call mem_cpy
	add $0x0A, %sp
	mov $DISK_PATH_MEM+0x02, FSP_OFF_DISK_MEM+0x02(%di)
	mov $DISK_PATH_MEM, FSP_OFF_DISK_MEM(%di)
	add $FSP_SIZE, %di

	xor %ax, %ax
	push $FSP_SIZE
	push %di
	push %ax
	push $fsp+FSP_OFF_ROOT
	push %ax
	call mem_cpy
	add $0x0A, %sp
	mov $DISK_ROOT_MEM+0x02, FSP_OFF_DISK_MEM+0x02(%di)
	mov $DISK_ROOT_MEM, FSP_OFF_DISK_MEM(%di)
	add $FSP_SIZE, %di

	pop %di
	ret
