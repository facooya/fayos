# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# [Debug] Show paths - pathc, *pathv

.include "chr.inc"
.section .data
.pathc_str: .asciz "pathc: "
.pathv_str: .asciz "pathv["
.pathv_end_str: .asciz "]: "

.section .text
.code16
.global dbg_path_cv

# dbg_path_cv()
dbg_path_cv:
	push %si
	push %di
	push %ax
	push %bx
	push %cx
	push %dx

	mov $CHR_CR, %al
	call vga_outc
	mov $CHR_LF, %al
	call vga_outc
	call dbg_line
	mov $CHR_CR, %al
	call vga_outc
	mov $CHR_LF, %al
	call vga_outc

	# {{{ pathc
	mov $path_cv, %si
	mov (%si), %cx
	add $0x02, %si

	push %cx # [s.f0:pathc]
	push $.pathc_str
	call vga_outs
	add $0x02, %sp
	pop %cx # [s.f0:pathc]

	push %cx # [s.f0:pathc]
	mov %cx, %ax
	add $0x30, %al
	call vga_outc

	mov $CHR_CR, %al
	call vga_outc
	mov $CHR_LF, %al
	call vga_outc
	pop %cx # [s.f0:pathc]
	# }}}

	xor %dx, %dx # pathv idx

.lp:
	# {{{ pathv idx
	push %cx # [s.0:pathc]
	push %dx # [s.1:pathv]

	push $.pathv_str
	call vga_outs
	add $0x02, %sp

	pop %dx # [s.1:pathv]
	push %dx # [s.1:pathv]

	mov %dl, %al
	add $0x30, %al
	call vga_outc

	push $.pathv_end_str
	call vga_outs
	add $0x02, %sp
	# }}}

	# {{{ path out
	mov $path_sbuf, %di
	add $0x02, %di # skip bufc

	mov (%si), %ax
	add %ax, %di

	push %di
	call vga_outs
	add $0x02, %sp
	# }}}
	pop %dx # [s.1:pathv]
	pop %cx # [s.0:pathc]

	# {lp.step}
	add $0x02, %si
	sub $0x01, %cx
	add $0x01, %dx

	# (pathc == 0) ? {end} : {lp}
	test %cx, %cx
	jz .end

	push %cx
	push %dx
	mov $CHR_CR, %al
	call vga_outc
	mov $CHR_LF, %al
	call vga_outc
	pop %dx
	pop %cx
	jmp .lp

.end:
	mov $CHR_CR, %al
	call vga_outc
	mov $CHR_LF, %al
	call vga_outc
	call dbg_line
	mov $CHR_CR, %al
	call vga_outc
	mov $CHR_LF, %al
	call vga_outc

	pop %dx
	pop %cx
	pop %bx
	pop %ax
	pop %di
	pop %si
	ret
