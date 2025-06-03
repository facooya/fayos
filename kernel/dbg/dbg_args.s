# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Debug for argc, optc, argv

.include "chr.s"
.section .data

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
	push %ax
	push %bx
	push %cx
	push %dx

	call outnl
	call dbg_line
	call outnl

	# {init} raw_buf
	mov $raw_buf, %si
	mov (%si), %bx
	add $0x02, %si

# {TASK}
	# outs(&str)
	push $.argc_str
	call outs
	add $0x02, %sp

	# get argc
	mov $args, %di
	mov (%di), %cx # argc
	add $0x02, %di # skip argc

	# byte to ascii
	mov %cx, %ax
	add $0x30, %al

	# outc() argc
	call outc
	call outnl

# {TASK}
	# outs(&str)
	push $.optc_str
	call outs
	add $0x02, %sp

	# get optc
	mov (%di), %ax # optc
	add $0x02, %di # skip optc

	# byte to ascii
	add $0x30, %al

	# outc() optc
	call outc
	call outnl
	jmp .argv

# {TASK}
.argv:
	# {end.done}
	test %cx, %cx
	jz .done

	xor %dx, %dx # idx

.argv__lp:
	# {{{
	push $.argv_str
	call outs
	add $0x02, %sp

	# outc() idx
	mov %dl, %al # idx
	add $0x30, %al
	call outc

	push $.argv_end_str
	call outs
	add $0x02, %sp
	# }}}

	# {{{
	# {init}
	mov $raw_buf, %si
	add $0x02, %si # skip len

	# calc offset
	mov (%di), %ax # argv[i]
	add %ax, %si

	# outs(&str)
	push %si
	call outs
	add $0x02, %sp
	# }}}

	# {lp.step}
	add $0x02, %di # argv
	sub $0x01, %cx # argc
	add $0x01, %dx # idx

	# {chk}
	test %cx, %cx
	jz .done

	# {lp}
	call outnl
	jmp .argv__lp

.done:
	call outnl
	call dbg_line
	call outnl

	pop %dx
	pop %cx
	pop %bx
	pop %ax
	pop %di
	pop %si
	ret
