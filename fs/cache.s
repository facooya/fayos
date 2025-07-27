# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Cache for file system

.include "fayfs/inode.s"
.section .data
.global inode
.global tmp_inode

.global inum
.global tmp_inum
.global tmp_dir_inum
.global rmdir_inum
.global clear_inum

.global bbnum
.global ibnum

.global de_dots

inode: .zero I_SIZE
tmp_inode: .zero I_SIZE

inum: .long 0x00
tmp_inum: .long 0x00
tmp_dir_inum: .long 0x00
rmdir_inum: .long 0x00
clear_inum: .long 0x00

bbnum: .long 0x00
ibnum: .long 0x00

de_dots:
	.word 0x002E
	.word 0x4001
	.word 0x2E2E
	.word 0x4002
