# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# [Index Node] Initial inode packet

.include "fs/fs.s"
.include "fs/ind.s"
.section .text
.code16
.global ind_init

# ind_init()
ind_init:
	push %si

	mov $indp+INDP_OFF_PAR, %si
	push $(FS_ROOT_INUM&0xFFFF)
	push $(FS_ROOT_INUM>>0x10)
	push %si
	call ind_read
	add $0x06, %sp

	mov $indp+INDP_OFF_CUR, %si
	push $(FS_ROOT_INUM&0xFFFF)
	push $(FS_ROOT_INUM>>0x10)
	push %si
	call ind_read
	add $0x06, %sp

	mov $indp+INDP_OFF_TMP, %si
	push $(FS_ROOT_INUM&0xFFFF)
	push $(FS_ROOT_INUM>>0x10)
	push %si
	call ind_read
	add $0x06, %sp

	pop %si
	ret
