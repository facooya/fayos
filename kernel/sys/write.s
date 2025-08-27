# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Write

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

	mov $0xB000, %ax
	mov %ax, %es
	mov $0x8000, %di
	mov 0x04(%bp), %si

.lp:
	mov (%si), %al
	cmp $0x0A, %al
	je .nl
	test %al, %al
	jz .end

	mov %al, %es:(%di)
	add $0x01, %si
	add $0x01, %di

	mov $0x07, %al
	mov %al, %es:(%di)
	add $0x01, %di

	mov (%si), %al
	test %al, %al
	jz .end
	jmp .lp

.nl:
	mov %di, %ax
	and $0x00FF, %ax
	sub %ax, %di
	add $0xA0, %di

	add $0x01, %si
	jmp .lp

.end:
	pop %bp
	pop %di
	pop %si
	pop %es
	ret
