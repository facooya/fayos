# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Tokenize for arguments

.include "chr.s"

.section .text
.code16
.global tok_args

# tok_args()
# si,bx = (raw_buf) len, data
# di,cx = (tmp_buf) len, data
tok_args:
	push %si
	push %di
	push %bx

	# {init} raw_buf
	mov $raw_buf, %si
	mov (%si), %bx
	add $0x02, %si

	# {init} tmp_buf
	mov $tmp_buf, %di
	add $0x02, %di
	xor %cx, %cx

	# {exit}
	test %bx, %bx
	jz .exit

.chk_tok:
	# {exit}
	test %bx, %bx
	jz .exit
	mov (%si), %al

	# {body}
	cmp $CHR_SP, %al
	je .skip_sp_init
	cmp $CHR_QUOT, %al
	je .tok_quot
	jmp .cpy_chr

.skip_sp_zero:
	xor %al, %al
	mov %al, (%di)
	add $0x01, %di
	add $0x01, %cx

.skip_sp_init:
	# {init}
	add $0x01, %si
	sub $0x01, %bx

.skip_sp:
	# {exit}
	test %bx, %bx
	jz .exit
	mov (%si), %al

	# {body}
	cmp $CHR_SP, %al
	jne .chk_tok

	# {step}
	add $0x01, %si
	sub $0x01, %bx
	jmp .skip_sp

.cpy_chr:
	# {end}
	test %bx, %bx
	jz .cpy_buf
	mov (%si), %al

	# {next}
	cmp $CHR_SP, %al
	je .skip_sp_zero

	# {body}
	mov %al, (%di)
	add $0x01, %di
	add $0x01, %cx

	# {step}
	add $0x01, %si
	sub $0x01, %bx
	jmp .cpy_chr

.tok_quot:
	mov %al, (%di)
	add $0x01, %di
	add $0x01, %cx

	add $0x01, %si
	sub $0x01, %bx

.tok_quot__cpy:
	# {exit}
	test %bx, %bx
	jz .exit
	mov (%si), %al

	cmp $CHR_QUOT, %al
	je .tok_quot__end

	# {body}
	mov %al, (%di)
	add $0x01, %di
	add $0x01, %cx

	# {step}
	add $0x01, %si
	sub $0x01, %bx
	jmp .tok_quot__cpy

.tok_quot__end:
	# TODO: except \"
	mov %al, (%di)
	add $0x01, %di
	add $0x01, %cx

	add $0x01, %si
	sub $0x01, %bx
	test %bx, %bx
	jz .cpy_buf
	jmp .skip_sp_zero

.cpy_buf:
	mov $tmp_buf, %di
	mov %cx, (%di)
	jmp .done

.exit:

.done:
	# DEBUG!!!
	push $tmp_buf
	call d_buf
	add $0x02, %sp

	pop %bx
	pop %di
	pop %si
	ret
