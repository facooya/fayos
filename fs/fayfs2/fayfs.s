# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Fayos file system

.section .data

.global i_num
.global b_num
.global fb_num
.global fi_num
.global lba
.global blk_lba
.global free_dentry

i_num: .long 0x02
b_num: .long 0x01
fb_num: .long 0x02
fi_num: .long 0x03
lba: .long 0x80
blk_lba: .long 0x80
free_dentry: .word 0x00
