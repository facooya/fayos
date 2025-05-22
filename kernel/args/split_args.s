# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Split arguments

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

.norm_cpy:
	test %bx, %bx
	jz .norm_cpy_end
	mov (%si), %al

	cmp $CHR_SP, %al
	je .space
	mov %al, (%di)
	add $0x01, %di
	add $0x01, %cx

	add $0x01, %si
	sub $0x01, %bx
	jmp .norm_cpy

.space:
	xor %al, %al
	mov %al, (%di)
	add $0x01, %di
	add $0x01, %cx

1:
	test %bx, %bx
	jz .exit
	mov (%si), %al

	# TODO add '
	cmp $CHR_HYPHEN, %al
	je .hyphen
	cmp $CHR_QUOT, %al
	je .quot
	cmp $CHR_GT, %al
	je .gt
	cmp $CHR_SP, %al
	jne .norm_cpy

	add $0x01, %si
	sub $0x01, %bx
	jmp 1b

.hyphen:
	mov %al, %ah
	add $0x01, %si
	sub $0x01, %bx

1:
	test %bx, %bx
	jz .exit
	mov (%si), %al

	cmp $CHR_SP, %al
	je .space
	mov %ah, (%di)
	mov %al, 0x01(%di)
	xor %al, %al
	mov %al, 0x02(%di)
	add $0x03, %di
	add $0x03, %cx

	add $0x01, %si
	sub $0x01, %bx
	jmp 1b

.quot:
	mov %al, (%di)
	add $0x01, %di
	add $0x01, %cx

	add $0x01, %si
	sub $0x01, %bx

1:
	test %bx, %bx
	jz .exit
	mov (%si), %al

	cmp $CHR_QUOT, %al
	je 2f
	mov %al, (%di)
	add $0x01, %di
	add $0x01, %cx

	add $0x01, %si
	sub $0x01, %bx
	jmp 1b

2:
	# TODO except \"
	mov %al, (%di)
	add $0x01, %di
	add $0x01, %cx

	add $0x01, %si
	sub $0x01, %bx
	jmp .norm_cpy

.gt:
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
	jmp .gt_end

.gt_end:
	jmp .exit

.norm_cpy_end:
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
