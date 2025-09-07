# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Clear display for boot

# clear_disp()
clear_disp:
	push %es

	# vid init
	mov $0xB000, %ax
	mov %ax, %es
	mov $0x8000, %di

	# {{{ get disp
	xor %dx, %dx
	mov $0x0484, %bx
	mov (%bx), %dl

	mov $0x044A, %bx
	mov (%bx), %ax
	# }}}

	mul %dx
	mov %ax, %cx

.clear_disp__lp:
	# (count == 0) ? {end}
	test %cx, %cx
	jz .clear_disp__end

	# clear
	mov $SPACE, %al
	mov %al, %es:(%di)
	add $0x01, %di

	# conf
	mov $CONF_BG, %al
	mov %al, %es:(%di)
	add $0x01, %di

	# {lp}
	sub $0x01, %cx
	jmp .clear_disp__lp

.clear_disp__end:
	# {{{ set cursor
	mov $0x0E, %al
	mov $0x03D4, %dx
	out %al, %dx
	mov $0x03D5, %dx
	xor %al, %al
	out %al, %dx

	mov $0x0F, %al
	mov $0x03D4, %dx
	out %al, %dx
	mov $0x03D5, %dx
	xor %al, %al
	out %al, %dx
	# }}}

	pop %es
	ret
