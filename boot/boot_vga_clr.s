# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya

.include "boot.s"
.section .text
.code16
.global boot_vga_clr

# boot_vga_clr()
boot_vga_clr:
	push %es

	# init
	mov $(VGA_MEM>>0x10), %ax
	mov %ax, %es
	mov $(VGA_MEM&0xFFFF), %di

	# { get disp
	xor %dx, %dx
	mov $DISP_ADDR_ROW, %bx
	mov (%bx), %dl

	mov $DISP_ADDR_COL, %bx
	mov (%bx), %ax
	# }

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

	# attr
	mov $VGA_ATTR_COLOR, %al
	mov %al, %es:(%di)
	add $0x01, %di

	sub $0x01, %cx
	jmp .lp

.done:
	# { set curs
	mov $VGA_CMD_CURS_POS_HI, %al
	mov $VGA_PORT_CURS_CMD, %dx
	out %al, %dx
	mov $VGA_PORT_CURS_DATA, %dx
	xor %al, %al
	out %al, %dx

	mov $VGA_CMD_CURS_POS_LO, %al
	mov $VGA_PORT_CURS_CMD, %dx
	out %al, %dx
	mov $VGA_PORT_CURS_DATA, %dx
	xor %al, %al
	out %al, %dx
	# }

	pop %es
	ret
