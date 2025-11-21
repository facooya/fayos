# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# [Argument] Tokenize

.include "chr.s"
.section .text
.code16
.global arg_tok

# arg_tok()
# <info>
# bx:si = (cl_sbuf) size:chr
# cx:di = (tmp_sbuf) size:chr
# <ret> ax = {0:true, 1:exit, 2:skip}
# <mod> cl_sbuf, tmp_sbuf
arg_tok:
	push %si
	push %di
	push %bx

	# { init
	mov $cl_sbuf, %si
	mov (%si), %bx
	add $0x02, %si

	mov $tmp_sbuf, %di
	add $0x02, %di
	xor %cx, %cx
	# }

	# (cl_sbuf.size == 0) ? {skip} : {gate}
	test %bx, %bx
	jz .skip
	jmp .gate

.gate:
	mov (%si), %al
	cmp $CHR_SP, %al
	je .skip_sp
	cmp $CHR_QT, %al
	je .tok_qt
	cmp $CHR_HS, %al
	je .tok_hs
	jmp .tok_chr

.skip_sp:
	inc %si
	dec %bx

.skip_sp__lp:
	# (cl_sbuf.size == 0) ? {cpy_buf}
	test %bx, %bx
	jz .cpy_buf

	# (cl_sbuf.chr != sp) ? {end}
	mov (%si), %al
	cmp $CHR_SP, %al
	jne .skip_sp__end

	inc %si
	dec %bx
	jmp .skip_sp__lp

.skip_sp__end:
	# (tmp_sbuf.size == 0) ? {gate}
	test %cx, %cx
	jz .gate

	# store null
	xor %al, %al
	mov %al, (%di)
	inc %di
	inc %cx
	jmp .gate

.tok_chr:
.tok_chr__lp:
	# (cl_sbuf.size == 0) ? {cpy_buf}
	test %bx, %bx
	jz .cpy_buf

	# {{{
	mov (%si), %al

	# (chr == qt) ? {err}
	cmp $CHR_QT, %al
	je .err_tok_syn

	# (chr == sp) ? {skip_sp}
	cmp $CHR_SP, %al
	je .skip_sp

	# (chr == hash) ? {tok_chr_hs}
	cmp $CHR_HS, %al
	je .tok_chr_hs

	# store tmp_sbuf
	mov %al, (%di)
	inc %di
	inc %cx
	# }}}

	inc %si
	dec %bx
	jmp .tok_chr__lp

.tok_hs:
	dec %cx

.tok_chr_hs:
	# (cl_sbuf[i-1].chr != bsl) ? {cpy_buf}
	mov -0x01(%si), %al
	cmp $CHR_BSL, %al
	jne .cpy_buf

	# replace
	mov $CHR_HS, %al
	mov %al, -0x01(%di)

	inc %si
	dec %bx
	jmp .gate

.tok_qt:
	# skip qt
	inc %si
	dec %bx

.tok_qt__lp:
	# (cl_sbuf.size == 0) ? {err}
	test %bx, %bx
	jz .err_qt_no

	# (cl_sbuf.chr == qt) ? {chk}
	mov (%si), %al
	cmp $CHR_QT, %al
	je .tok_qt__chk

	# store tmp_sbuf
	mov %al, (%di)
	inc %di
	inc %cx

	inc %si
	dec %bx
	jmp .tok_qt__lp

.tok_qt__chk:
	# (chr-1 == bsl) ? {chk} ? {end}
	mov -0x01(%si), %al
	cmp $CHR_BSL, %al
	je .tok_qt__chk_bsl
	jmp .tok_qt__end

.tok_qt__chk_bsl:
	# (chr-2 == bsl) ? {end}
	mov -0x02(%si), %al
	cmp $CHR_BSL, %al
	je .tok_qt__end

	# replace bsl -> qt
	mov $CHR_QT, %al
	mov %al, -0x01(%di)

	inc %si
	dec %bx
	jmp .tok_qt__lp

.tok_qt__end:
	inc %si
	dec %bx

	# (size == 0) ? {cpy_buf}
	test %bx, %bx
	jz .cpy_buf

	# (chr != sp) ? {err} ? {skip_sp}
	mov (%si), %al
	cmp $CHR_SP, %al
	jne .err_tok_syn
	jmp .skip_sp

# {TASK}
.cpy_buf:
	push %cx # [s.f0:tmp_sbuf.size]
	xor %ax, %ax
	mov (cl_sbuf), %cx
	add $0x02, %cx
	push %cx # (size)
	push %ax # (value)
	push $cl_sbuf # (&off)
	push %ax # (&seg)
	call mem_set
	add $0x08, %sp
	pop %cx # [s.f0:tmp_sbuf.size]

	# store last null
	xor %ax, %ax
	mov %al, (%di)
	inc %cx

	# {
	mov $tmp_sbuf, %di
	mov %cx, (%di)
	add $0x02, %di

	mov $cl_sbuf, %si
	mov %cx, (%si)
	add $0x02, %si
	# }

# <pre>
# si = *cl_sbuf.chr
# cx:di = (tmp_sbuf) size:chr
.cpy_buf__lp:
	# (size == 0) ? {end}
	test %cx, %cx
	jz .cpy_buf__end

	# cpy
	mov (%di), %al
	mov %al, (%si)

	inc %si # cl.chr
	inc %di # tmp.chr
	dec %cx # tmp.size
	jmp .cpy_buf__lp

.cpy_buf__end:
	xor %ax, %ax # <ret:code>
	jmp .done

# {DONE}
.skip:
	mov $0x02, %ax # <ret:code>
	jmp .done

.exit:
	mov $0x01, %ax # <ret:code>
	jmp .done

.done:
	pop %bx
	pop %di
	pop %si
	ret

# {ERR}
.err_qt_no:
	mov $CHR_CR, %al
	call vga_putc
	mov $CHR_LF, %al
	call vga_putc
	push $emsg_qt_no
	jmp .err_hdl

.err_tok_syn:
	mov $CHR_CR, %al
	call vga_putc
	mov $CHR_LF, %al
	call vga_putc
	push $emsg_tok_syn
	jmp .err_hdl

.err_hdl:
	call vga_puts
	add $0x02, %sp
	mov $CHR_CR, %al
	call vga_putc
	mov $CHR_LF, %al
	call vga_putc
	jmp .exit
