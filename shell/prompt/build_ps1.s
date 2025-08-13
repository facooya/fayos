# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Build prompt string

.include "chr.s"
.section .data
.ps1_path: .zero 0x100
.ps1_name: .asciz "fayos"

.section .text
.code16
.global build_ps1

# build_ps1()
build_ps1:
	push %si
	push %di

	mov $.ps1_name, %si
	mov $ps1, %di

.name__lp:
	# {end} (chr == null)
	mov (%si), %al
	test %al, %al
	jz .name__end

	mov %al, (%di)

	# {lp}
	add $0x01, %si
	add $0x01, %di
	jmp .name__lp

.name__end:
	mov $CHR_COL, %al
	mov %al, (%di)
	add $0x01, %di

	mov $CHR_SL, %al
	mov %al, (%di)
	add $0x01, %di

.path__lp:
	# jmp .path__lp

.path__end:
	mov $CHR_HS, %al
	mov %al, (%di)
	add $0x01, %di

	mov $CHR_SP, %al
	mov %al, (%di)
	add $0x01, %di

	pop %di
	pop %si
	ret
