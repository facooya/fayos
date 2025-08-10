# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# History line

.section .text
.code16
.global hist_line

# hist_line()
# <ret> ax = mem_off
# <ret> dx = hist_line_size
hist_line:
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

	# {{{ calc mem ptr
	mov $file_lines, %di
	add $0x02, %di # skip lines_c

.lp:
	# {end.done} (hist_line_i == 0)
	test %cx, %cx
	jz .done

	mov (%di), %ax
	add %ax, %bx
	add $0x02, %bx # skip cr,lf

	# {lp}
	add $0x02, %di
	sub $0x01, %cx
	jmp .lp

.done:
	# }}}
	# dx = hist_line_size
	mov %bx, %ax

	pop %bx
	pop %di
	ret
