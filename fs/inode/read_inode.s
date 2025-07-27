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
# *inum
# *inode
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
	mov %dx, %ds

	# calc inum
	xor %dx, %dx
	mov 0x04(%bp), %si # *inum
	mov (%si), %ax # inum_lo
	mov $I_SIZE, %cx
	mul %cx
	add %ax, %bx

	mov 0x06(%bp), %si # *inode

	# set i_file_size
	mov I_FILE_SIZE_OFF(%bx), %ax
	mov %ax, I_FILE_SIZE_OFF(%si)

	# set i_blk
	mov I_BLK_0_OFF(%bx), %ax
	mov %ax, I_BLK_0_OFF(%si)
	mov I_BLK_0_OFF+0x02(%bx), %ax
	mov %ax, I_BLK_0_OFF+0x02(%si)

	pop %bx
	pop %si
	pop %bp
	ret
