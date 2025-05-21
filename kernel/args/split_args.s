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

.write:
	test %bx, %bx
	jz .write_end
	mov (%si), %al

	# TODO add '
	cmp $CHR_SP, %al
	je .sp
	cmp $CHR_QUOT, %al
	je .quot
	cmp $CHR_GT, %al
	je .gt
	mov %al, (%di)

	add $0x01, %si
	add $0x01, %di
	sub $0x01, %bx
	add $0x01, %cx
	jmp .write

.sp:
	add $0x01, %si
	sub $0x01, %bx
	mov -1(%di), %al
	test %al, %al
	jz 1f

	xor %al, %al
	mov %al, (%di)
	add $0x01, %di
	add $0x01, %cx

1:
	test %bx, %bx
	jz .exit
	mov (%si), %al

	cmp $CHR_HYPHEN, %al
	je .sp_hyphen
	cmp $CHR_SP, %al
	jne .write

	add $0x01, %si
	sub $0x01, %bx
	jmp 1b

.sp_hyphen:
	mov %al, %ah
	add $0x01, %si
	sub $0x01, %bx

1:
	test %bx, %bx
	jz .exit
	mov (%si), %al

	cmp $CHR_SP, %al
	je .sp
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
	add $0x01, %si
	sub $0x01, %bx

	cmp $CHR_QUOT, %al
	je 2f
	mov %al, (%di)
	add $0x01, %di
	add $0x01, %cx
	jmp 1b

2:
	# TODO except \"
	mov %al, (%di)
	xor %al, %al
	mov %al, 0x01(%di)
	add $0x02, %di
	add $0x02, %cx
	jmp .write

.gt:
	
.write_end:
	xor %ax, %ax
	jmp .done

.exit:
	# HACK
	mov $tmp_buf, %di
	mov %cx, (%di)

	# DEBUG!!!
	push $raw_buf
	call d_buf
	add $0x02, %sp
	push $tmp_buf
	call d_buf
	add $0x02, %sp

	mov $0x01, %ax

.done:
	pop %bx
	pop %di
	pop %si
	ret
