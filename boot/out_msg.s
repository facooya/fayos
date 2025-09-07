# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Out message for boot

# out_msg(&str)
out_msg:
	push %bp
	mov %sp, %bp
	push %es

	mov 0x04(%bp), %si

	# vid init
	mov $0xB800, %ax
	mov %ax, %es
	xor %di, %di

	# {{{ get cursor
	mov $0x0E, %al
	mov $0x03D4, %dx
	out %al, %dx
	mov $0x03D5, %dx
	in %dx, %al
	mov %al, %ah

	mov $0x0F, %al
	mov $0x03D4, %dx
	out %al, %dx
	mov $0x03D5, %dx
	in %dx, %al

	# skip outc, conf
	add %ax, %di
	add %ax, %di

	mov %ax, %cx # pos
	# }}}

.out_msg__lp:
	# (chr == null) ? {end}
	mov (%si), %al
	test %al, %al
	jz .out_msg__done

	# (chr == newline) ? {newline}
	cmp $NEWLINE, %al
	je .out_msg__newline

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
	jmp .out_msg__lp

.out_msg__newline:
	# {{{ newline
	push %cx
	mov $0x044A, %bx
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
	jmp .out_msg__lp

.out_msg__done:
	# {{{ set cursor
	mov $0x0E, %al
	mov $0x03D4, %dx
	out %al, %dx
	mov $0x03D5, %dx
	mov %ch, %al
	out %al, %dx

	mov $0x0F, %al
	mov $0x03D4, %dx
	out %al, %dx
	mov $0x03D5, %dx
	mov %cl, %al
	out %al, %dx
	# }}}

	pop %es
	pop %bp
	ret

