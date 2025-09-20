# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Viedo shift up by line

.section .text
.code16
.global vga_shu

# vga_shu()
vga_shu:
	push %es
	push %si
	push %di
	push %bx

	mov $0x044A, %bx
	mov (%bx), %cx
	xor %ax, %ax
	mov $0x0484, %bx
	mov (%bx), %al
	mul %cx
	mov %ax, %cx # cpy_cnt

	push %cx # [s.f0:cpy_cnt]
	push %ax
	call vga_set_curs
	add $0x02, %sp
	pop %cx # [s.f0:cpy_cnt]

	mov $0xB800, %ax
	mov %ax, %es
	xor %si, %si
	xor %di, %di

	# ignore top row
	mov $0x044A, %bx
	mov (%bx), %ax
	add %ax, %si
	add %ax, %si

.cpy__lp:
	# (cpy_cnt == 0) : {end}
	test %cx, %cx
	jz .end

	mov %es:(%si), %ax
	mov %ax, %es:(%di)

	add $0x02, %si
	add $0x02, %di
	sub $0x01, %cx
	jmp .cpy__lp

.end:
	call vga_clr_line

.done:
	pop %bx
	pop %di
	pop %si
	pop %es
	ret
