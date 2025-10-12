# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Debug utilities

.include "chr.s"
.section .text
.code16
.global dbg_line

# dbg_line()
dbg_line:
	push %ax
	push %cx
	push %dx
	mov $0x05, %cx

.lp:
	# {end.done}
	test %cx, %cx
	jz .done

	push %cx
	mov $CHR_EQ, %al
	call vga_putc
	pop %cx

	# {lp}
	sub $0x01, %cx
	jmp .lp

.done:
	pop %dx
	pop %cx
	pop %ax
	ret
