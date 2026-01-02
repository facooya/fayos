# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Debug trace

.include "chr.inc"
.section .text
.code16
.global dbg_a
.global dbg_b
.global dbg_c

dbg_a:
	push %ax
	push %cx
	push %dx
	call ._prol
	mov $0x41, %al
	jmp .done

dbg_b:
	push %ax
	push %cx
	push %dx
	call ._prol
	mov $0x42, %al
	jmp .done

dbg_c:
	push %ax
	push %cx
	push %dx
	call ._prol
	mov $0x43, %al
	jmp .done

.done:
	call vga_putc
	mov $CHR_SP, %al
	call vga_putc
	call dbg_line
	mov $CHR_CR, %al
	call vga_putc
	mov $CHR_LF, %al
	call vga_putc

	pop %dx
	pop %cx
	pop %ax
	ret

._prol:
	mov $CHR_CR, %al
	call vga_putc
	mov $CHR_LF, %al
	call vga_putc
	call dbg_line
	mov $CHR_SP, %al
	call vga_putc
	ret
