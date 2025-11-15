# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# [Prompt String 1] Build prompt string

.include "chr.s"
.section .text
.code16
.global ps1_build

# ps1_build()
ps1_build:
	push %si
	push %di

	mov $ps1_name, %si
	mov $ps1, %di

.zero__lp:
	# (*ps1[i] == null) ? {end}
	mov (%di), %al
	test %al, %al
	jz .zero__end

	xor %al, %al
	mov %al, (%di)

	inc %di
	jmp .zero__lp

.zero__end:
	mov $ps1, %di

.name__lp:
	# (chr == null) ? {end}
	mov (%si), %al
	test %al, %al
	jz .name__end

	mov %al, (%di)

	inc %si
	inc %di
	jmp .name__lp

.name__end:
	mov $CHR_COL, %al
	mov %al, (%di)
	inc %di

	mov $cwd, %si

.path__lp:
	mov (%si), %al
	test %al, %al
	jz .path__end

	mov %al, (%di)

	inc %si
	inc %di
	jmp .path__lp

.path__end:
	mov $CHR_HS, %al
	mov %al, (%di)
	inc %di

	mov $CHR_SP, %al
	mov %al, (%di)
	inc %di

	pop %di
	pop %si
	ret
