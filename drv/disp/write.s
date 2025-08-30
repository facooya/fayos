# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Display write

.section .text
.code16
.global write

# write(*str)
write:
	push %bp
	mov %sp, %bp
	push %es
	push %si
	push %di

	# TODO: get display size

	mov $0xB000, %ax
	mov %ax, %es
	mov $0x8000, %di
	mov 0x04(%bp), %si

.lp:
	# (chr == nl) ? {nl}
	mov (%si), %al
	cmp $0x0A, %al
	je .nl

	# (chr == null) ? {end}
	test %al, %al
	jz .end

	# write
	mov %al, %es:(%di)
	add $0x01, %si
	add $0x01, %di

	# conf
	mov $0x07, %al
	mov %al, %es:(%di)
	add $0x01, %di

	# (chr == null) ? {end} : {lp}
	mov (%si), %al
	test %al, %al
	jz .end
	jmp .lp

.nl:
	# get fst col
	mov %di, %ax
	and $0x00FF, %ax
	sub %ax, %di

	# nl (80*2)
	add $0xA0, %di

	add $0x01, %si
	jmp .lp

.end:
	pop %bp
	pop %di
	pop %si
	pop %es
	ret
