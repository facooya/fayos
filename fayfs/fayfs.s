# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Fayos file system

.include "fayfs/sb.s"
.section .data
.global inode
.global tmp_inode

.global i_num

.global next_i_num
.global next_i_blk

inode: .zero I_SIZE
tmp_inode: .zero I_SIZE

i_num: .long 0x00

next_i_num: .long 0x00
next_i_blk: .long 0x00
