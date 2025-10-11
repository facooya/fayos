# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Clear display in bootloader

.include "boot.s"
.section .text
.code16
.global boot_vga_clr

# boot_vga_clr()
boot_vga_clr:
	push %es

	# vid init
	mov $VID_MEM_SEG, %ax
	mov %ax, %es
	xor %di, %di

	# {{{ get disp
	xor %dx, %dx
	mov $DISP_MEM_ROW, %bx
	mov (%bx), %dl

	mov $DISP_MEM_COL, %bx
	mov (%bx), %ax
	# }}}

	mul %dx
	mov %ax, %cx

.lp:
	# (count == 0) ? {end}
	test %cx, %cx
	jz .done

	# clear
	mov $CHR_SP, %al
	mov %al, %es:(%di)
	add $0x01, %di

	# conf
	mov $CONF_BG, %al
	mov %al, %es:(%di)
	add $0x01, %di

	# {lp}
	sub $0x01, %cx
	jmp .lp

.done:
	# {{{ set cursor
	mov $CURS_POS_HI, %al
	mov $CURS_CMD_REG, %dx
	out %al, %dx
	mov $CURS_DATA_REG, %dx
	xor %al, %al
	out %al, %dx

	mov $CURS_POS_LO, %al
	mov $CURS_CMD_REG, %dx
	out %al, %dx
	mov $CURS_DATA_REG, %dx
	xor %al, %al
	out %al, %dx
	# }}}

	pop %es
	ret
