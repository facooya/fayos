# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# [Disk] Initial

.include "fs/ind.s"
.include "drv/disk.s"
.section .text
.code16
.global disk_init_dp

# disk_init_dp()
# <req> indp
disk_init_dp:
	push %si
	push %di

	mov $dp+DP_OFF_PAR, %di
	mov $DISK_BLK_SECT_CNT, %ax
	mov %ax, DP_OFF_SECT_CNT(%di)

	mov $(DISK_PAR_MEM>>0x10), %ax
	mov %ax, DP_OFF_MEM+0x02(%di)
	mov $(DISK_PAR_MEM&0xFFFF), %ax
	mov %ax, DP_OFF_MEM(%di)

	mov $indp+INDP_OFF_PAR, %si
	push IND_OFF_BLK_0(%si)
	push IND_OFF_BLK_0+0x02(%si)
	call fs_blk_to_lba
	add $0x04, %sp
	mov %dx, DP_OFF_LBA+0x02(%di)
	mov %ax, DP_OFF_LBA(%di)

	mov $dp+DP_OFF_CUR, %di
	mov $DISK_BLK_SECT_CNT, %ax
	mov %ax, DP_OFF_SECT_CNT(%di)

	mov $(DISK_CUR_MEM>>0x10), %ax
	mov %ax, DP_OFF_MEM+0x02(%di)
	mov $(DISK_CUR_MEM&0xFFFF), %ax
	mov %ax, DP_OFF_MEM(%di)

	mov $indp+INDP_OFF_CUR, %si
	push IND_OFF_BLK_0(%si)
	push IND_OFF_BLK_0+0x02(%si)
	call fs_blk_to_lba
	add $0x04, %sp
	mov %dx, DP_OFF_LBA+0x02(%di)
	mov %ax, DP_OFF_LBA(%di)

	mov $dp+DP_OFF_TMP, %di
	mov $DISK_BLK_SECT_CNT, %ax
	mov %ax, DP_OFF_SECT_CNT(%di)

	mov $(DISK_TMP_MEM>>0x10), %ax
	mov %ax, DP_OFF_MEM+0x02(%di)
	mov $(DISK_TMP_MEM&0xFFFF), %ax
	mov %ax, DP_OFF_MEM(%di)

	mov $indp+INDP_OFF_TMP, %si
	push IND_OFF_BLK_0(%si)
	push IND_OFF_BLK_0+0x02(%si)
	call fs_blk_to_lba
	add $0x04, %sp
	mov %dx, DP_OFF_LBA+0x02(%di)
	mov %ax, DP_OFF_LBA(%di)

	pop %di
	pop %si
	ret
