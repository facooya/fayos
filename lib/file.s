# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025-2026 Facooya and Fanone Facooya

.include "chr.inc"
.include "fs/fs.inc"
.section .text
.code16
.global file_parse_lines

# file_parse_lines(ub16 *seg, ub16 *off, fsp *src)
# <mod: file_linev, file_lines>
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

	mov $file_linev, %di
	xor %ax, %ax
	mov %ax, (%di)
	add $0x02, %di

	mov $file_lines, %si
	xor %ax, %ax
	mov %ax, (%si) # init lines_c
	add $0x02, %si # skip lines_c
	xor %cx, %cx

1:
	# (file_size == 0) {done}
	test %dx, %dx
	jz 99f

	# (chr == CR) ? {line}
	push %ax # [s.l0:linev]
	mov %es:(%bx), %al
	cmp $CHR_CR, %al
	je 2f
	pop %ax # [s.l0:linev]

	inc %ax # linev
	inc %bx
	inc %cx # line_size
	dec %dx # file_size
	jmp 1b

2: # line
	# update line_s
	mov %cx, (%si)
	add $0x02, %si

	# update lines_c
	mov (file_lines), %ax
	inc %ax
	mov %ax, (file_lines)

	pop %ax # [s.l0:linev]
	add $0x02, %ax
	mov %ax, (%di)
	add $0x02, %di

	xor %cx, %cx

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
.global file_lines
.global file_linev
file_lines: .zero 0x100
# lines_c, line_size, line_size, ... (word, word, word, ...)
file_linev: .zero 0x100 # HACK
