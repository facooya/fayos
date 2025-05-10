# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Fayos file system

.section .data

.global dentry_ptr

.global f_i_num
.global f_blk_num

.global i_num
.global i_blk

.global next_i_num
.global next_i_blk

dentry_ptr: .word 0x00

f_i_num: .long 0x02
f_blk_num: .long 0x01

i_num: .long 0x00 # 0x02: root inode
i_blk: .long 0x00 # 0x01: root dir blk

next_i_num: .long 0x00
next_i_blk: .long 0x00
