# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Parse for arguments, And calculation option count

.include "chr.s"
.section .text
.code16
.global parse_args

# parse_args()
# <INFO>
# si = raw.data
# cx = argc
# <RET>
# ax = 0:true, 1:exit
parse_args:
	push %si
	push %di
	push %bx

	# {{{
	# {init}
	mov $cl_lbuf, %si
	add $0x02, %si # skip len

	mov $args, %di
	mov (%di), %cx # argc
	# }}}

	# {task}
	jmp .cmd

# {TASK}
.cmd:
	# re_alpha(&chr)
	# ret: ax = 0(true), ax = 1(false)
	push %cx # argc
	push %si # raw.data
	call re_alpha
	add $0x02, %sp
	pop %cx # argc

	# {end.err} (ret.code != true)
	test %ax, %ax
	jnz .err_cmd_syn

.cmd__lp:
	# {end} (raw.data == null)
	mov (%si), %al
	test %al, %al
	jz .cmd__end

	# {lp}
	add $0x01, %si # raw.data
	jmp .cmd__lp

.cmd__end:
	# {step}
	add $0x01, %si # raw.data
	sub $0x01, %cx # argc

	# {end.done} (argc == 0)
	xor %ax, %ax
	test %cx, %cx
	jz .done

	# {task} (raw.data == hy)
	mov (%si), %al
	cmp $CHR_HY, %al
	je .opt

	# {task}
	jmp .arg

# {TASK}
# <INFO>
# di = &args
# bx = optc
# <REQ>
# (*si == hy)
.opt:
	xor %bx, %bx # optc
	add $0x01, %si # skip hy

# <REQ>
# (*si == alpha)
.opt__lp:
	# {chk} (chr == null)
	mov (%si), %al # raw.data
	test %al, %al
	jz .opt__chk

	# re_alpha(&chr)
	push %cx # argc
	push %si # raw.data
	call re_alpha
	add $0x02, %sp
	pop %cx # argc

	# {end.err} (ret.code != true)
	test %ax, %ax
	jnz .err_opt_syn

	# {lp}
	add $0x01, %si # raw.data
	jmp .opt__lp

.opt__chk:
	# {{{
	# {step}
	add $0x01, %si # skip null
	add $0x01, %bx # optc

	# {end} (chr != hy)
	mov (%si), %al # raw.data
	cmp $CHR_HY, %al
	jne .opt__end
	# }}}

	# {lp}
	add $0x01, %si # skip hy
	jmp .opt__lp

.opt__end:
	# store optc
	mov $args, %di
	mov %bx, 0x02(%di)

	# {step}
	sub %bx, %cx # argc

	# {end.done} (argc == 0)
	test %cx, %cx
	jz .done

	# {task}
	jmp .arg

# {TASK}
.arg:
# <REQ>
# (*si != null)
.arg__lp:
	# {chk} (chr == null)
	mov (%si), %al # raw.data
	test %al, %al
	jz .arg__chk

	# {lp}
	add $0x01, %si # raw.data
	jmp .arg__lp

.arg__chk:
	# {end} (argc == 0)
	sub $0x01, %cx # argc
	test %cx, %cx
	jz .arg__end

	# {task}
	# ah = redir.type
	mov 0x01(%si), %al
	mov $0x01, %ah
	cmp $CHR_GT, %al
	je .redir
	mov $0x03, %ah
	cmp $CHR_LT, %al
	je .redir

	# {lp}
	add $0x01, %si
	jmp .arg__lp

.arg__end:
	# {end.done}
	xor %ax, %ax
	jmp .done

# {TASK}
# <INFO>
# di = &redir_buf
# dx = offset
# <REQ>
# (*si == null)
# ah = redir.type
.redir:
	# {init}
	xor %dx, %dx
	mov $redir_buf, %di
	mov %ah, %dh # redir.type
	add $0x02, %di # skip type+len

	# {step}
	add $0x02, %si # skip null+redir.type
	sub $0x01, %cx # argc

	# {end.err} (chr != 0)
	mov (%si), %al # raw.data
	test %al, %al
	jnz .err_redir_type

	# {end.err} (argc == 0)
	test %cx, %cx
	jz .err_redir_req

	# {pre}
	add $0x01, %si # skip null

# <REQ>
# (*si == chr)
# di = redir.data
# dl = redir.len
.redir__lp:
	mov (%si), %al # raw.data

	# {end} (raw.data == null)
	test %al, %al
	jz .redir__end

	mov %al, (%di) # redir.data

	# {lp}
	add $0x01, %si # raw.data
	add $0x01, %di # redir.data
	add $0x01, %dl # redir.len
	jmp .redir__lp

.redir__end:
	# store hdr
	mov $redir_buf, %di
	mov %dx, (%di) # redir.hdr

	# {{{ chk err
	# {step}
	sub $0x01, %cx # argc

	# {end.err} (argc != 0)
	test %cx, %cx
	jnz .err_redir_extra
	# }}}

	# {{{ update argc
	mov $args, %di
	mov (%di), %ax # argc

	# argc -= redir.arg
	sub $0x02, %ax
	mov %ax, (%di)
	# }}}

	# {end.done}
	xor %ax, %ax
	jmp .done

# {DONE}
.exit:
	mov $0x01, %ax
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
