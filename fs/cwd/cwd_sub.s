# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# [Current Working Directory] Sub path

.include "chr.s"
.section .text
.code16
.global cwd_sub

# cwd_sub()
cwd_sub:
	push %si
	push %di

	mov $cwd, %si
	xor %ax, %ax
	push %si # (&off)
	push %ax # (&seg)
	call mem_size
	add $0x04, %sp
	add %ax, %si
	sub $0x01, %si

.lp:
	# {end} (chr == SL)
	mov (%si), %al
	cmp $CHR_SL, %al
	jz .end

	xor %al, %al
	mov %al, (%si)

	# {lp}
	sub $0x01, %si
	jmp .lp

.end:
	mov $cwd, %di
	xor %ax, %ax
	push %di
	push %ax
	call mem_size
	add $0x04, %sp

	cmp $0x01, %ax
	je .pass__null

	xor %ax, %ax
	mov %al, (%si)
	add $0x01, %si

.pass__null:
	pop %di
	pop %si
	ret
