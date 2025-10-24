# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# [Disk] Initial

.include "drv/disk.s"
.include "fs/ind.s"
.section .text
.code16
.global disk_init_dp

# disk_init_dp()
disk_init_dp:
	push %si
	push %di
	push %bx

	mov $dp, %bx
	mov %bx, %di
	add $DP_OFF_CUR, %di

	mov $DISK_BLK_SECT_CNT, %ax
	mov %ax, DP_OFF_SECT_CNT(%di)

	mov $(DISK_CUR_MEM>>0x10), %ax
	mov %ax, DP_OFF_MEM+0x02(%di)
	mov $(DISK_CUR_MEM&0xFFFF), %ax
	mov %ax, DP_OFF_MEM(%di)

	push (root_inum)
	push (root_inum+0x02)
	mov $indp+INDP_OFF_CUR, %si
	push %si
	call ind_read4
	add $0x06, %sp

	mov IND_OFF_BLK_0(%si), %ax
	push %ax
	xor %ax, %ax
	push %ax
	call fs_blk_to_lba
	add $0x04, %sp
	push %ax
	call dbg_reg
	add $0x02, %sp
	# <dx:ax = lba_hi:lba_lo>
	mov %dx, DP_OFF_LBA+0x02(%di)
	mov %ax, DP_OFF_LBA(%di)

	pop %bx
	pop %di
	pop %si
	ret
