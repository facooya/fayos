# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# [File System] Data

.include "fs/ind.s"
.section .data
.global inode
.global tmp_inode

.global inum
.global root_inum
.global tmp_inum
.global tmp_dir_inum
.global rmdir_inum
.global clear_inum
.global path_inum
.global parent_path_inum

.global bbnum
.global ibnum

.global mnt
.global fd
.global ft

.global de_dots
.global de_hist

.global ind_list

.global ind_cache
# seg, off, inum, ind

inode: .zero IND_SIZE
tmp_inode: .zero IND_SIZE

inum: .long 0x00
root_inum: .long 0x00

tmp_inum: .long 0x00
tmp_dir_inum: .long 0x00
rmdir_inum: .long 0x00
clear_inum: .long 0x00
path_inum: .long 0x00
parent_path_inum: .long 0x00

bbnum: .long 0x00
ibnum: .long 0x00

mnt: .word 0x00
fd: .word 0x00
ft: .zero 0x100
# flg, seg, off, ind_ptr (seg, off)

de_dots:
	.word 0x002E
	.word 0x4001
	.word 0x2E2E
	.word 0x4002

de_hist:
	.word 0x8008
	.asciz ".history"

ind_list: .zero 0x100

ind_cache: .zero 0x100
