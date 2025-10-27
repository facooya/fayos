# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# [Superblock] Make root directory

.include "fs/fs.s"
.include "fs/ind.s"
.section .text
.code16
.global sb_make_root

# sb_make_root()
sb_make_root:
	call ind_add
	# <dx:ax = inum_hi:inum_lo>

	call fsp_init # test
	call ind_init
	call disk_init_dp

	push $indp+INDP_OFF_CUR
	call de_add_dots
	add $0x02, %sp

	call ind_init
	ret
