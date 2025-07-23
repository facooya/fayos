# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Read inode in inode table

.include "fayfs/inode.s"
.section .text
.code16
.global read_inode

# read_inode(
# inum_hi, inum_lo
# &inode
# )
read_inode:
	push %bp
	mov %sp, %bp
	push %si
	push %bx

	push $dap_it
	call read_disk
	add $0x02, %sp
	mov %ax, %bx
	#mov %dx, %ds

	# calc inum
	xor %dx, %dx
	mov 0x06(%bp), %cx # inum_lo
	mov $I_SIZE, %ax
	mul %cx
	add %ax, %bx

	mov 0x08(%bp), %si

	# set i_file_size
	mov I_FILE_SIZE_OFF(%bx), %ax
	mov %ax, I_FILE_SIZE_OFF(%si)

	# set i_blk
	mov I_BLK_0_LO_OFF(%bx), %ax
	mov %ax, I_BLK_0_LO_OFF(%si)
	mov I_BLK_0_HI_OFF(%bx), %ax
	mov %ax, I_BLK_0_HI_OFF(%si)

	pop %bx
	pop %si
	pop %bp
	ret
