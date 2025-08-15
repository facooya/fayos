# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Buffer

.section .data
.global raw_buf
.global hist_buf
.global tmp_buf
.global redir_buf
.global write_buf
.global path_buf

raw_buf: .zero 0x400
hist_buf: .zero 0x400
tmp_buf: .zero 0x400
redir_buf: .zero 0x200
write_buf: .zero 0x400
path_buf: .zero 0x100

.section .text
.code16
.global clear_buf
.global clear_redir_buf

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
