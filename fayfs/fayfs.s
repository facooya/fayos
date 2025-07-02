# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Fayos file system

.section .data

.global dentry_ptr
.global i_file_size

.global i_num
.global i_blk

.global next_i_num
.global next_i_blk

dentry_ptr: .word 0x00
i_file_size: .word 0x00

i_num: .long 0x00 # 0x02: root inode
i_blk: .long 0x00 # 0x01: root dir blk

next_i_num: .long 0x00
next_i_blk: .long 0x00
