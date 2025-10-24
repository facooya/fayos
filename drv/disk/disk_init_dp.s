# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# [Disk] Initial

.include "drv/disk.s"
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
	add $DP_OFF_PAR, %di

	mov $DISK_BLK_SECT_CNT, %ax
	mov %ax, DP_OFF_SECT_CNT(%di)

	mov $(DISK_PAR_MEM>>0x10), %ax
	mov %ax, DP_OFF_MEM+0x02(%di)
	mov $(DISK_PAR_MEM&0xFFFF), %ax
	mov %ax, DP_OFF_MEM(%di)

	mov %bx, %di
	add $DP_OFF_CUR, %di

	mov $DISK_BLK_SECT_CNT, %ax
	mov %ax, DP_OFF_SECT_CNT(%di)

	mov $(DISK_CUR_MEM>>0x10), %ax
	mov %ax, DP_OFF_MEM+0x02(%di)
	mov $(DISK_CUR_MEM&0xFFFF), %ax
	mov %ax, DP_OFF_MEM(%di)

	mov %bx, %di
	add $DP_OFF_TMP, %di

	mov $DISK_BLK_SECT_CNT, %ax
	mov %ax, DP_OFF_SECT_CNT(%di)

	mov $(DISK_TMP_MEM>>0x10), %ax
	mov %ax, DP_OFF_MEM+0x02(%di)
	mov $(DISK_TMP_MEM&0xFFFF), %ax
	mov %ax, DP_OFF_MEM(%di)

	pop %bx
	pop %di
	pop %si
	ret
