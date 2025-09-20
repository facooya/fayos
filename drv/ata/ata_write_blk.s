# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Write block

.section .text
.code16
.global ata_write_blk

# ata_write_blk(seg, off, blknum)
ata_write_blk:
	push %bp
	mov %sp, %bp

	# TODO: allocate memory seg:off - es:di
	# TODO: blknum to LBA
	# mov 0x08(%bp), %ax

	push $0x08 # sect_cnt
	push $0xA0 # lba_lo
	push $0x00 # lba_hi
	mov 0x06(%bp), %ax
	xor %ax, %ax
	push %ax # off
	mov 0x04(%bp), %ax
	mov $0x2000, %ax
	push %ax # seg
	call ata_write_sect
	add $0x0A, %sp

.done:
	pop %bp
	ret
