# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Debug register - show register value

.include "chr.s"
.section .data
.outnum: .zero 0x05

.section .text
.code16
.global dbg_reg

# dbg_reg(uint16_t reg)
dbg_reg:
	push %bp
	mov %sp, %bp
	push %si
	push %ax
	push %bx
	push %cx
	push %dx

	call dbg_line
	
	# {init}
	mov $.outnum, %si
	add $0x03, %si # last to first

	mov 0x04(%bp), %bx # num
	mov $0x04, %cx # count

.lp:
	mov %bx, %ax # num
	and $0x0F, %al # mask

	# (al > 9)
	cmp $0x09, %al
	jg .hex

	add $0x30, %al
	jmp .step

.hex:
	add $0x37, %al

.step:
	# store
	mov %al, (%si)
	sub $0x01, %si

	# {end} (count == 0)
	sub $0x01, %cx
	test %cx, %cx
	jz .end

	# {lp}
	shr $0x04, %bx
	jmp .lp

.end:
	push $.outnum
	call vga_puts
	add $0x02, %sp

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
