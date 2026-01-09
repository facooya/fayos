# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025-2026 Facooya and Fanone Facooya

.section .text
.code16
.global mem_size
.global mem_set
.global mem_cpy
.global mem_cmp

# mem_size(ub16 *seg, ub16 *off)
# <ret: ax = size>
mem_size:
	push %bp
	mov %sp, %bp
	push %es
	push %bx

	mov 0x04(%bp), %ax # (*seg)
	mov %ax, %es
	mov 0x06(%bp), %bx # (*off)
	xor %cx, %cx # size

1:
	# (chr == null) ? {done}
	mov %es:(%bx), %al
	test %al, %al
	jz 90f

	inc %bx
	inc %cx # size
	jmp 1b

90:
	mov %cx, %ax # <ret:size>

	pop %bx
	pop %es
	pop %bp
	ret

# mem_set(
# ub16 *seg
# ub16 *off
# ub8 value
# ub16 size
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

1:
	# (size == 0) ? {done}
	test %cx, %cx
	jz 99f

	# set
	mov %dl, %es:(%si)

	inc %si
	dec %cx
	jmp 1b

99:
	pop %si
	pop %es
	pop %bp
	ret

# mem_cpy(
# ub16 *d_seg,
# ub16 *d_off,
# ub16 *s_seg,
# ub16 *s_off,
# ub16 size
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

1:
	# (size == 0) ? {done}
	test %cx, %cx
	jz 99f

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
	jmp 1b

99:
	pop %di
	pop %si
	pop %es
	pop %bp
	ret

# mem_cmp(
# ub16 *d_seg
# ub16 *d_off
# ub16 *s_seg
# ub16 *s_off
# ub16 size
# )
# <ret: ax = {0:true, 1:false}>
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

1:
	# (size == 0) ? {done.e}
	test %cx, %cx
	jz 91f

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
	jne 92f

	inc %si
	inc %di
	dec %cx
	jmp 1b

91: # equal
	xor %ax, %ax
	jmp 99f

92: # not equal
	mov $0x01, %ax
	jmp 99f

99:
	pop %di
	pop %si
	pop %es
	pop %bp
	ret
