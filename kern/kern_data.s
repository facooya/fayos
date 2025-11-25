# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# [Kernel] Data

.section .data
.global cl_sbuf
.global cl_hist_sbuf
.global tmp_sbuf
.global redir_hsbuf
.global write_sbuf

.global date_zbuf

.global curs

cl_sbuf: .zero 0x200
cl_hist_sbuf: .zero 0x200
tmp_sbuf: .zero 0x200
redir_hsbuf: .zero 0x200
write_sbuf: .zero 0x200

date_zbuf: .zero 0x10

curs:
	.word 0x00 # min_pos
	.word 0x00 # max_pos
