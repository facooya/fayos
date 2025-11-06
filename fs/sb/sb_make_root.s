# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# [Superblock] Make root directory

.include "fs/fs.s"
.section .text
.code16
.global sb_make_root

# sb_make_root()
sb_make_root:
	push $F_TYPE_DIR # (f_type)
	call ind_add
	add $0x02, %sp
	# <dx:ax = inum_hi:inum_lo>

	call fsp_init

	push $fsp+FSP_OFF_CUR # (fsp &src)
	push $fsp+FSP_OFF_TMP # (fsp &dst)
	call de_add_dots
	add $0x04, %sp

	call fsp_init
	ret
