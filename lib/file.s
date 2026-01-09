# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025-2026 Facooya and Fanone Facooya

.include "chr.inc"
.include "fs/fs.inc"
.section .text
.code16
.global file_parse_lines

# file_parse_lines(ub16 *seg, ub16 *off, fsp *src)
# <mod: file_line_cv>
file_parse_lines:
	push %bp
	mov %sp, %bp
	push %es
	push %si
	push %di
	push %bx

	mov 0x04(%bp), %ax
	mov %ax, %es
	mov 0x06(%bp), %bx
	mov 0x08(%bp), %si # (fsp *src)
	mov FSP_OFF_F_SIZE(%si), %dx

	mov $file_line_cv, %di
	xor %ax, %ax
	mov %ax, (%di) # line_c

	xor %cx, %cx # line_v
	add $0x02, %di
	mov %cx, (%di) # line_v[0] # HACK
	add $0x02, %di # skip line_v[0]

1:
	# (file_size == 0) ? {done}
	test %dx, %dx
	jz 99f

	# (chr == CR) ? {line}
	mov %es:(%bx), %al
	cmp $CHR_CR, %al
	je 2f

	inc %cx # line_v
	inc %bx
	dec %dx # file_size
	jmp 1b

2: # line
	# update lines_c
	mov (file_line_cv), %ax
	inc %ax
	mov %ax, (file_line_cv)

	# store line_v
	add $0x02, %cx # skip size cr, lf
	mov %cx, (%di)
	add $0x02, %di

	# skip cr, lf
	add $0x02, %bx
	sub $0x02, %dx # file_size
	jmp 1b

99:
	pop %bx
	pop %di
	pop %si
	pop %es
	pop %bp
	ret

.section .data
.global file_line_cv
file_line_cv: .zero 0x100
