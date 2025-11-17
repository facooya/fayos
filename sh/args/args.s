# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Argments main

# NOTE
# [n_args]
# argc [2-byte]
# optc [2-byte]
# argv [2-byte]-[156-byte]

.include "chr.s"
.section .data
.global args

args: .zero 0x100

.section .text
.code16
.global proc_args

# proc_args()
# <RET>
# ax = 0:true, 1:exit
proc_args:
	push %si

	mov $cl_sbuf, %si
	mov (%si), %cx
	add $0x02, %si

	test %cx, %cx
	jz .exit

.raw__lp:
	# {end.done} (len == 0)
	test %cx, %cx
	jz .exit

	# {end} (*data != sp)
	mov (%si), %al
	cmp $CHR_SP, %al
	jne .raw__end

	# {lp}
	add $0x01, %si
	sub $0x01, %cx
	jmp .raw__lp

.raw__end:
	call history
	call ._zero

	# {{{ proc
	call tok_args
	test %ax, %ax
	jnz .exit

	call build_args

	call parse_args
	cmp $0x01, %ax
	je .exit
	cmp $0x02, %ax
	je .done_redir
	jmp .done
	# }}}

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
	mov $args, %si
	mov %ax, (%si) # argc
	mov %ax, 0x02(%si) # optc
	mov %ax, 0x04(%si) # argv[0]
	ret
