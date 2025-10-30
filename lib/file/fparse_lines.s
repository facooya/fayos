# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Parse file lines and each line size except cr/lf

.include "chr.s"
.include "fs/fs.s"
.include "fs/inode.s"
.section .data
.global file_lines
.global file_linev
file_lines: .zero 0x100
# lines_c, line_size, line_size, ... (word, word, word, ...)
file_linev: .zero 0x100 # HACK

.section .text
.code16
.global fparse_lines

# fparse_lines(*seg, *off, fsp *src)
# <ret> file_lines
fparse_lines:
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
	mov FSP_OFF_IND_FILE_SIZE(%si), %dx

	mov $file_linev, %di
	xor %ax, %ax
	mov %ax, (%di)
	add $0x02, %di

	mov $file_lines, %si
	xor %ax, %ax
	mov %ax, (%si) # init lines_c
	add $0x02, %si # skip lines_c
	xor %cx, %cx

.lp:
	# {end} (file_size == 0)
	test %dx, %dx
	jz .end

	# {line} (chr == CR)
	push %ax # [s.l0:linev]
	mov %es:(%bx), %al
	cmp $CHR_CR, %al
	je .line
	pop %ax # [s.l0:linev]

	# {lp}
	inc %ax # linev
	add $0x01, %bx
	add $0x01, %cx # line_size
	sub $0x01, %dx # file_size
	jmp .lp

.line:
	# update line_s
	mov %cx, (%si)
	add $0x02, %si

	# update lines_c
	mov (file_lines), %ax
	add $0x01, %ax
	mov %ax, (file_lines)

	pop %ax # [s.l0:linev]
	add $0x02, %ax
	mov %ax, (%di)
	add $0x02, %di

	xor %cx, %cx

	# {lp} skip cr, lf
	add $0x02, %bx
	sub $0x02, %dx # file_size
	jmp .lp

.end:
	pop %bx
	pop %di
	pop %si
	pop %es
	pop %bp
	ret
