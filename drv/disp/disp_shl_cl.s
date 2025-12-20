# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya

.section .text
.code16
.global disp_shl_cl

# disp_shl_cl(ub8 *data)
disp_shl_cl:
	push %bp
	mov %sp, %bp
	push %si
	push %di

	mov 0x04(%bp), %si # (*data)

	# cpy
	mov %si, %di
	dec %di

	# { size
	push %es # [s.f0:extra]
	xor %ax, %ax
	mov %ax, %es

	push %di
	push %es
	call mem_size
	add $0x04, %sp
	pop %es # [s.f0:extra]

	mov %ax, %cx # size
	# }

.lp:
	# left shift
	mov (%di), %al # data
	mov %al, -0x01(%di)

	# (str.len == 0) ? {end}
	test %cx, %cx
	jz .end

	inc %di # data
	dec %cx # size
	jmp .lp

.end:
	# left curs
	call vga_get_curs
	dec %ax
	push %ax # [s.1:curs_pos]
	push %ax
	call vga_set_curs
	add $0x02, %sp

	push %si
	call vga_puts
	add $0x02, %sp

	# overwrite
	mov $CHR_SP, %al
	call vga_putc

	# left curs
	pop %ax # [s.1:curs_pos]
	push %ax
	call vga_set_curs
	add $0x02, %sp

.done:
	pop %di
	pop %si
	pop %bp
	ret
