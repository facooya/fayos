# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya

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

	# init
	mov $(VGA_MEM>>0x10), %ax
	mov %ax, %es
	mov $(VGA_MEM&0xFFFF), %di

	# { get curs
	mov $VGA_CMD_CURS_POS_HI, %al
	mov $VGA_PORT_CURS_CMD, %dx
	out %al, %dx
	mov $VGA_PORT_CURS_DATA, %dx
	in %dx, %al
	mov %al, %ah

	mov $VGA_CMD_CURS_POS_LO, %al
	mov $VGA_PORT_CURS_CMD, %dx
	out %al, %dx
	mov $VGA_PORT_CURS_DATA, %dx
	in %dx, %al

	# skip outc, conf
	add %ax, %di
	add %ax, %di

	mov %ax, %cx # pos
	# }

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
	mov $VGA_CONF_BG, %al
	mov %al, %es:(%di)
	add $0x01, %di

	# {lp}
	add $0x01, %si
	add $0x01, %cx # pos
	jmp .lp

.nl:
	# {{{ newline
	push %cx
	mov $DISP_ADDR_COL, %bx
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

	# curs pos
	mov %di, %ax
	mov $0x02, %cx
	xor %dx, %dx
	div %cx
	mov %ax, %cx

	add $0x01, %si
	jmp .lp

.done:
	# { set curs
	mov $VGA_CMD_CURS_POS_HI, %al
	mov $VGA_PORT_CURS_CMD, %dx
	out %al, %dx
	mov $VGA_PORT_CURS_DATA, %dx
	mov %ch, %al
	out %al, %dx

	mov $VGA_CMD_CURS_POS_LO, %al
	mov $VGA_PORT_CURS_CMD, %dx
	out %al, %dx
	mov $VGA_PORT_CURS_DATA, %dx
	mov %cl, %al
	out %al, %dx
	# }

	pop %es
	pop %bp
	ret
