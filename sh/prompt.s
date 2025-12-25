# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya

.include "chr.s"
.section .text
.code16
.global ps1_build

# [public] ps1_build()
# <req> cwd
ps1_build:
	push %si
	push %di

	mov $_ps1_name, %si
	mov $ps1, %di

10: # zero
1:
	# (*ps1[i] == null) ? {end}
	mov (%di), %al
	test %al, %al
	jz 9f

	xor %al, %al
	mov %al, (%di)

	inc %di
	jmp 1b

9:
20: # name
	mov $ps1, %di

1:
	# (chr == null) ? {end}
	mov (%si), %al
	test %al, %al
	jz 9f

	mov %al, (%di)

	inc %si
	inc %di
	jmp 1b

9:
	mov $CHR_COL, %al
	mov %al, (%di)
	inc %di

30: # path
	mov $cwd, %si

1:
	mov (%si), %al
	test %al, %al
	jz 9f

	mov %al, (%di)

	inc %si
	inc %di
	jmp 1b

9:
90:
	mov $CHR_HS, %al
	mov %al, (%di)
	inc %di

	mov $CHR_SP, %al
	mov %al, (%di)
	inc %di

	pop %di
	pop %si
	ret

# [data]
.section .data
.global ps1
ps1: .zero 0x110
_ps1_name: .asciz "fayos"
