# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# [Memory] Compare

.section .text
.code16
.global mem_cmp

# mem_cmp(
# *d_seg
# *d_off
# *s_seg
# *s_off
# size
# )
# <ret> ax = {0:true, 1:false}
mem_cmp:
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
	# (size == 0) ? {done.e}
	test %cx, %cx
	jz .e

	# { get chr
	mov 0x08(%bp), %ax # (*s_seg)
	mov %ax, %es
	mov %es:(%si), %dh # s_chr

	mov 0x04(%bp), %ax # (*d_seg)
	mov %ax, %es
	mov %es:(%di), %dl # d_chr
	# }

	# (s_chr != d_chr) ? {done.ne}
	cmp %dh, %dl
	jne .ne

	inc %si
	inc %di
	dec %cx
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
