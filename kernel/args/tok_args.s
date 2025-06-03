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
# <INFO>
# si:bx = &raw_buf:len
# di:cx = &tmp_buf:len
tok_args:
	push %si
	push %di
	push %bx

	# {init}
	mov $raw_buf, %si
	mov (%si), %bx # len
	add $0x02, %si

	# {init}
	mov $tmp_buf, %di
	add $0x02, %di
	xor %cx, %cx # len

	# {end}
	test %bx, %bx
	jz .exit
	jmp .gate

# {TASK}
.gate:
	# {end.done}
	test %bx, %bx
	jz .exit

	mov (%si), %al

	# {task}
	cmp $CHR_SP, %al
	je .skip_sp
	cmp $CHR_QT, %al
	je .tok_qt
	jmp .tok_chr

# {TASK}
.skip_sp:
	# {step}
	add $0x01, %si
	sub $0x01, %bx

.skip_sp__lp:
	# {task}
	test %bx, %bx
	jz .cpy_buf

	# {end}
	mov (%si), %al
	cmp $CHR_SP, %al
	jne .skip_sp__end

	# {lp}
	add $0x01, %si
	sub $0x01, %bx
	jmp .skip_sp__lp

.skip_sp__end:
	# store null
	xor %al, %al
	mov %al, (%di)
	add $0x01, %di
	add $0x01, %cx

	# {task}
	jmp .gate

# {TASK}
.tok_chr:
.tok_chr__lp:
	# {task} (len == 0)
	test %bx, %bx
	jz .cpy_buf

	mov (%si), %al

	# {end.err} (chr == qt)
	cmp $CHR_QT, %al
	je .err_tok

	# {task} (chr == sp)
	cmp $CHR_SP, %al
	je .skip_sp

	# store
	mov %al, (%di)
	add $0x01, %di
	add $0x01, %cx

	# {lp}
	add $0x01, %si
	sub $0x01, %bx
	jmp .tok_chr__lp

# {TASK}
.tok_qt:
	# store qt
	mov %al, (%di)
	add $0x01, %di
	add $0x01, %cx

	# {step}
	add $0x01, %si
	sub $0x01, %bx

.tok_qt__lp:
	# {end.err}
	test %bx, %bx
	jz .err_qt_no

	# {chk}
	mov (%si), %al
	cmp $CHR_QT, %al
	je .tok_qt__chk

	# store
	mov %al, (%di)
	add $0x01, %di
	add $0x01, %cx

	# {lp}
	add $0x01, %si
	sub $0x01, %bx
	jmp .tok_qt__lp

.tok_qt__chk:
	# store qt
	mov %al, (%di)
	add $0x01, %di
	add $0x01, %cx

	# {end} (chr != bsl)
	mov -0x01(%si), %al
	cmp $CHR_BSL, %al
	jne .tok_qt__end

	# {lp}
	add $0x01, %si
	sub $0x01, %bx
	jmp .tok_qt__lp

.tok_qt__end:
	# {step}
	add $0x01, %si
	sub $0x01, %bx

	# {task} (len == 0)
	test %bx, %bx
	jz .cpy_buf

	# {end.err} (chr != space)
	mov (%si), %al
	cmp $CHR_SP, %al
	jne .err_tok

	# {task}
	jmp .skip_sp

# {TASK}
.cpy_buf:
	# {end.done} (len == 0)
	test %cx, %cx
	jz .skip

	# store null
	xor %ax, %ax
	mov %al, (%di)
	add $0x01, %cx

	# {init}
	mov $tmp_buf, %di
	mov %cx, (%di) # store len
	add $0x02, %di # skip len

	# {init}
	mov $raw_buf, %si
	mov %cx, (%si) # store len
	add $0x02, %si # skip len

# <PRE>
# cx = src_len
.cpy_buf__lp:
	# {end} (src_len == 0)
	test %cx, %cx
	jz .cpy_buf__end

	# cpy
	mov (%di), %al
	mov %al, (%si)

	# {lp}
	add $0x01, %si
	add $0x01, %di
	sub $0x01, %cx # src_len
	jmp .cpy_buf__lp

.cpy_buf__end:
	xor %ax, %ax
	jmp .done

# {DONE}
.skip:
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

# {ERR}
.err_qt_no:
	call outnl
	push $qt_no_emsg
	jmp .err_hdl

.err_tok:
	call outnl
	push $tok_emsg
	jmp .err_hdl

.err_hdl:
	call outs
	add $0x02, %sp
	call outnl
	jmp .exit
