# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# [Kernel] Data

.section .data
.global cl_lbuf
.global cl_hist_lbuf
.global tmp_buf
.global redir_buf
.global write_buf
.global path_buf
.global cursor

cl_lbuf: .zero 0x400
cl_hist_lbuf: .zero 0x400
tmp_buf: .zero 0x400
redir_buf: .zero 0x200
write_buf: .zero 0x400
path_buf: .zero 0x100

cursor:
	.word 0x00 # min_pos
	.word 0x00 # max_pos

.section .text
.code16
.global clear_redir_buf

# clear_redir_buf()
clear_redir_buf:
	push %si

	# {init}
	xor %cx, %cx
	mov $redir_buf, %si
	mov (%si), %ax # type:len
	mov %cx, (%si)
	mov %al, %cl

.zero__lp:
	# {end} (redir.len == 0)
	test %cx, %cx
	jz .zero__end

	xor %al, %al
	mov %al, (%si)

	# {lp}
	add $0x01, %si # redir.data
	sub $0x01, %cx # redir.len
	jmp .zero__lp

.zero__end:
	pop %si
	ret
