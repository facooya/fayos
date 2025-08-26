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
	mov %al, %es:(%di)
	add $0x01, %si
	add $0x01, %di

	mov $0x07, %al
	mov %al, %es:(%di)
	add $0x01, %di

	mov (%si), %al
	test %al, %al
	jnz .lp

	pop %bp
	pop %di
	pop %si
	pop %es
	ret
