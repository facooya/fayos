# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Buffer

.section .data
.global raw_buf
.global tmp_buf
.global redir_buf
.global write_buf

raw_buf: .zero 0x400
tmp_buf: .zero 0x400
redir_buf: .zero 0x200
write_buf: .zero 0x400

.section .text
.code16
.global clear_buf

# clear_buf(buf)
clear_buf:
	# prol
	push %bp
	mov %sp, %bp
	push %si
	
	# init
	mov 0x04(%bp), %si
	mov (%si), %cx

	# zero_len
	xor %ax, %ax
	mov %ax, (%si)
	add $0x02, %si

.clear_buf__zero_buf:
	# {escape}
	test %cx, %cx
	jz .clear_buf__done

	# zero
	xor %al, %al
	mov %al, (%si)

	# step
	add $0x01, %si
	sub $0x01, %cx
	jmp .clear_buf__zero_buf

.clear_buf__done:
	# epil
	pop %si
	pop %bp
	ret
