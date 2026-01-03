# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya

.include "drv/vga.inc"
.include "chr.inc"
.section .text
.code16
.global vga_outs

# vga_outs(*str)
vga_outs:
	push %bp
	mov %sp, %bp
	push %es
	push %si
	push %di
	push %bx

	mov 0x04(%bp), %si

	mov $(VGA_MEM>>0x10), %ax
	mov %ax, %es
	mov $(VGA_MEM&0xFFFF), %di

	call vga_get_curs
	add %ax, %di
	add %ax, %di
	mov %ax, %cx # cur_curs
	mov (vga_size), %bx

.lp:
	# (chr == null) ? {done}
	mov (%si), %al
	test %al, %al
	jz .done

	cmp $CHR_CR, %al
	je .chr__cr
	cmp $CHR_LF, %al
	je .chr__lf

	# (curs_pos >= vga_size) ? {shu.in}
	cmp %bx, %cx
	jge .shu__in

.lp__put:
	mov $VGA_ATTR_COLOR, %ah
	mov %ax, %es:(%di)
	add $0x02, %di

	inc %si
	inc %cx # cur_curs
	jmp .lp

.chr__cr:
	push %bx # [s.l0:vga_size]
	mov %cx, %ax # cur_curs
	mov (VGA_ADDR_COL), %bx # col

	# [cur_curs - (cur_curs % col)]
	xor %dx, %dx
	div %bx
	sub %dx, %cx # cur_curs
	sub %dx, %di
	sub %dx, %di

	pop %bx # [s.l0:vga_size]
	inc %si
	jmp .lp

.chr__lf:
	mov (VGA_ADDR_COL), %ax
	add %ax, %cx
	add %ax, %di
	add %ax, %di

	# (cur_curs >= vga_size) ? {shu} : {lp}
	mov (vga_size), %ax
	cmp %ax, %cx
	jge .shu
	inc %si
	jmp .lp

.shu__in:
	push %si # [s.l1:str]
	push %ax # [s.l0:chr]

	# init
	mov (VGA_ADDR_COL), %ax
	xor %si, %si
	add %ax, %si
	add %ax, %si
	xor %di, %di

	# cpy
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

	mov (vga_last_row_off), %cx # curs_pos
	mov %cx, %di
	add %cx, %di # vga_off

	pop %ax # [s.l0:chr]
	pop %si # [s.l1:str]
	jmp .lp__put

.shu:
	# init
	push %si # [s.l0:str]
	mov (VGA_ADDR_COL), %ax
	sub %ax, %cx
	mov %cx, %dx # curs_pos
	xor %si, %si
	add %ax, %si
	add %ax, %si
	xor %di, %di

	# cpy
	mov (vga_last_row_off), %cx
	push %ds # [s.s0:vga_seg]
	mov $(VGA_MEM>>0x10), %ax
	mov %ax, %ds
	rep movsw
	pop %ds # [s.s0:vga_seg]
	pop %si # [s.l0:str]

	# clr last line
	mov (VGA_ADDR_COL), %cx
	mov $((VGA_ATTR_COLOR<<0x08)|CHR_SP), %ax
	rep stosw

	# set
	mov %dx, %cx # curs_pos
	mov %dx, %di
	add %dx, %di

	inc %si
	jmp .lp

.done:
	push %cx # cur_curs
	call vga_set_curs
	add $0x02, %sp

	pop %bx
	pop %di
	pop %si
	pop %es
	pop %bp
	ret
