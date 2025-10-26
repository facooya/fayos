# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# [Memory] Copy

.section .text
.code16
.global mem_cpy

# mem_cpy(
# *d_seg,
# *d_off,
# *s_seg,
# *s_off,
# size
# )
mem_cpy:
	push %bp
	mov %sp, %bp
	push %es
	push %si
	push %di

	# init
	mov 0x0A(%bp), %si # (*s_off)
	mov 0x06(%bp), %di # (*d_off)
	mov 0x0C(%bp), %cx # (size)

.lp:
	# (size == 0) ? {done}
	test %cx, %cx
	jz .done

	# {{{ cpy
	mov 0x08(%bp), %ax # (*s_seg)
	mov %ax, %es
	mov %es:(%si), %dl

	mov 0x04(%bp), %ax # (*d_seg)
	mov %ax, %es
	mov %dl, %es:(%di)
	# }}}

	inc %si
	inc %di
	dec %cx
	jmp .lp

.done:
	pop %di
	pop %si
	pop %es
	pop %bp
	ret
