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

	mov $cmd_lbuf, %si
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
	test %ax, %ax
	jnz .exit

	jmp .done
	# }}}

.exit:
	# {zero}
	push $cmd_lbuf
	call bufzero
	add $0x02, %sp
	call ._zero

	mov $0x01, %ax
	jmp .epil

.done:
	xor %ax, %ax
	jmp .epil

.epil:
	pop %si
	ret

._zero:
	push $tmp_buf
	call bufzero
	add $0x02, %sp

	call clear_redir_buf

	xor %ax, %ax
	mov $args, %si
	mov %ax, (%si) # argc
	mov %ax, 0x02(%si) # optc
	mov %ax, 0x04(%si) # argv[0]
	ret
