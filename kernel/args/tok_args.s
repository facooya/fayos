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

.skip_sp_init:
	# {init}
	add $0x01, %si
	sub $0x01, %bx

.skip_sp:
	# {end}
	test %bx, %bx
	jz .cpy_buf
	mov (%si), %al

	# {body}
	cmp $CHR_SP, %al
	jne .add_zero

	# {step}
	add $0x01, %si
	sub $0x01, %bx
	jmp .skip_sp

.add_zero:
	test %cx, %cx
	jz .chk_tok

	# {body}
	xor %al, %al
	mov %al, (%di)
	add $0x01, %di
	add $0x01, %cx
	jmp .chk_tok

.cpy_chr:
	# {end}
	test %bx, %bx
	jz .cpy_buf
	mov (%si), %al

	# {err}
	cmp $CHR_QUOT, %al
	je .call_hdl_syn_err

	# {next}
	cmp $CHR_SP, %al
	je .skip_sp_init

	# {body}
	mov %al, (%di)
	add $0x01, %di
	add $0x01, %cx

	# {step}
	add $0x01, %si
	sub $0x01, %bx
	jmp .cpy_chr

.tok_quot:
	# {store} quot
	mov %al, (%di)
	add $0x01, %di
	add $0x01, %cx

	# {next} chr
	add $0x01, %si
	sub $0x01, %bx

.tok_quot__cpy:
	# {err}
	test %bx, %bx
	jz .call_hdl_quot_err
	mov (%si), %al

	# {end}
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

	# {step}
	add $0x01, %si
	sub $0x01, %bx

	# {end}
	test %bx, %bx
	jz .cpy_buf
	mov (%si), %al

	# {err}
	cmp $CHR_SP, %al
	jne .call_hdl_syn_err

	# {step}
	jmp .skip_sp_init

.cpy_buf:
	mov $tmp_buf, %di
	mov %cx, (%di)
	add $0x02, %di

	mov $raw_buf, %si
	xor %bx, %bx
	add $0x02, %si

.cpy_buf_lp:
	# {end}
	test %cx, %cx
	jz .cpy_buf_end

	# {cpy}
	mov (%di), %al
	mov %al, (%si)

	# {step}
	add $0x01, %si
	add $0x01, %di
	add $0x01, %bx
	sub $0x01, %cx
	jmp .cpy_buf_lp

.cpy_buf_end:
	mov $raw_buf, %si
	mov %bx, (%si)
	jmp .done

.exit:
	mov $raw_buf, %si
	xor %bx, %bx
	mov %bx, (%si)

.done:
	# DEBUG!!!
	push $raw_buf
	call d_buf
	add $0x02, %sp

	pop %bx
	pop %di
	pop %si
	ret

# ERR
.call_hdl_quot_err:
	call outnl
	call hdl_quot_err
	call outnl
	jmp .exit

.call_hdl_syn_err:
	call outnl
	call hdl_syn_err
	call outnl
	jmp .exit
