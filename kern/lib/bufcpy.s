# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Buffer copy

.section .text
.code16
.global bufcpy

# bufcpy(
# *dest_buf,
# *src_buf
# )
# <req>
# struct buf {
# uint16_t len;
# uint8_t data[];
# };
bufcpy:
	push %bp
	mov %sp, %bp
	push %si
	push %di

	# init
	mov 0x06(%bp), %si
	mov 0x04(%bp), %di

	# cpy len
	mov (%si), %cx
	mov %cx, (%di)

	# skip len
	add $0x02, %si
	add $0x02, %di

	xor %ax, %ax # seg
	push %cx
	push %si
	push %ax
	push %di
	push %ax
	call memcpy
	add $0x0A, %sp

.done:
	pop %di
	pop %si
	pop %bp
	ret
