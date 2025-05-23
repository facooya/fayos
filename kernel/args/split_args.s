# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Split for arguments

.include "chr.s"

.section .text
.code16
.global split_args

# split_args()
# si = raw_buf
# di = tmp_buf
# bx = raw_buf_len
# cx = tmp_buf_len
split_args:
	push %si
	push %di
	push %bx

	mov $raw_buf, %si
	mov (%si), %bx
	add $0x02, %si

	mov $tmp_buf, %di
	xor %cx, %cx
	add $0x02, %di

.chk_tok:
	test %bx, %bx
	jz .tok_end
	mov (%si), %al

	# TODO add '
	cmp $CHR_HYPHEN, %al
	je .cpy_opt
	cmp $CHR_QUOT, %al
	je .cpy_quot_init
	cmp $CHR_GT, %al
	je .cpy_redir
	jmp .cpy_chr

.add_zero:
	xor %al, %al
	mov %al, (%di)
	add $0x01, %di
	add $0x01, %cx

.skip_sp:
	test %bx, %bx
	jz .exit
	mov (%si), %al

	cmp $CHR_SP, %al
	jne .chk_tok

	add $0x01, %si
	sub $0x01, %bx
	jmp .skip_sp

.cpy_chr:
	test %bx, %bx
	jz .tok_end
	mov (%si), %al

	cmp $CHR_SP, %al
	je .add_zero
	mov %al, (%di)
	add $0x01, %di
	add $0x01, %cx

	add $0x01, %si
	sub $0x01, %bx
	jmp .cpy_chr

.cpy_opt:
	mov %al, %ah
	add $0x01, %si
	sub $0x01, %bx
	mov (%si), %al
	cmp $CHR_SP, %al
	je .exit

.norm_opt:
	test %bx, %bx
	jz .exit
	mov (%si), %al

	cmp $CHR_SP, %al
	je .skip_sp
	mov %ah, (%di)
	mov %al, 0x01(%di)
	xor %al, %al
	mov %al, 0x02(%di)
	add $0x03, %di
	add $0x03, %cx

	add $0x01, %si
	sub $0x01, %bx
	jmp .norm_opt

.cpy_quot_init:
	mov %al, (%di)
	add $0x01, %di
	add $0x01, %cx

	add $0x01, %si
	sub $0x01, %bx

.cpy_quot:
	test %bx, %bx
	jz .exit
	mov (%si), %al

	cmp $CHR_QUOT, %al
	je .cpy_quot_end
	mov %al, (%di)
	add $0x01, %di
	add $0x01, %cx

	add $0x01, %si
	sub $0x01, %bx
	jmp .cpy_quot

.cpy_quot_end:
	# TODO except \"
	mov %al, (%di)
	add $0x01, %di
	add $0x01, %cx

	add $0x01, %si
	sub $0x01, %bx
	test %bx, %bx
	jz .tok_end
	mov (%si), %al
	cmp $CHR_SP, %al
	je .add_zero
	jmp .exit

.cpy_redir:
	mov $tmp_buf, %di
	mov %cx, (%di)

	mov $redir_buf, %di
	add $0x02, %di
	xor %cx, %cx

	mov %al, (%di)
	add $0x01, %di
	add $0x01, %cx

	add $0x01, %si
	sub $0x01, %bx

1:
	test %bx, %bx
	jz .exit
	mov (%si), %al
	cmp $CHR_SP, %al
	jne 2f

	add $0x01, %si
	sub $0x01, %bx
	jmp 1b

2:
	test %bx, %bx
	jz 3f
	mov (%si), %al

	mov %al, (%di)
	add $0x01, %di
	add $0x01, %cx

	add $0x01, %si
	sub $0x01, %bx
	jmp 2b

3:
	mov $redir_buf, %di
	mov %cx, (%di)
	jmp .cpy_redir_end

.cpy_redir_end:
	jmp .exit

.tok_end:
	# TODO: add null?
	mov $tmp_buf, %di
	mov %cx, (%di)

	xor %ax, %ax
	jmp .exit # DEBUG!!!

.exit:
	# DEBUG!!!
	push $raw_buf
	call d_buf
	add $0x02, %sp
	push $tmp_buf
	call d_buf
	add $0x02, %sp
	push $redir_buf
	call d_buf
	add $0x02, %sp

	mov $0x01, %ax

.done:
	pop %bx
	pop %di
	pop %si
	ret
