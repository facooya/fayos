# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Fayos file system

.include "fayfs/sb.s"
.section .data
.global inode
.global tmp_inode

.global inum
.global tmp_inum

.global de_dots

.global next_i_num
.global next_i_blk

inode: .zero I_SIZE
tmp_inode: .zero I_SIZE

inum: .long 0x00
tmp_inum: .long 0x00

de_dots:
	.word 0x002E
	.word 0x4001
	.word 0x2E2E
	.word 0x4002

# TODO: remove
next_i_num: .long 0x00
next_i_blk: .long 0x00
