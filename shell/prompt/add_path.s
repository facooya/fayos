# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Add directory name at path

.include "chr.s"
.section .text
.code16
.global add_path

# add_path(*dir_name)
add_path:
	push %bp
	mov %sp, %bp
	push %si
	push %di

	mov 0x04(%bp), %si
	mov $path, %di

	push %di
	xor %ax, %ax
	push %ax
	call strlen
	add $0x04, %sp
	add %ax, %di

	# {lp} (*(path--) = SL)
	mov -0x01(%di), %al
	cmp $CHR_SL, %al
	je .lp

	mov $CHR_SL, %al
	mov %al, (%di)
	add $0x01, %di

.lp:
	# {end} (chr == null)
	mov (%si), %al
	test %al, %al
	jz .end

	mov %al, (%di)

	# {lp}
	add $0x01, %si
	add $0x01, %di
	jmp .lp

.end:
	xor %ax, %ax
	mov %al, (%di)
	add $0x01, %di

	pop %di
	pop %si
	pop %bp
	ret
