# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# [File System Packet] Block number to logical block address

.include "drv/disk.s"
.include "fs/sb.s"
.section .text
.code16
.global fsp_blk_to_lba

# fsp_blk_to_lba(ub16 blk_num)
# <ret> ax = lba
fsp_blk_to_lba:
	push %bp
	mov %sp, %bp
	push %es
	push %bx
	
	mov 0x04(%bp), %ax # (blk_num)
	xor %dx, %dx
	mov $DISK_BLK_SECT_CNT, %cx
	mul %cx

	# get norm lba
	mov $(DISK_SB_MEM>>0x10), %cx
	mov %cx, %es
	mov $(DISK_SB_MEM&0xFFFF), %bx
	mov %es:SB_OFF_NORM_LBA(%bx), %cx
	add %cx, %ax # <ret:lba>

	pop %bx
	pop %es
	pop %bp
	ret
