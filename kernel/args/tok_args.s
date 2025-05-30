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

	# {done}
	test %bx, %bx
	jz .exit

.chk_tok:
	# {done}
	test %bx, %bx
	jz .exit

	mov (%si), %al

	# {step}
	cmp $CHR_SP, %al
	je .skip_sp
	cmp $CHR_QUOT, %al
	je .tok_quot
	jmp .tok_chr

.skip_sp:
	# {init}
	add $0x01, %si
	sub $0x01, %bx

.skip_sp_lp:
	# {end}
	test %bx, %bx
	jz .cpy_buf

	mov (%si), %al

	# {end}
	cmp $CHR_SP, %al
	jne .add_zero

	# {loop}
	add $0x01, %si
	sub $0x01, %bx
	jmp .skip_sp_lp

.add_zero:
	# {end}
	test %cx, %cx
	jz .chk_tok

	xor %al, %al
	mov %al, (%di)

	# {loop}
	add $0x01, %di
	add $0x01, %cx
	jmp .chk_tok

.tok_chr:
	# (len == 0)
	test %bx, %bx
	jz .cpy_buf

	mov (%si), %al

	# (chr == quot)
	cmp $CHR_QUOT, %al
	je .call_hdl_tok_syn_err

	# (chr == space)
	cmp $CHR_SP, %al
	je .skip_sp

	# store chr
	mov %al, (%di)
	add $0x01, %di
	add $0x01, %cx

	# {loop}
	add $0x01, %si
	sub $0x01, %bx
	jmp .tok_chr

.tok_quot:
	# {store} quot
	mov %al, (%di)
	add $0x01, %di
	add $0x01, %cx

	# {next} chr
	add $0x01, %si
	sub $0x01, %bx

.tok_quot__lp:
	# {err}
	test %bx, %bx
	jz .call_hdl_quot_err

	mov (%si), %al

	# {end}
	cmp $CHR_QUOT, %al
	je .tok_quot__chk_bsl

	# store
	mov %al, (%di)
	add $0x01, %di
	add $0x01, %cx

	# {loop}
	add $0x01, %si
	sub $0x01, %bx
	jmp .tok_quot__lp

.tok_quot__chk_bsl:
	# store quot
	mov %al, (%di)
	add $0x01, %di
	add $0x01, %cx

	mov -0x01(%si), %al

	# (chr != back_slash)
	cmp $CHR_BSLASH, %al
	jne .tok_quot__end

	# {loop}
	add $0x01, %si
	sub $0x01, %bx
	jmp .tok_quot__lp

.tok_quot__end:
	# {loop}
	add $0x01, %si
	sub $0x01, %bx

	# (len == 0)
	test %bx, %bx
	jz .cpy_buf

	mov (%si), %al

	# (chr != space)
	cmp $CHR_SP, %al
	jne .call_hdl_tok_syn_err

	# {loop}
	jmp .skip_sp

# {MAIN} CPY_BUF
.cpy_buf:
	# (len == 0)
	test %cx, %cx
	jz .skip

	# add last null
	xor %ax, %ax
	mov %al, (%di)
	add $0x01, %cx

	# {init}
	mov $tmp_buf, %di
	mov %cx, (%di)
	add $0x02, %di

	# {init}
	mov $raw_buf, %si
	xor %bx, %bx
	add $0x02, %si

.cpy_buf_lp:
	# (len == 0)
	test %cx, %cx
	jz .cpy_buf_end

	# cpy
	mov (%di), %al
	mov %al, (%si)

	# {loop}
	add $0x01, %si
	add $0x01, %di
	add $0x01, %bx
	sub $0x01, %cx
	jmp .cpy_buf_lp

.cpy_buf_end:
	# save len
	mov $raw_buf, %si
	mov %bx, (%si)

	xor %ax, %ax
	jmp .done

# {DONE}
.skip:
	# {init}
	xor %bx, %bx
	mov $raw_buf, %si
	mov %bx, (%si)

	mov $0x02, %ax
	jmp .done

.exit:
	mov $0x01, %ax
	jmp .done

.done:
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

.call_hdl_tok_syn_err:
	call outnl
	call hdl_tok_syn_err
	call outnl
	jmp .exit
