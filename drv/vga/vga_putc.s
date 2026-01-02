# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya

.include "drv/vga.inc"
.include "chr.inc"
.section .text
.code16
.global vga_putc

# vga_putc()
# <req> al = chr
vga_putc:
	push %es
	push %si
	push %di
	push %bx

	# esc chrs
	cmp $CHR_CR, %al
	je .chr__cr
	cmp $CHR_LF, %al
	je .chr__lf

	# init
	push %ax # [s.0:chr]
	mov $(VGA_MEM>>0x10), %ax
	mov %ax, %es
	mov $(VGA_MEM&0xFFFF), %di

	call vga_get_curs
	mov (vga_size), %cx

	# (cur_curs >= vga_size) ? {shu.chr}
	cmp %cx, %ax
	jge .shu__chr

	add %ax, %di # curs_pos
	add %ax, %di

	inc %ax
	push %ax
	call vga_set_curs
	add $0x02, %sp
	pop %ax # [s.0:chr]

.put:
	# put
	mov $VGA_ATTR_COLOR, %ah
	mov %ax, %es:(%di)
	add $0x02, %di
	jmp .done

.chr__cr:
	call vga_get_curs
	mov %ax, %bx # curs_pos

	mov (VGA_ADDR_COL), %cx

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

	mov (VGA_ADDR_COL), %cx
	add %cx, %bx # curs_pos
	add %cx, %di
	add %cx, %di

	# (curs_pos >= vga_size) ? {shu}
	mov (vga_size), %ax
	cmp %ax, %bx
	jge .shu__lf

	push %bx
	call vga_set_curs
	add $0x02, %sp
	jmp .done

.shu__chr:
	mov (VGA_ADDR_COL), %ax
	xor %si, %si
	add %ax, %si
	add %ax, %si
	xor %di, %di

	mov (vga_last_row_off), %cx
	push %ds # [s.s0:vga_seg]
	mov $(VGA_MEM>>0x10), %ax
	mov %ax, %ds
	rep movsw
	pop %ds # [s.s0:vga_seg]

	# clr line
	mov (VGA_ADDR_COL), %cx
	mov $((VGA_ATTR_COLOR<<0x08)|CHR_SP), %ax
	rep stosw

	mov (vga_last_row_off), %ax
	mov %ax, %di
	add %ax, %di

	inc %ax
	push %ax
	call vga_set_curs
	add $0x02, %sp

	pop %ax # [s.0:chr]
	jmp .put

.shu__lf:
	# init
	mov (VGA_ADDR_COL), %ax
	sub %ax, %bx # curs_pos
	xor %si, %si
	add %ax, %si
	add %ax, %si
	xor %di, %di

	# cpy
	mov (vga_last_row_off), %cx
	push %ds # [s.s0:vga_seg]
	mov $(VGA_MEM>>0x10), %ax
	mov %ax, %es
	mov %ax, %ds
	rep movsw
	pop %ds # [s.s0:vga_seg]

	# clr line
	mov (VGA_ADDR_COL), %cx
	mov $((VGA_ATTR_COLOR<<0x08)|CHR_SP), %ax
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
	pop %si
	pop %es
	ret
