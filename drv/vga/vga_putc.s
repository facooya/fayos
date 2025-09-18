# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Video put character

.section .text
.code16
.global vga_putc

# vga_putc()
# <req> al = chr
vga_putc:
	push %es
	push %di
	push %dx

	# init
	push %ax # [s.0:chr]
	mov $0xB800, %ax
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
	mov %al, %es:(%di)
	add $0x01, %di

	# conf
	mov $0x07, %al
	mov %al, %es:(%di)
	add $0x01, %di

	pop %dx
	pop %di
	pop %es
	ret
