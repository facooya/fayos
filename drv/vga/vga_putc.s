# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Video put character

.include "drv/vga.s"
.include "chr.s"
.section .text
.code16
.global vga_putc

# vga_putc()
# <req> al = chr
vga_putc:
	push %es
	push %di
	push %bx

	# esc chrs
	cmp $CHR_CR, %al
	je .chr__cr
	cmp $CHR_LF, %al
	je .chr__lf

	# init
	push %ax # [s.0:chr]
	mov $VGA_SEG, %ax
	mov %ax, %es
	xor %di, %di

	call vga_get_curs
	add %ax, %di # curs_pos
	add %ax, %di

	inc %ax
	push %ax
	call vga_set_curs
	add $0x02, %sp
	pop %ax # [s.0:chr]

	# out
	mov $VGA_COLOR_NORM, %ah
	mov %ax, %es:(%di)
	add $0x02, %di
	jmp .done

.chr__cr:
	call vga_get_curs
	mov %ax, %bx # curs_pos

	mov (VGA_COL), %cx # col

	# [curs_pos - (curs_pos % col)]
	xor %dx, %dx
	div %cx
	sub %dx, %bx
	xor %di, %di
	add %bx, %di
	add %bx, %di

	push %bx
	call vga_set_curs
	add $0x02, %sp
	jmp .done

.chr__lf:
	call vga_get_curs
	mov %ax, %bx # cur_curs_pos

	mov (VGA_COL), %cx # col
	add %cx, %bx # curs_pos
	add %cx, %di
	add %cx, %di

	# (curs_pos >= vga_size) ? {shu}
	mov (vga_size), %ax
	cmp %ax, %bx
	jge .shu

	push %bx
	call vga_set_curs
	add $0x02, %sp
	jmp .done

.shu:
	# init
	push %si
	mov (VGA_COL), %ax
	sub %ax, %bx # curs_pos
	xor %si, %si
	add %ax, %si
	add %ax, %si
	xor %di, %di

	# cpy
	mov (vga_last_row_off), %cx
	push %ds
	mov $VGA_SEG, %ax
	mov %ax, %es
	mov %ax, %ds
	rep movsw
	pop %ds
	pop %si

	# clr line
	mov (VGA_COL), %cx
	mov $((VGA_COLOR_NORM<<0x08)|CHR_SP), %ax
	rep stosw

	# set
	mov %bx, %di
	add %bx, %di

	push %bx
	call vga_set_curs
	add $0x02, %sp
	jmp .done

.done:
	pop %bx
	pop %di
	pop %es
	ret
