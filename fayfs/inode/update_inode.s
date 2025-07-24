# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Update inode in inode table

.include "fayfs/inode.s"
.section .text
.code16
.global update_inode

# update_inode(
# inum_hi, inum_lo,
# &inode
# )
update_inode:
	push %bp
	mov %sp, %bp
	push %si
	push %bx

	push $dap_it
	call read_disk
	add $0x02, %sp
	mov %ax, %bx
	mov %dx, %ds

	xor %dx, %dx
	mov 0x06(%bp), %ax # inum_lo
	mov $I_SIZE, %cx
	mul %cx # ax *= cx
	add %ax, %bx # set mem

	mov 0x08(%bp), %si # &inode
	mov I_FILE_SIZE_OFF(%si), %ax
	mov %ax, I_FILE_SIZE_OFF(%bx)

	mov I_BLK_0_OFF(%si), %ax
	mov %ax, I_BLK_0_OFF(%bx)
	mov I_BLK_0_OFF+0x02(%si), %ax
	mov %ax, I_BLK_0_OFF+0x02(%bx)

	push $dap_it
	call write_disk
	add $0x02, %sp
	xor %ax, %ax
	mov %ax, %ds

	pop %bx
	pop %si
	pop %bp
	ret
