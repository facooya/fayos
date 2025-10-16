# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Update inode in inode table

.include "drv/disk.s"
.include "fs/inode.s"
.section .text
.code16
.global update_inode

# update_inode(
# *inum
# *inode
# )
update_inode:
	push %bp
	mov %sp, %bp
	push %es
	push %si
	push %bx

	push $DNUM_IT
	call disk_read_sect
	add $0x02, %sp
	mov %ax, %bx
	mov %dx, %es

	xor %dx, %dx
	mov 0x04(%bp), %si # *inum
	mov (%si), %ax # inum_lo
	mov $I_SIZE, %cx
	mul %cx # ax *= cx
	add %ax, %bx # set mem

	mov 0x06(%bp), %si # *inode
	mov I_FILE_SIZE_OFF(%si), %ax
	mov %ax, %es:I_FILE_SIZE_OFF(%bx)

	mov I_BLK_0_OFF(%si), %ax
	mov %ax, %es:I_BLK_0_OFF(%bx)
	mov I_BLK_0_OFF+0x02(%si), %ax
	mov %ax, %es:I_BLK_0_OFF+0x02(%bx)

	push $DNUM_IT
	call disk_write_sect
	add $0x02, %sp

	pop %bx
	pop %si
	pop %es
	pop %bp
	ret
