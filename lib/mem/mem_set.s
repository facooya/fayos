# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# [Memory] Set

.section .text
.code16
.global mem_set

# mem_set(
# *seg
# *off
# value
# size
# )
mem_set:
	push %bp
	mov %sp, %bp
	push %es
	push %si

	# init
	mov 0x04(%bp), %ax # (*seg)
	mov %ax, %es
	mov 0x06(%bp), %si # (*off)
	mov 0x08(%bp), %dx # (value)
	mov 0x0A(%bp), %cx # (size)

.lp:
	# (size == 0) ? {done}
	test %cx, %cx
	jz .done

	# set
	mov %dl, %es:(%si)

	inc %si
	dec %cx
	jmp .lp

.done:
	pop %si
	pop %es
	pop %bp
	ret
