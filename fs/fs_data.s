# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# [File System] Data

.section .data
.global bbnum
.global ibnum

.global path_sbuf
.global path_cv
.global cwd

.global fsp

bbnum: .long 0x00
ibnum: .long 0x00

path_sbuf: .zero 0x50
path_cv: .zero 0x50
cwd: .zero 0x100

# file system packet
fsp: .zero 0x200
# ind, ind_ptr, inum, d_sect_cnt, d_mem, d_lba
