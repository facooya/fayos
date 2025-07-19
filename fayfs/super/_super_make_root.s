# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Make root

.include "fayfs/inode.s"
.section .text
.code16
.global _super_make_root

# _super_make_root()
_super_make_root:
	call add_inode

	# add dentry dot
	mov $de_dots, %si
	mov 0x02(%si), %cx
	push %si
	push %cx
	mov (inum), %ax
	push %ax
	mov (inum+0x02), %ax
	push %ax
	mov (inum), %ax
	push %ax
	mov (inum+0x02), %ax
	push %ax
	call add_dentry
	add $0x0C, %sp
	push %ax

	# add dentry dotdot
	mov $de_dots, %si
	add $0x04, %si
	mov 0x02(%si), %cx
	push %si
	push %cx
	mov (inum), %ax
	push %ax
	mov (inum+0x02), %ax
	xor %ax, %ax
	push %ax
	mov (inum), %ax
	push %ax
	mov (inum+0x02), %ax
	xor %ax, %ax
	push %ax
	call add_dentry
	add $0x0C, %sp
	push %ax

	mov $inode, %si
	push %si
	mov (inum), %ax
	push %ax
	mov (inum+0x02), %ax
	push %ax
	call read_inode
	add $0x06, %sp

	pop %cx
	pop %ax
	add %cx, %ax
	mov %ax, I_FILE_SIZE_OFF(%si)
	push %si
	mov (inum), %ax
	push %ax
	mov (inum+0x02), %ax
	push %ax
	call update_inode
	add $0x06, %sp
	ret
