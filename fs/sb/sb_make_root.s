# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# [Superblock] Make root directory

.include "fs/inode.s"
.section .text
.code16
.global sb_make_root

# sb_make_root()
sb_make_root:
	push %si

	call add_inode

	# add dentry dot
	mov $de_dots, %si
	mov 0x02(%si), %cx
	push %si
	push %cx
	push $inum
	push $inum
	call add_dentry
	add $0x08, %sp
	push %ax

	push $inode
	push $inum
	call read_inode
	add $0x04, %sp

	pop %ax
	mov $inode, %si
	mov %ax, I_FILE_SIZE_OFF(%si)

	push $inode
	push $inum
	call update_inode
	add $0x04, %sp

	# add dentry dotdot
	mov $de_dots, %si
	add $0x04, %si
	mov 0x02(%si), %cx
	push %si
	push %cx
	push $inum
	push $inum
	call add_dentry
	add $0x08, %sp
	push %ax

	push $inode
	push $inum
	call read_inode
	add $0x04, %sp

	pop %cx
	mov $inode, %si
	mov I_FILE_SIZE_OFF(%si), %ax
	add %cx, %ax
	mov %ax, I_FILE_SIZE_OFF(%si)

	push $inode
	push $inum
	call update_inode
	add $0x04, %sp

	pop %si
	ret
