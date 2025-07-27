# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Command echo

# NOTE
# [n_opt_flag]
# 0: e (escape)
# 1: n (no-newline)

.include "chr.s"
.section .text
.code16
.global cmd_echo

# cmd_echo()
# <INFO>
# si = &raw_buf
# di = &args
# bx = opt_flag
# cx = argc
cmd_echo:
	push %si
	push %di
	push %bx

	# {{blk.1}
	# get argc
	mov $args, %di
	mov (%di), %cx # argc
	add $0x02, %di

	# get optc
	mov (%di), %bx # optc
	add $0x02, %di

	# calc
	mov %cx, %ax
	sub $0x01, %ax # skip cmd
	sub %bx, %ax # skip optc

	# {end.err} (argc == 0)
	test %ax, %ax
	jz .err_arg_req
	# {blk.1}}

	# {{{
	# {init}
	mov $raw_buf, %si
	add $0x02, %si # skip len

	# {init}
	mov %bx, %ax # optc
	xor %bx, %bx # opt_flag
	add $0x02, %di # skip argv[0] (cmd)
	sub $0x01, %cx # skip argv[0]

	# {task} (optc == 0)
	test %ax, %ax
	jz .run
	jmp .opt
	# }}}

# {TASK}
# <PRE>
# (*si == hyphen)
# <INFO>
# dx = optc
.opt:
	mov %ax, %dx # optc

	add (%di), %si # buf += argv[1]
	add $0x01, %si # skip hyphen

# <PRE>
# (*si == opt_chr)
.opt__lp:
	mov (%si), %al

	# (opt_chr == e)
	cmp $0x65, %al
	je .opt__set_e

	# (opt_chr == n)
	cmp $0x6E, %al
	je .opt__set_n

	# {end.err}
	jmp .err_opt_inv

.opt__set_e:
	bts $0x00, %bx
	jmp .opt__set_chk

.opt__set_n:
	bts $0x01, %bx
	jmp .opt__set_chk

.opt__set_chk:
	add $0x01, %si

	# {chk} (opt_chr == null)
	mov (%si), %al
	test %al, %al
	jz .opt__chk

	# {lp}
	jmp .opt__lp

# <PRE>
# (*si == null)
.opt__chk:
	# {step}
	sub $0x01, %cx # argc
	sub $0x01, %dx # optc

	# {end} (optc == 0)
	test %dx, %dx
	jz .opt__end

	# {lp}
	add $0x02, %si # skip null+hyphen
	add $0x02, %di # argv[n+1]
	jmp .opt__lp

# <PRE>
# (*si == null)
.opt__end:
	add $0x02, %di # argv[n+1]

	# {task}
	jmp .run

# {TASK}
# <PRE>
# (*di == arg_idx)
.run:
	# {init}
	mov $raw_buf, %si
	add $0x02, %si

	mov (%di), %ax # arg_idx
	add %ax, %si

.run__lp:
	# {step} (opt == e)
	bt $0x00, %bx
	jc .run__exec_e

	push %si
	call puts
	add $0x02, %sp

	# {step}
	jmp .run__chk

.run__exec_e:
	push %si
	call putf
	add $0x02, %sp

.run__chk:
	sub $0x01, %cx # argc

	# {end} (arg_c == 0)
	test %cx, %cx
	jz .run__end

	call putsp

	# {lp.init}
	mov $raw_buf, %si
	add $0x02, %si # skip len

	# {lp.step}
	add $0x02, %di # argv[n+1]
	mov (%di), %ax
	add %ax, %si

	# {lp}
	jmp .run__lp

.run__end:
	# {end.done} (opt == n)
	xor %ax, %ax
	bt $0x01, %bx
	jc .done

	call putnl
	xor %ax, %ax
	jmp .done

# {DONE}
.done:
	pop %bx
	pop %di
	pop %si
	ret

# {ERR}
.err_opt_inv:
	# print opt err
	mov (%si), %al # opt err char
	call outc
	call outcol
	call outsp

	push $emsg_opt_inv
	jmp .err_hdl

.err_arg_req:
	push $emsg_arg_req
	jmp .err_hdl

.err_hdl:
	call outs
	add $0x02, %sp

	call outnl

	mov $0x01, %ax
	jmp .done
