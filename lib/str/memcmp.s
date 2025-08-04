# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Memory compare

.section .text
.code16
.global memcmp

# memcmp(
# *src_seg
# *src_off
# *dst_seg
# *dst_off
# number
# )
# <ret> ax = 0:true, 1:false
memcmp:
	push %bp
	mov %sp, %bp
	push %es
	push %si
	push %di

	# init
	mov 0x06(%bp), %si # *src_off
	mov 0x0A(%bp), %di # *dst_off
	mov 0x0C(%bp), %cx # number

.lp:
	# load
	mov 0x04(%bp), %ax
	mov %ax, %es
	mov %es:(%si), %dh # *src

	mov 0x08(%bp), %ax
	mov %ax, %es
	mov %es:(%di), %dl # *dst

	# cond: 0 ? e
	test %cx, %cx
	jz .e

	# cond: != ? ne
	cmp %dh, %dl
	jne .ne

	# step
	add $0x01, %si
	add $0x01, %di
	sub $0x01, %cx
	jmp .lp

.e:
	xor %ax, %ax
	jmp .done

.ne:
	mov $0x01, %ax
	jmp .done

.done:
	pop %di
	pop %si
	pop %es
	pop %bp
	ret
