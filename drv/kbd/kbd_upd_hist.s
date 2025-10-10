# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Update history

.include "chr.s"
.section .text
.code16
.global kbd_upd_hist

# kbd_upd_hist()
# <req> hist_idx
kbd_upd_hist:
	push %di
	push %bx

	mov $file_lines, %di
	mov (%di), %cx # linec
	add $0x02, %di
	mov (hist_idx), %ax
	add %ax, %di
	add %ax, %di
	mov (%di), %dx # line_size

	mov $raw_buf, %si
	mov %dx, (%si)
	add $0x02, %si

	mov (hist_idx), %ax
	mov $file_linev, %di
	add %ax, %di
	add %ax, %di
	mov (%di), %dx # tgt_line
	add %dx, %bx # hist_file

.raw:
	mov (raw_buf), %cx

.raw__lp:
	# (len == 0) ? {disp}
	test %cx, %cx
	jz .disp

	mov %es:(%bx), %al
	mov %al, (%si)

	inc %si
	inc %bx
	dec %cx
	jmp .raw__lp

.disp:
	mov $raw_buf, %si
	mov (%si), %cx
	add $0x02, %si

	push %si
	push %cx
	call vga_putls
	add $0x04, %sp

	mov (cursor), %ax
	add %ax, %cx
	mov %cx, (cursor+0x02)
	jmp .done

.done:
	pop %bx
	pop %di
	ret
