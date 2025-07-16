# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Directory entry

.include "fayfs/super.s"
.include "fayfs/i.s"
.section .text
.code16
.global set_blk_lba

# set_blk_lba() # FIXME: blk overflow
set_blk_lba:
	push %si

	# init
	mov $inode, %si
	mov I_BLK_0_LO_OFF(%si), %ax
	
	mov $0x08, %cx
	xor %dx, %dx
	mul %cx

	push %bx
	mov $0x600, %bx
	mov NORM_LBA_LO_OFF(%bx), %cx
	add %cx, %ax
	pop %bx

	# set dap lba # HACK!!!: low high
	push %ax # low
	xor %ax, %ax
	push %ax # high
	call set_dap_lba
	add $0x04, %sp

	pop %si
	ret
