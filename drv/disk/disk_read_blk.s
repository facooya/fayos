# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# [Disk] Read block

.include "drv/disk.s"
.include "fs/sb.s"
.section .text
.code16
.global disk_read_blk

# disk_read_blk(
# ub16 seg,
# ub16 off,
# ub16 blk_num
# )
# <ret> dx:ax = seg:off
disk_read_blk:
	push %bp
	mov %sp, %bp
	push %es
	push %si
	push %bx

	# TODO: blk_hi
	mov 0x08(%bp), %ax # blk_lo

	xor %dx, %dx
	mov $0x08, %cx
	mul %cx

	mov $(DISK_SB_MEM>>0x10), %cx
	mov %cx, %es
	mov $(DISK_SB_MEM&0xFFFF), %bx
	mov SB_OFF_NORM_LBA(%bx), %cx
	add %cx, %ax

	push $DISK_BLK_SECT_CNT # sect_cnt
	push %ax # lba_lo
	xor %ax, %ax
	push %ax # lba_hi
	mov 0x06(%bp), %ax
	push %ax # off
	mov 0x04(%bp), %ax
	push %ax # seg
	call ata_read_sect
	add $0x0A, %sp

	pop %bx
	pop %si
	pop %es
	pop %bp
	ret
