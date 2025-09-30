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

	add $0x01, %ax
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

	# vga col
	mov $VGA_COL, %bx
	mov (%bx), %cx # col
	mov %ax, %bx # curs_pos

	# [curs_pos - (curs_pos % col)]
	xor %dx, %dx
	div %cx
	sub %dx, %bx

	push %bx
	call vga_set_curs
	add $0x02, %sp
	jmp .done

.chr__lf:
	call vga_get_curs

	# vga col
	mov $VGA_COL, %bx
	mov (%bx), %cx # col
	mov %ax, %bx # curs_pos

	# [curs_pos - (curs_pos % col) + col]
	xor %dx, %dx
	div %cx
	sub %dx, %bx
	add %cx, %bx

	# calc max_curs
	push %bx # [s.c0:curs_pos]
	mov $VGA_COL, %bx
	mov (%bx), %cx
	xor %ax, %ax
	mov $VGA_ROW, %bx
	mov (%bx), %al
	add $0x01, %al
	mul %cx
	pop %bx # [s.c0:curs_pos]

	# (curs_pos >= max_curs) : {call.vga_shu}
	cmp %ax, %bx
	jge .call__vga_shu

	push %bx
	call vga_set_curs
	add $0x02, %sp
	jmp .done

.done:
	pop %bx
	pop %di
	pop %es
	ret

.call__vga_shu:
	call vga_shu
	jmp .done
