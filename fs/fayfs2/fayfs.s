# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Fayos file system

.section .data

.global free_dentry

.global f_i_num
.global f_blk_num

.global cwd_i
.global i_blk

free_dentry: .word 0x00

f_i_num: .long 0x02
f_blk_num: .long 0x01

cwd_i: .long 0x02 # 0x02: root inode
i_blk: .long 0x01 # 0x01: root dir blk
