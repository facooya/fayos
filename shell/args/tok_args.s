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
# bx:si = (raw_buf) len:&data
# cx:di = (tmp_buf) len:&data
# <RET>
# ax = 0:true, 1:exit, 2:skip
tok_args:
	push %si
	push %di
	push %bx

	# {{{ init
	mov $raw_buf, %si
	mov (%si), %bx # len
	add $0x02, %si

	mov $tmp_buf, %di
	add $0x02, %di

	xor %cx, %cx # tmp.len
	# }}}

	# {end.skip}
	test %bx, %bx # raw.len
	jz .skip
	jmp .gate

# {TASK}
.gate:
	mov (%si), %al # raw.data

	# {task}
	cmp $CHR_SP, %al
	je .skip_sp
	cmp $CHR_QT, %al
	je .tok_qt
	cmp $CHR_HS, %al
	je .tok_hs
	jmp .tok_chr

# {TASK}
.skip_sp:
	# {init.step}
	add $0x01, %si # raw.data
	sub $0x01, %bx # raw.len

.skip_sp__lp:
	# {task} (raw.len == 0)
	test %bx, %bx
	jz .cpy_buf

	# {end} (raw.data != sp)
	mov (%si), %al
	cmp $CHR_SP, %al
	jne .skip_sp__end

	# {lp}
	add $0x01, %si # raw.data
	sub $0x01, %bx # raw.len
	jmp .skip_sp__lp

.skip_sp__end:
	# {task} (tmp.len == 0)
	test %cx, %cx
	jz .gate

	# store null
	xor %al, %al
	mov %al, (%di)
	add $0x01, %di # tmp.data
	add $0x01, %cx # tmp.len

	# {task}
	jmp .gate

# {TASK}
.tok_chr:
.tok_chr__lp:
	# {task} (raw.len == 0)
	test %bx, %bx
	jz .cpy_buf

	# {{{
	mov (%si), %al # raw.data

	# {end.err} (raw.data == qt)
	cmp $CHR_QT, %al
	je .err_tok_syn

	# {task} (raw.data == sp)
	cmp $CHR_SP, %al
	je .skip_sp

	# {task} (raw.data == hash)
	cmp $CHR_HS, %al
	je .tok_chr_hs

	# store
	mov %al, (%di)
	add $0x01, %di # tmp.data
	add $0x01, %cx # tmp.len
	# }}}

	# {lp}
	add $0x01, %si # raw.data
	sub $0x01, %bx # raw.len
	jmp .tok_chr__lp

# {TASK}
.tok_hs:
	sub $0x01, %cx

.tok_chr_hs:
	# (raw_buf[i-1] != back_slash) ? {cpy_buf}
	mov -0x01(%si), %al
	cmp $CHR_BSL, %al
	jne .cpy_buf

	# replace
	sub $0x01, %di
	sub $0x01, %cx
	mov $CHR_HS, %al
	mov %al, (%di)
	add $0x01, %di
	add $0x01, %cx

	# {lp.gate}
	add $0x01, %si
	sub $0x01, %bx
	jmp .gate

# {TASK}
.tok_qt:
	# skip qt
	add $0x01, %si # raw.data
	sub $0x01, %bx # raw.len

.tok_qt__lp:
	# {end.err} (raw.len == 0)
	test %bx, %bx
	jz .err_qt_no

	# {chk} (raw.data == qt)
	mov (%si), %al
	cmp $CHR_QT, %al
	je .tok_qt__chk

	# store
	mov %al, (%di)
	add $0x01, %di # tmp.data
	add $0x01, %cx # tmp.len

	# {lp}
	add $0x01, %si # raw.data
	sub $0x01, %bx # raw.len
	jmp .tok_qt__lp

.tok_qt__chk:
	# {chk} (raw.data-1 == bsl)
	mov -0x01(%si), %al
	cmp $CHR_BSL, %al
	je .tok_qt__chk_bsl

	# {end}
	jmp .tok_qt__end

.tok_qt__chk_bsl:
	# {end} (raw.data-2 == bsl)
	mov -0x02(%si), %al
	cmp $CHR_BSL, %al
	je .tok_qt__end

	# change bsl -> qt
	mov $CHR_QT, %al
	mov %al, -0x01(%di) # tmp.data-1

	# {lp}
	add $0x01, %si # raw.data
	sub $0x01, %bx # raw.len
	jmp .tok_qt__lp

.tok_qt__end:
	# {step}
	add $0x01, %si # raw.data
	sub $0x01, %bx # raw.len

	# {task} (raw.len == 0)
	test %bx, %bx
	jz .cpy_buf

	# {end.err} (raw.data != sp)
	mov (%si), %al
	cmp $CHR_SP, %al
	jne .err_tok_syn

	# {task}
	jmp .skip_sp

# {TASK}
.cpy_buf:
	push %cx
	push $raw_buf
	call bufzero
	add $0x02, %sp
	pop %cx

	# store last null
	xor %ax, %ax
	mov %al, (%di) # tmp.data
	add $0x01, %cx # tmp.len

	# {{{
	mov $tmp_buf, %di
	mov %cx, (%di) # store len
	add $0x02, %di # skip len

	mov $raw_buf, %si
	mov %cx, (%si) # store len
	add $0x02, %si # skip len
	# }}}

# <PRE>
# si = &raw.data
# cx:di = (tmp_buf) len:&data
.cpy_buf__lp:
	# {end} (tmp.len == 0)
	test %cx, %cx
	jz .cpy_buf__end

	# tmp to raw
	mov (%di), %al
	mov %al, (%si)

	# {lp}
	add $0x01, %si # raw.data
	add $0x01, %di # tmp.data
	sub $0x01, %cx # tmp.len
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
	push $emsg_qt_no
	jmp .err_hdl

.err_tok_syn:
	call outnl
	push $emsg_tok_syn
	jmp .err_hdl

.err_hdl:
	call outs
	add $0x02, %sp
	call outnl
	jmp .exit
