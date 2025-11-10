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

# fsp_blk_to_lba(ub16 blk_num_hi, ub16 blk_num_lo)
# <ret> dx:ax = lba_hi:lba_lo
fsp_blk_to_lba:
	push %bp
	mov %sp, %bp
	push %es
	push %bx

	mov 0x04(%bp), %ax # blk_num_hi
	xor %dx, %dx
	mov $DISK_BLK_SECT_CNT, %cx
	mul %cx
	push %ax # [s.c0:tmp_lba_hi]

	mov 0x06(%bp), %ax # blk_num_lo
	xor %dx, %dx
	mul %cx # ax=tmp_lba_lo

	pop %cx # [s.c0:tmp_lba_hi]
	add %cx, %dx # <ret.1:lba_hi>

	# get norm lba
	mov $(DISK_SB_MEM>>0x10), %cx
	mov %cx, %es
	mov $(DISK_SB_MEM&0xFFFF), %bx
	mov %es:SB_OFF_NORM_LBA(%bx), %cx

	# add norm
	clc
	add %cx, %ax # <ret:lba_lo>
	jc .carry
	jmp .done

.carry:
	inc %dx # <ret.2:lba_hi>

.done:
	pop %bx
	pop %es
	pop %bp
	ret
