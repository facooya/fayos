# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# [Index Node] Initial inode packet

.include "fs/ind.s"
.section .text
.code16
.global ind_init

# ind_init()
ind_init:
	mov $indp+INDP_OFF_PAR, %si
	push (root_inum)
	push (root_inum+0x02)
	push %si
	call ind_read4
	add $0x06, %sp

	mov $indp+INDP_OFF_CUR, %si
	push (root_inum)
	push (root_inum+0x02)
	push %si
	call ind_read4
	add $0x06, %sp
	ret
