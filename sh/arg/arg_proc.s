# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# [Argument] Process

.include "chr.s"
.section .text
.code16
.global arg_proc

# arg_proc()
# <ret> ax = {true:0, exit:1}
arg_proc:
	push %si

	mov $cl_sbuf, %si
	mov (%si), %cx
	add $0x02, %si

	# (size == 0) ? {exit}
	test %cx, %cx
	jz .exit

.buf__lp:
	# (size == 0) ? {done}
	test %cx, %cx
	jz .exit

	# (chr != sp) ? {end}
	mov (%si), %al
	cmp $CHR_SP, %al
	jne .buf__end

	inc %si
	dec %cx
	jmp .buf__lp

.buf__end:
	call history
	call ._zero

	# { proc
	call arg_tok
	# <ax = {0:true, 1:exit, 2:skip}>

	# (arg_tok() != true) ? {exit}
	test %ax, %ax
	jnz .exit

	call arg_build

	call arg_parse
	# <ax = {true:0, exit:1, redir:2}>

	# (arg_parse() == exit) ? {exit}
	cmp $0x01, %ax
	je .exit
	# (arg_parse() == redir) ? {redir} : {done}
	cmp $0x02, %ax
	je .done_redir
	jmp .done
	# }

.exit:
	# {zero}
	xor %ax, %ax
	mov (cl_sbuf), %cx
	add $0x02, %cx

	push %cx # (size)
	push %ax # (value)
	push $cl_sbuf # (&off)
	push %ax # (&seg)
	call mem_set
	add $0x08, %sp
	call ._zero

	mov $0x01, %ax
	jmp .epil

.done_redir:
	mov $0x02, %ax
	jmp .epil

.done:
	xor %ax, %ax
	jmp .epil

.epil:
	pop %si
	ret

._zero:
	xor %ax, %ax
	mov (tmp_sbuf), %cx
	add $0x02, %cx

	push %cx # (size)
	push %ax # (value)
	push $tmp_sbuf # (&off)
	push %ax # (&seg)
	call mem_set
	add $0x08, %sp

	call clear_redir_buf

	xor %ax, %ax
	mov $arg_ccv, %si
	mov %ax, (%si) # arg_c
	mov %ax, 0x02(%si) # opt_c
	mov %ax, 0x04(%si) # arg_v[0]
	ret
