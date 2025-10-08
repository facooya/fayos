# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# History line

.section .text
.code16
.global _kbd_hist_line

# _kbd_hist_line()
# <req> es = segment
# <ret> ax = mem_off
# <ret> dx = hist_line_size
# <ret> *si = raw_buf
_kbd_hist_line:
	push %di
	push %bx

	# {{{ calc
	# lines_c - hist_stack = hist_line
	# &file_lines + 2 = &line_size
	# &line_size + (hist_line * 2) = hist_line_size
	mov $file_lines, %di
	mov (%di), %cx # lines_c
	add $0x02, %di
	mov (hist_stack), %ax
	sub %ax, %cx # hist_line
	sub $0x01, %cx # hist_line_i

	add %cx, %di
	add %cx, %di
	mov (%di), %dx # hist_line_size
	# }}}

	mov $file_lines, %di
	add $0x02, %di # skip lines_c

.calc__lp:
	# {end} (hist_line_i == 0)
	test %cx, %cx
	jz .raw

	mov (%di), %ax
	add %ax, %bx
	add $0x02, %bx # skip cr,lf

	# {lp}
	add $0x02, %di
	sub $0x01, %cx
	jmp .calc__lp

.raw:
	mov $raw_buf, %si
	mov %dx, (%si) # hist_line_size
	add $0x02, %si # skip buf.len

.raw__lp:
	# {end} (size == 0)
	test %dx, %dx
	jz .disp

	mov %es:(%bx), %al
	mov %al, (%si)

	# {lp}
	add $0x01, %si # buf.data
	add $0x01, %bx # mem
	sub $0x01, %dx # size
	jmp .raw__lp

.disp:
	mov $raw_buf, %si
	mov (%si), %cx # buf.len
	add $0x02, %si # skip len

	push %si
	push %cx
	call vga_putls
	add $0x04, %sp

	mov (cursor), %ax # cursor.min
	add %ax, %cx
	mov %cx, (cursor+0x02) # update cursor.max
	jmp .done

.done:
	pop %bx
	pop %di
	ret
