# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Free memory

.section .text
.code16
.global free_mem

# free_mem()
# <req> memnum
free_mem:
	push %si

	mov (memnum), %ax
	xor %dx, %dx
	mov $0x08, %cx
	div %cx # ax /= 0x08, dx %= 0x08

	mov $mem_bitmap, %si
	add %ax, %si

	# free bitmap
	xor %ax, %ax # init
	mov (%si), %al
	btr %dx, %ax
	mov %al, (%si)

	pop %si
	ret
