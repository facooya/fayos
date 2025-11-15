# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# [Current Working Directory] Add path

.include "chr.s"
.section .text
.code16
.global cwd_add

# cwd_add(*seg, *off, size)
cwd_add:
	push %bp
	mov %sp, %bp
	push %es
	push %si
	push %di

	mov 0x04(%bp), %es # (*seg)
	mov 0x06(%bp), %si # (*off)
	mov $cwd, %di

	mov (%si), %al
	cmp $CHR_SL, %al
	je .done

	xor %ax, %ax
	push %di # (&off)
	push %ax # (&seg)
	call mem_size
	add $0x04, %sp
	add %ax, %di

	# (*(cwd--) == SL) ? {pass}
	mov -0x01(%di), %al
	cmp $CHR_SL, %al
	je .pass

	mov $CHR_SL, %al
	mov %al, (%di)
	inc %di

.pass:
	# mem cpy
	mov 0x08(%bp), %cx # size
	xor %ax, %ax
	push %cx # (size)
	push %si # (&s_off)
	push %es # (&s_seg)
	push %di # (&d_off)
	push %ax # (&d_seg)
	call mem_cpy
	add $0x0A, %sp

	# store last null
	mov 0x08(%bp), %ax # (size)
	add %ax, %di
	xor %ax, %ax
	mov %al, (%di)
	inc %di

.done:
	pop %di
	pop %si
	pop %es
	pop %bp
	ret
