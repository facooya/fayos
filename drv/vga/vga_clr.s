# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Clear all

.section .text
.code16
.global vga_clr

# vga_clr()
vga_clr:
	push %es
	push %di
	push %bx

	mov $0xB800, %ax
	mov %ax, %es
	xor %di, %di

	xor %dx, %dx
	mov $0x0484, %bx
	mov (%bx), %dl # row

	mov $0x044A, %bx
	mov (%bx), %ax # col

	mul %dx
	mov %ax, %cx # count

	xor %ax, %ax
	push %ax
	call set_cursor2
	add $0x02, %sp

.lp:
	# (count == 0) ? {end}
	test %cx, %cx
	jz .end

	# clr
	mov $0x20, %al
	mov %al, %es:(%di)
	add $0x01, %di

	# conf
	mov $0x07, %al
	mov %al, %es:(%di)
	add $0x01, %di

	sub $0x01, %cx
	jmp .lp

.end:
	pop %bx
	pop %di
	pop %es
	ret
