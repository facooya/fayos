# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# [Debug] Size buffer

.include "chr.inc"
.section .text
.code16
.global dbg_sbuf

# dbg_sbuf(&sbuf)
dbg_sbuf:
	push %bp
	mov %sp, %bp
	push %si
	push %ax
	push %bx
	push %cx
	push %dx

	mov $CHR_CR, %al
	call vga_putc
	mov $CHR_LF, %al
	call vga_putc
	call dbg_line
	mov $CHR_CR, %al
	call vga_putc
	mov $CHR_LF, %al
	call vga_putc

	mov 0x04(%bp), %si
	mov (%si), %cx # buf.len
	add $0x02, %si # skip len

	mov %cx, %ax # buf.len
	add $0x30, %al
	push %cx
	call vga_putc
	mov $CHR_CR, %al
	call vga_putc
	mov $CHR_LF, %al
	call vga_putc
	pop %cx

	call ._data
	mov $CHR_CR, %al
	call vga_putc
	mov $CHR_LF, %al
	call vga_putc
	call dbg_line
	mov $CHR_CR, %al
	call vga_putc
	mov $CHR_LF, %al
	call vga_putc

	pop %dx
	pop %cx
	pop %bx
	pop %ax
	pop %si
	pop %bp
	ret

._data:
	# {end} (buf.len == 0)
	test %cx, %cx # buf.len
	jz ._data__end

._data__lp:
	mov (%si), %al

	# (buf.data == sp)
	cmp $CHR_SP, %al
	je ._data__sp

	# (buf.data == null)
	test %al, %al
	jz ._data__nul

	push %cx
	call vga_putc
	pop %cx
	jmp ._data__chk

._data__sp:
	mov $CHR_PRD, %al
	push %cx
	call vga_putc
	pop %cx
	jmp ._data__chk

._data__nul:
	mov $CHR_ZERO, %al
	push %cx
	call vga_putc
	pop %cx
	jmp ._data__chk

._data__chk:
	# {step}
	add $0x01, %si # buf.data
	sub $0x01, %cx # buf.len

	# {end} (buf.len == 0)
	test %cx, %cx
	jz ._data__end

	# {lp}
	jmp ._data__lp

._data__end:
	ret

