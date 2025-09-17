# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Clear current cursor line

.section .text
.code16
.global vga_clr_line

# vga_clr_line()
vga_clr_line:
	push %es
	push %di
	push %bx

	mov $0xB800, %ax
	mov %ax, %es
	xor %di, %di

	call get_cursor2

	# get column
	mov $0x044A, %bx
	mov (%bx), %cx
	push %cx # [s.0:col]

	# get current line [line_idx=curs_pos/col]
	xor %dx, %dx
	div %cx
	mov %ax, %cx # line_idx

	# [line_start_pos=col*line_idx]
	pop %ax # [s.0:col]
	mul %cx
	add %ax, %di
	add %ax, %di

	push %ax
	call set_cursor2
	add $0x02, %sp

	# get col
	mov $0x044A, %bx
	mov (%bx), %cx

.lp:
	# (count == 0) ? {end}
	test %cx, %cx
	jz .done

	# write
	mov $0x20, %al # space
	mov %al, %es:(%di)
	add $0x01, %di

	# conf
	mov $0x07, %al
	mov %al, %es:(%di)
	add $0x01, %di

	sub $0x01, %cx
	jmp .lp

.done:
	pop %bx
	pop %di
	pop %es
	ret
