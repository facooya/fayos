# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# [Memory] Free

.section .text
.code16
.global mem_free

# mem_free(ub16 seg, ub16 off)
mem_free:
	push %bp
	mov %sp, %bp
	push %si

	mov $mem_bm, %si

	# seg
	mov 0x04(%bp), %ax
	shr $0x0C, %ax
	add %ax, %si
	add %ax, %si

	mov (%si), %cx

	# off
	mov 0x06(%bp), %ax
	shr $0x0C, %ax
	btr %ax, %cx

	mov %cx, (%si)

	pop %si
	pop %bp
	ret
