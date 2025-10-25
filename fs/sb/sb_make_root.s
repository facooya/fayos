# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# [Superblock] Make root directory

.include "fs/inode.s"
.include "fs/ind.s"
.section .data
.dent_dot: .asciz "."
.dent_dots: .asciz ".."
.section .text
.code16
.global sb_make_root

# sb_make_root()
sb_make_root:
	push %si

	call ind_add
	# <dx:ax = inum_hi:inum_lo>

	call ind_init
	call disk_init_dp
	call de_add_dots
	call ind_init

	pop %si
	ret
