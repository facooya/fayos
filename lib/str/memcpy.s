# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Memory copy

.section .text
.code16
.global memcpy

# memcpy(
# *dst_seg
# *dst_off
# *src_seg
# *src_off
# number
# )
memcpy:
	push %bp
	mov %sp, %bp
	push %es
	push %si
	push %di

	# init
	mov 0x0A(%bp), %si # *src_off
	mov 0x06(%bp), %di # *dst_off
	mov 0x0C(%bp), %cx # number

.lp:
	# {{{ cpy
	mov 0x08(%bp), %ax
	mov %ax, %es
	mov %es:(%si), %dl

	mov 0x04(%bp), %ax
	mov %ax, %es
	mov %dl, %es:(%di)
	# }}}

	# {end} (size == 0)
	test %cx, %cx
	jz .done

	# {lp}
	add $0x01, %si
	add $0x01, %di
	sub $0x01, %cx
	jmp .lp

.done:
	pop %di
	pop %si
	pop %es
	pop %bp
	ret
