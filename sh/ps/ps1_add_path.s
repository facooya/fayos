# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# [Prompt String 1] Add directory name at path

.include "chr.s"
.section .text
.code16
.global ps1_add_path

# ps1_add_path(*seg, *off, num)
ps1_add_path:
	push %bp
	mov %sp, %bp
	push %es
	push %si
	push %di

	mov 0x04(%bp), %es
	mov 0x06(%bp), %si
	mov $ps1_path, %di

	mov (%si), %al
	cmp $CHR_SL, %al
	je .done

	push %di
	xor %ax, %ax
	push %ax
	call mem_size
	add $0x04, %sp
	add %ax, %di

	# {pass} (*(ps1_path--) == SL)
	mov -0x01(%di), %al
	cmp $CHR_SL, %al
	je .pass

	mov $CHR_SL, %al
	mov %al, (%di)
	add $0x01, %di

.pass:
	# mem cpy
	mov 0x08(%bp), %cx # num
	push %cx
	push %si
	push %es
	push %di
	xor %ax, %ax
	push %ax
	call mem_cpy
	add $0x0A, %sp

	# store last null
	mov 0x08(%bp), %ax
	add %ax, %di
	xor %ax, %ax
	mov %al, (%di)
	add $0x01, %di

.done:
	pop %di
	pop %si
	pop %es
	pop %bp
	ret
