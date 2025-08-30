# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Read key

.section .text
.code16
.global read_key

# read_key()
read_key:
	push %si
	push %di

	mov $keymap, %si
	mov %si, %di
	xor %ax, %ax

.lp:
	call ._obf
	in $0x60, %al

	# (kd == end_key) ? {lp}
	cmp $0xF0, %al
	je .lp

	xor %cx, %cx
	add %al, %cl
	add %cx, %di

	mov (%di), %al
	call outc

	xor %ax, %ax
	mov %si, %di
	jmp .lp

	pop %di
	pop %si
	ret

._obf:
	in $0x64, %al
	test $0x01, %al
	jz ._obf
	ret
