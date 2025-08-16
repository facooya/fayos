# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Show paths - pathc, *pathv

.include "chr.s"
.section .data
.pathc_str: .asciz "pathc: "
.pathv_str: .asciz "pathv["
.pathv_end_str: .asciz "]: "

.section .text
.code16
.global dbg_paths

# dbg_paths()
dbg_paths:
	push %si
	push %di
	push %ax
	push %bx
	push %cx
	push %dx

	call outnl
	call dbg_line
	call outnl

	# {{{ pathc
	mov $paths, %si
	mov (%si), %cx
	add $0x02, %si

	push $.pathc_str
	call outs
	add $0x02, %sp

	mov %cx, %ax
	add $0x30, %al
	call outc
	call outnl
	# }}}

	xor %dx, %dx # pathv idx

.lp:
	# {{{ pathv idx
	push $.pathv_str
	call outs
	add $0x02, %sp

	mov %dl, %al
	add $0x30, %al
	call outc

	push $.pathv_end_str
	call outs
	add $0x02, %sp
	# }}}

	# {{{ path out
	mov $path_buf, %di
	add $0x02, %di # skip bufc

	mov (%si), %ax
	add %ax, %di

	push %di
	call outs
	add $0x02, %sp
	# }}}

	# {lp.step}
	add $0x02, %si
	sub $0x01, %cx
	add $0x01, %dx

	# (pathc == 0) ? {end} : {lp}
	test %cx, %cx
	jz .end
	call outnl
	jmp .lp

.end:
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
