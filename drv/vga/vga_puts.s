# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Video put string

.include "drv/vga.s"
.include "chr.s"
.section .text
.code16
.global vga_puts

# vga_puts(*str)
vga_puts:
	push %bp
	mov %sp, %bp
	push %es
	push %si
	push %di
	push %bx

	mov 0x04(%bp), %si

	mov $VGA_SEG, %ax
	mov %ax, %es
	xor %di, %di

	call vga_get_curs
	add %ax, %di
	add %ax, %di
	mov %ax, %cx # cur_curs

.lp:
	# (chr == null) ? {end}
	mov (%si), %al
	test %al, %al
	jz .end

	cmp $CHR_CR, %al
	je .chr__cr
	cmp $CHR_LF, %al
	je .chr__lf

	mov $VGA_COLOR_NORM, %ah
	mov %ax, %es:(%di)
	add $0x02, %di

	inc %si
	inc %cx # cur_curs
	jmp .lp

.chr__cr:
	mov %cx, %ax # cur_curs
	mov $VGA_COL, %bx
	mov (%bx), %bx # col

	# [cur_curs - (cur_curs % col)]
	xor %dx, %dx
	div %bx
	sub %dx, %cx # cur_curs
	sub %dx, %di
	sub %dx, %di

	inc %si
	jmp .lp

.chr__lf:
	mov (VGA_COL), %ax
	add %ax, %cx
	add %ax, %di
	add %ax, %di

	# (cur_curs >= vga_size) ? {shu} : {lp}
	mov (vga_size), %ax
	cmp %ax, %cx
	jge .shu
	inc %si
	jmp .lp

.shu:
	# init
	push %si # [s.l0:str]
	mov (VGA_COL), %ax
	xor %si, %si
	add %ax, %si
	add %ax, %si
	xor %di, %di

	# cpy
	mov (vga_last_row_off), %cx
	push %ds # [s.s0:vga_seg]
	mov $VGA_SEG, %ax
	mov %ax, %ds
	rep movsw
	pop %ds # [s.s0:vga_seg]
	pop %si # [s.l0:str]

	# clr last line
	mov (VGA_COL), %cx
	mov $((VGA_COLOR_NORM<<0x08)|CHR_SP), %ax
	rep stosw

	mov (vga_last_row_off), %cx # cur_curs
	mov %cx, %di
	add %cx, %di

	inc %si
	jmp .lp

.end:
	push %cx # cur_curs
	call vga_set_curs
	add $0x02, %sp

	pop %bx
	pop %di
	pop %si
	pop %es
	pop %bp
	ret
