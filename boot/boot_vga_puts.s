# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Put string in bootloader

.include "boot.s"
.section .text
.code16
.global boot_vga_puts

# boot_vga_puts(&str)
boot_vga_puts:
	push %bp
	mov %sp, %bp
	push %es

	mov 0x04(%bp), %si

	# vid init
	mov $VID_MEM_SEG, %ax
	mov %ax, %es
	xor %di, %di

	# {{{ get cursor
	mov $CURS_POS_HI, %al
	mov $CURS_CMD_REG, %dx
	out %al, %dx
	mov $CURS_DATA_REG, %dx
	in %dx, %al
	mov %al, %ah

	mov $CURS_POS_LO, %al
	mov $CURS_CMD_REG, %dx
	out %al, %dx
	mov $CURS_DATA_REG, %dx
	in %dx, %al

	# skip outc, conf
	add %ax, %di
	add %ax, %di

	mov %ax, %cx # pos
	# }}}

.lp:
	# (chr == null) ? {end}
	mov (%si), %al
	test %al, %al
	jz .done

	# (chr == newline) ? {newline}
	cmp $CHR_NL, %al
	je .nl

	# out
	mov %al, %es:(%di)
	add $0x01, %di

	# conf
	mov $CONF_BG, %al
	mov %al, %es:(%di)
	add $0x01, %di

	# {lp}
	add $0x01, %si
	add $0x01, %cx # pos
	jmp .lp

.nl:
	# {{{ newline
	push %cx
	mov $DISP_MEM_COL, %bx
	mov (%bx), %cx # col

	xor %dx, %dx
	mov %di, %ax
	div %cx
	sub %dx, %di # init col

	# skip out, conf
	add %cx, %di
	add %cx, %di

	pop %cx
	# }}}

	# cursor pos
	mov %di, %ax
	mov $0x02, %cx
	xor %dx, %dx
	div %cx
	mov %ax, %cx

	add $0x01, %si
	jmp .lp

.done:
	# {{{ set cursor
	mov $CURS_POS_HI, %al
	mov $CURS_CMD_REG, %dx
	out %al, %dx
	mov $CURS_DATA_REG, %dx
	mov %ch, %al
	out %al, %dx

	mov $CURS_POS_LO, %al
	mov $CURS_CMD_REG, %dx
	out %al, %dx
	mov $CURS_DATA_REG, %dx
	mov %cl, %al
	out %al, %dx
	# }}}

	pop %es
	pop %bp
	ret
