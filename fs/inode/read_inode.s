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
	push %es
	push %si
	push %bx

	mov $dap_it, %bx
	push $0x08 # sect_cnt
	mov 0x08(%bx), %ax
	push %ax # lba_lo
	mov 0x0A(%bx), %ax
	push %ax # lba_hi
	mov 0x04(%bx), %ax
	push %ax # off
	mov 0x06(%bx), %ax
	push %ax # seg
	call ata_read_sect
	add $0x0A, %sp
	mov %ax, %bx
	mov %dx, %es

	# calc inum
	xor %dx, %dx
	mov 0x04(%bp), %si # *inum
	mov (%si), %ax # inum_lo
	mov $I_SIZE, %cx
	mul %cx
	add %ax, %bx

	mov 0x06(%bp), %si # *inode

	# set i_file_size
	mov %es:I_FILE_SIZE_OFF(%bx), %ax
	mov %ax, I_FILE_SIZE_OFF(%si)

	# set i_blk
	mov %es:I_BLK_0_OFF(%bx), %ax
	mov %ax, I_BLK_0_OFF(%si)
	mov %es:I_BLK_0_OFF+0x02(%bx), %ax
	mov %ax, I_BLK_0_OFF+0x02(%si)

	pop %bx
	pop %si
	pop %es
	pop %bp
	ret
