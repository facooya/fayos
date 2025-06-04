# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Debug buffer

.include "chr.s"

.section .text
.code16
.global dbg_buf
.global dbg_redir_buf

# dbg_buf(buf)
dbg_buf:
	push %bp
	mov %sp, %bp
	push %si
	push %di
	push %bx

	call outnl
	call dbg_line
	call outnl

	mov 0x04(%bp), %si
	mov (%si), %cx # buf.len
	add $0x02, %si # skip len

	mov %cx, %ax # buf.len
	add $0x30, %al
	call outc
	call outnl

	call ._data
	call outnl
	call dbg_line
	call outnl

	pop %bx
	pop %di
	pop %si
	pop %bp
	ret

# dbg_redir_buf()
# <INFO>
# hdr:data
# <REQ>
# hdr = type:len
# ax = hdr
dbg_redir_buf:
	push %si
	push %di
	push %bx

	mov $redir_buf, %si
	mov (%si), %cx # redir.hdr
	
	# {{{ out
	call outnl
	call dbg_line
	call outnl

	# type
	mov %ch, %al # redir.type
	add $0x30, %al
	call sys_tty_out
	call outcol

	# len
	mov %cl, %al # redir.len
	add $0x30, %al
	call sys_tty_out
	call outnl
	# }}}

	# {{{
	mov (%si), %ax # redir.hdr
	add $0x02, %si

	xor %cx, %cx
	mov %al, %cl # redir.len
	call ._data

	call outnl
	call dbg_line
	call outnl
	# }}}

	pop %si
	pop %di
	pop %bx
	ret

# {TASK}
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

	call sys_tty_out
	jmp ._data__chk

._data__sp:
	mov $CHR_PRD, %al
	call sys_tty_out
	jmp ._data__chk

._data__nul:
	mov $CHR_ZERO, %al
	call sys_tty_out
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

