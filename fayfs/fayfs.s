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

.global blk_bitmap
.global inode_bitmap

.global next_i_num
.global next_i_blk

inode: .zero I_SIZE
tmp_inode: .zero I_SIZE

inum: .long 0x00
tmp_inum: .long 0x00

blk_bitmap: .zero 0x20
inode_bitmap: .zero 0x04

next_i_num: .long 0x00
next_i_blk: .long 0x00
