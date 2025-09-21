# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Read block

.include "fayfs/super.s"
.section .text
.code16
.global ata_read_blk

# ata_read_blk(seg, off, *blknum)
ata_read_blk:
	push %bp
	mov %sp, %bp
	push %si
	push %bx

	# TODO: allocate memory seg:off - es:di

	mov 0x08(%bp), %si

	# TODO: blknum hi lo calc
	mov 0x02(%si), %ax
	mov (%si), %ax
	xor %dx, %dx
	mov $0x08, %cx
	mul %cx

	# [lba_lo + NORM_LBA]
	mov $S_OFF_MEM, %bx
	mov NORM_LBA_OFF(%bx), %cx
	clc
	add %cx, %ax
	jnc .ncf
	add $0x01, %dx

.ncf:
	push $0x08 # sect_cnt
	push %ax # lba_lo
	push %dx # lba_hi
	mov 0x06(%bp), %ax
	push %ax # off
	mov 0x04(%bp), %ax
	push %ax # seg
	call ata_read_sect
	add $0x0A, %sp

.done:
	pop %bx
	pop %si
	pop %bp
	ret
