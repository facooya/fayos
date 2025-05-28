# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Regular Expression

.include "chr.s"
.section .text
.code16
.global re_alpha

# re_alpha(&chr)
re_alpha:
	push %bp
	mov %sp, %bp
	push %si

	mov 0x04(%bp), %si
	mov (%si), %al

	cmp $CHR_UC_A, %al
	jb .false
	cmp $CHR_UC_Z, %al
	jbe .true
	cmp $CHR_LC_A, %al
	jb .false
	cmp $CHR_LC_Z, %al
	jbe .true

.true:
	xor %ax, %ax
	jmp .done

.false:
	mov $0x01, %ax

.done:
	pop %si
	pop %bp
	ret
