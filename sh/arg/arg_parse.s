# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# [Argument] Parse

.include "chr.s"
.include "fs/fs.s"
.section .text
.code16
.global arg_parse

# arg_parse()
# <info>
# si = (cl_sbuf) chr
# cx = arg_c
# <ret> ax = {true:0, exit:1, redir:2}
arg_parse:
	push %si
	push %di
	push %bx

	mov $cl_sbuf, %si
	add $0x02, %si
	mov $arg_ccv, %di
	mov (%di), %cx # arg_c
	jmp .cmd

.cmd:
	# { chk redir
	dec %si
	# ah = redir.type
	mov 0x01(%si), %dx
	mov $0x11, %ah
	cmp $REDIR_WRITE, %dx
	je .redir
	mov $0x12, %ah
	cmp $REDIR_APPEND, %dx
	jne 1f
	mov 0x03(%si), %al
	test %al, %al
	je .redir
1:
	inc %si
	# }

	# regex_alpha
	push %cx # [s.f0:arg_c]
	push %si # (&chr)
	call regex_alpha
	add $0x02, %sp
	# <ax = {true:0, false:1}>
	pop %cx # [s.f0:arg_c

	# (regex_alpha() != true) ? {err}
	test %ax, %ax
	jnz .err_cmd_syn

.cmd__lp:
	# (chr == null) ? {end}
	mov (%si), %al
	test %al, %al
	jz .cmd__end

	inc %si
	jmp .cmd__lp

.cmd__end:
	inc %si # chr
	dec %cx # arg_c

	# (arg_c == 0) ? {done}
	xor %ax, %ax
	test %cx, %cx
	jz .done

	# (chr == hy) ? {opt} : {arg}
	mov (%si), %al
	cmp $CHR_HY, %al
	je .opt
	jmp .arg

# {TASK}
# <info>
# di = *arg_ccv
# bx = opt_c
# <req>
# (*si == hy)
.opt:
	xor %bx, %bx # opt_c
	add $0x01, %si # skip hy

# <REQ>
# (*si == alpha)
.opt__lp:
	# (chr == null) ? {chk}
	mov (%si), %al
	test %al, %al
	jz .opt__chk

	# regex_alpha
	push %cx # [s.f0:arg_c]
	push %si # (&chr)
	call regex_alpha
	add $0x02, %sp
	# <ax = {true:0, false:1}>
	pop %cx # [s.f0:arg_c]

	# (regex_alpha() != true) ? {err}
	test %ax, %ax
	jnz .err_opt_syn

	inc %si
	jmp .opt__lp

.opt__chk:
	# {
	inc %si # skip null
	inc %bx # opt_c

	# (chr != hy) ? {end}
	mov (%si), %al
	cmp $CHR_HY, %al
	jne .opt__end
	# }

	inc %si # skip hy
	jmp .opt__lp

.opt__end:
	# store opt_c
	mov $arg_ccv, %di
	mov %bx, 0x02(%di)

	sub %bx, %cx # arg_c

	# (arg_c == 0) ? {done} : {arg}
	test %cx, %cx
	jz .done
	jmp .arg

# {TASK}
.arg:
	# { chk redir
	dec %si
	# ah = redir.type
	mov 0x01(%si), %dx
	mov $0x01, %ah
	cmp $REDIR_WRITE, %dx
	je .redir
	mov $0x02, %ah
	cmp $REDIR_APPEND, %dx
	jne 1f
	mov 0x03(%si), %al
	test %al, %al
	je .redir
1:
	# }
	inc %si

# <req>
# (*si != null)
.arg__lp:
	# (chr == null) ? {chk}
	mov (%si), %al
	test %al, %al
	jz .arg__chk

	inc %si
	jmp .arg__lp

.arg__chk:
	dec %cx # arg_c
	# (arg_c == 0) ? {end}
	test %cx, %cx
	jz .arg__end

	# ah = redir.type
	mov 0x01(%si), %dx
	mov $0x01, %ah
	cmp $REDIR_WRITE, %dx
	je .redir
	mov $0x02, %ah
	cmp $REDIR_APPEND, %dx
	jne 1f
	mov 0x03(%si), %al
	test %al, %al
	je .redir
1:

	inc %si
	jmp .arg__lp

.arg__end:
	xor %ax, %ax
	jmp .done

# {TASK}
# <info>
# di = *redir_hsbuf
# dx = off
# <req>
# (*si == null)
# ah = redir.type
.redir:
	# { clr
	mov $redir_hsbuf, %di
	mov (%di), %dx
	add $0x02, %di
	xor %dh, %dh

	push %ax # [s.f0:type]
	push %cx # [s.f1:arg_c]
	xor %cx, %cx
	push %dx # (size)
	push %cx # (value)
	push %di # (&off)
	push %cx # (&seg)
	call mem_set
	add $0x08, %sp
	pop %cx # [s.f1:arg_c]
	pop %ax # [s.f0:type]

	xor %dx, %dx
	mov %dx, (redir_hsbuf)
	# }

	xor %dx, %dx
	mov $redir_hsbuf, %di
	mov %ah, %dh # redir.type
	add $0x02, %di # skip type+size

	add $0x02, %si # skip null+redir.type
	dec %cx # arg_c

	# { redir append
	cmp $0x12, %dh
	je 1f
	cmp $0x02, %dh
	je 1f
	jmp 2f
1:
	add $0x01, %si
2:
	# }

	# (chr != 0) ? {err}
	mov (%si), %al
	test %al, %al
	jnz .err_redir_type

	# (arg_c == 0) { err}
	test %cx, %cx
	jz .err_redir_req

	# pre
	inc %si # skip null

# <req>
# (*si == chr)
# di = redir.chr
# dl = redir.size
.redir__lp:
	# (chr == null) ? {end}
	mov (%si), %al
	test %al, %al
	jz .redir__end

	# cpy
	mov %al, (%di)

	inc %si # cl.chr
	inc %di # redir.chr
	inc %dl # redir.size
	jmp .redir__lp

.redir__end:
	# store last null
	xor %ax, %ax
	mov %al, (%di)
	inc %di
	inc %dl

	# store hdr
	mov $redir_hsbuf, %di
	mov %dx, (%di) # redir.hdr

	dec %cx # arg_c
	# (arg_c != 0) ? {err}
	test %cx, %cx
	jnz .err_redir_extra

	# {{{ update arg_c
	mov $arg_ccv, %di
	mov (%di), %ax # arg_c

	# arg_c -= redir.arg
	sub $0x02, %ax
	mov %ax, (%di)
	# }}}

	# (redir.type == cmd) ? {done.redir}
	mov (redir_hsbuf), %ax
	cmp $0x10, %ah
	ja .done__redir

	xor %ax, %ax
	jmp .done

# {DONE}
.exit:
	mov $0x01, %ax
	jmp .done

.done__redir:
	sub $0x10, %ah
	mov %ax, (redir_hsbuf)
	mov $0x02, %ax
	jmp .done

.done:
	pop %bx
	pop %di
	pop %si
	ret

# {ERR}
.err_cmd_syn:
	mov $CHR_CR, %al
	call vga_putc
	mov $CHR_LF, %al
	call vga_putc
	push $emsg_cmd_syn
	jmp .err_hdl

.err_opt_syn:
	mov $CHR_CR, %al
	call vga_putc
	mov $CHR_LF, %al
	call vga_putc
	push $emsg_opt_syn
	jmp .err_hdl

.err_redir_type:
	mov $CHR_CR, %al
	call vga_putc
	mov $CHR_LF, %al
	call vga_putc
	push $emsg_redir_type
	jmp .err_hdl

.err_redir_req:
	mov $CHR_CR, %al
	call vga_putc
	mov $CHR_LF, %al
	call vga_putc
	push $emsg_redir_req
	jmp .err_hdl

.err_redir_extra:
	mov $CHR_CR, %al
	call vga_putc
	mov $CHR_LF, %al
	call vga_putc
	push $emsg_redir_extra
	jmp .err_hdl

.err_hdl:
	call vga_puts
	add $0x02, %sp
	mov $CHR_CR, %al
	call vga_putc
	mov $CHR_LF, %al
	call vga_putc
	jmp .exit
