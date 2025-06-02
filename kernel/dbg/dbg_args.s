# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Debug for argc, optc, argv

.include "chr.s"
.section .data
# TODO: using outs
.argc_str: .asciz "argc: "
.optc_str: .asciz "optc: "
.argv_str: .asciz "argv["
.argv_end_str: .asciz "]: "

.section .text
.code16
.global dbg_args

# dbg_args()
dbg_args:
	push %si
	push %di
	push %bx

	call outnl
	call dbg_line
	call outnl

	# {init} raw_buf
	mov $raw_buf, %si
	mov (%si), %bx
	add $0x02, %si

	# show argc
	mov $args, %di
	mov (%di), %cx # argc
	add $0x02, %di # skip argc
	mov %cx, %ax
	add $0x30, %al
	push %cx
	call sys_tty_out
	pop %cx

	call outnl

	# show optc
	mov (%di), %ax # optc
	add $0x02, %di # skip optc
	add $0x30, %al
	push %cx
	call sys_tty_out
	pop %cx

.argv__lp:
	# {end.done}
	test %cx, %cx
	jz .done
	call outnl

	mov $raw_buf, %si
	add $0x02, %si
	mov (%di), %ax
	add %ax, %si

	push %si
	call puts
	add $0x02, %sp

	# {lp}
	add $0x02, %di # argv
	sub $0x01, %cx # argc
	jmp .argv__lp

.done:
	call outnl
	call dbg_line
	call outnl

	pop %bx
	pop %di
	pop %si
	ret
