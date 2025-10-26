# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Buffer set zero

.section .text
.code16
.global bufzero

# bufzero(
# *buf
# )
# <req>
# struct buf {
# uint16_t len;
# uint8_t data[];
# };
bufzero:
	push %bp
	mov %sp, %bp
	push %si

	# init
	mov 0x04(%bp), %si
	mov (%si), %cx
	xor %ax, %ax
	mov %ax, (%si)
	add $0x02, %si

	xor %ax, %ax
	push %cx
	push %ax
	push %si
	push %ax
	call mem_set
	add $0x08, %sp

	pop %si
	pop %bp
	ret
