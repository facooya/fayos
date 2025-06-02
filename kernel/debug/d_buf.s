# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Debug buffer

.include "chr.s"

.section .text
.code16
.global d_buf
.global d_redir_buf

# d_buf(buf)
d_buf:
	push %bp
	mov %sp, %bp
	push %si
	push %di
	push %bx

	call outnl

	mov 0x04(%bp), %si
	mov (%si), %cx
	add $0x02, %si

	mov %cx, %ax
	add $0x30, %al
	call sys_tty_out
	call outnl

	call ._data
	call outnl

	pop %bx
	pop %di
	pop %si
	pop %bp
	ret

# d_redir_buf()
# <INFO>
# hdr:data
# <REQ>
# hdr = type:len
# ax = hdr
d_redir_buf:
	push %si
	push %di
	push %bx
	
	call outnl

	mov $redir_buf, %si
	mov (%si), %cx

	# type
	mov %ch, %al
	add $0x30, %al
	call sys_tty_out
	call outcol

	# len
	mov %cl, %al
	add $0x30, %al
	call sys_tty_out
	call outnl

	mov (%si), %ax
	add $0x02, %si

	xor %cx, %cx
	mov %al, %cl
	call ._data
	call outnl

	pop %si
	pop %di
	pop %bx
	ret

# {TASK}
._data:
	test %cx, %cx
	jz ._data__end

._data__lp:
	mov (%si), %al

	cmp $CHR_SP, %al
	je ._data__sp

	test %al, %al
	jz ._data__nul

	call sys_tty_out
	jmp ._data__chk

._data__sp:
	mov $CHR_PERIOD, %al
	call sys_tty_out
	jmp ._data__chk

._data__nul:
	mov $CHR_ZERO, %al
	call sys_tty_out
	jmp ._data__chk

._data__chk:
	add $0x01, %si
	sub $0x01, %cx

	# {end}
	test %cx, %cx
	jz ._data__end

	# {lp}
	jmp ._data__lp

._data__end:
	ret

