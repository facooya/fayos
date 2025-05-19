# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Buffer

.section .data
.global raw_buf
.global raw_buf_len
.global tmp_buf
.global tmp_buf_len
.global redir_buf
.global redir_buf_len
.global write_buf
.global write_buf_len

raw_buf: .zero 0x400
raw_buf_len: .word 0x00
tmp_buf: .zero 0x400
tmp_buf_len: .word 0x00
redir_buf: .zero 0x200
redir_buf_len: .word 0x00
write_buf: .zero 0x400
write_buf_len: .word 0x00

.section .text
.code16
.global clear_buf

# clear_buf(buf, len)
clear_buf:
	# prol
	push %bp
	mov %sp, %bp
	push %si
	push %di
	
	# init
	mov 0x04(%bp), %si
	mov 0x06(%bp), %di
	mov (%di), %cx

.clear_buf__zero_buf:
	# (len <= 0) ? zero_len {escape}
	cmp $0x00, %cx
	jle .clear_buf__zero_len

	# zero
	xor %al, %al
	mov %al, (%si)

	# step
	add $0x01, %si
	sub $0x01, %cx
	jmp .clear_buf__zero_buf

.clear_buf__zero_len:
	# zero
	xor %cx, %cx
	mov %cx, (%di)

	# epil
	pop %di
	pop %si
	pop %bp
	ret
