# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Read inode in inode table

.include "fayfs/sb.s"
.include "fayfs/i.s"
.section .text
.code16
.global read_inode

# read_inode(i_num_hi, i_num_lo)
# <ret> i_blk, i_file_size
read_inode:
	push %bp
	mov %sp, %bp
	push %bx

	# read inode
	push $I_LBA_LO
	push $I_LBA_HI
	call set_dap_lba
	add $0x04, %sp

	call read_block
	mov $0x8000, %bx

	# calc i_num
	xor %dx, %dx
	mov 0x06(%bp), %cx
	mov $I_SIZE, %ax
	mul %cx
	# ax *= cx

	# set mem
	add %ax, %bx

	# set i_file_size
	mov I_FILE_SIZE_OFF(%bx), %ax
	mov %ax, (i_file_size)

	# set i_blk
	mov I_BLK_LO_OFF(%bx), %ax
	mov %ax, (i_blk)
	mov I_BLK_HI_OFF(%bx), %dx
	mov %dx, (i_blk+0x02)

	pop %bx
	pop %bp
	ret
