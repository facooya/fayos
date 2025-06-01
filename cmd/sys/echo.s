# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Echo

# NOTE
# [n_opt_flag]
# 0: e (escape)
# 1: n (no-newline)

.include "chr.s"
.section .text
.code16
.global cmd_echo

# {ENTRY}
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

	# {init}
	mov $raw_buf, %si
	add $0x02, %si # skip len

	# get
	# mov $args_info, %di
	# mov 0x04(%di), %ax # arg_c
	mov $args, %di
	mov (%di), %cx # argc
	add $0x02, %di
	mov (%di), %bx # optc
	add $0x02, %di

	mov %cx, %ax
	sub $0x01, %ax # skip cmd
	sub %bx, %ax # skip optc

	# {end.err} (argc == 0)
	test %ax, %ax
	jz .hdl_arg_err

	# {init}
	mov %bx, %ax # optc
	xor %bx, %bx # opt_flag

	# {task} (opt_c == 0)
	test %ax, %ax
	jz .arg
	jmp .opt

# <PRE>
# *si == hyphen
.opt:
	mov %ax, %dx # opt_c

	add $0x02, %di # skip argv[0] (cmd)
	add (%di), %si # buf += argv[1]
	add $0x01, %si # skip hyphen

# <PRE>
# *si == opt_chr
.opt__lp_chk:
	mov (%si), %al

	# (opt_chr == e)
	cmp $0x65, %al
	je .opt__set_e

	# (opt_chr == n)
	cmp $0x6E, %al
	je .opt__set_n

	# {end.err}
	jmp .hdl_opt_err

.opt__set_e:
	bts $0x00, %bx
	jmp .opt__chk

.opt__set_n:
	bts $0x01, %bx
	jmp .opt__chk

.opt__chk:
.opt__set_end:
	add $0x01, %si

	# {end.step} (opt_chr == null)
	mov (%si), %al
	test %al, %al
	jz .opt__end

	jmp .opt__lp_chk

# <PRE>
# *si == null
.opt__end:
	# {task} (opt_c == 0)
	sub $0x01, %cx
	test %cx, %cx
	jz .arg

	# {step}
	add $0x02, %si # skip null+hyphen
	jmp .opt__lp_chk

.arg:
.arg__init:
	# set offset {init}
	mov $raw_buf, %si
	add $0x02, %si

	mov $args_info, %di
	mov 0x04(%di), %cx # arg_c
	mov 0x06(%di), %ax # arg_idx
	add %ax, %si

	# {task}
	call outnl
	jmp .run

.run:
.run__init:
	push %bx # opt_flag

	mov $args_info, %di
	mov (%di), %bx # opt_c
	mov 0x04(%di), %cx # arg_c

	mov $args, %di
	add $0x02, %di # skip argc

	xor %dx, %dx
	mov $0x02, %ax # align
	mul %bx # opt_c
	add %ax, %di # *di = arg_idx

	mov $raw_buf, %si
	add $0x02, %si # skip len

	mov (%di), %ax
	add %ax, %si

	pop %bx # opt_flag

	add $0x30, %al
	call sys_tty_out

.run__lp:
	# (opt == e)
	bt $0x00, %bx
	jc .run__opt_e

	# default
	push %si
	call print_str
	add $0x02, %sp

	# jmp
	jmp .run__skip_opt_e

.run__opt_e:
	push %si
	call print_esc
	add $0x02, %sp

.run__skip_opt_e:
	# (opt == n)
	bt $0x1, %bx
	jc .run__opt_n

	# default
	call outsp

	# {end}
	jmp .run__end

.run__opt_n:
	# {end.done} (arg_c == last)
	cmp $0x01, %cx
	je .done

	# {end}
	call outsp
	jmp .run__end

.run__end:
	sub $0x01, %cx # arg_c

	# {end.done} (arg_c == 0)
	test %cx, %cx
	jz .nl_done

	mov $raw_buf, %si
	add $0x02, %si # skip len

	add $0x02, %di
	mov (%di), %ax
	add %ax, %si

	# {step}
	jmp .run__lp

# DONE
.nl_done:
	call outnl

.done:
	pop %bx
	pop %di
	pop %si
	ret

# ERR
.hdl_opt_err:
	call outnl

	# print opt err
	mov (%si), %al # opt err char
	call outc
	call outcol
	call outsp

	# print err msg
	call hdl_opt_err

	jmp .done

.hdl_arg_err:
	call outnl
	call hdl_arg_err
	jmp .done
