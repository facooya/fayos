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
	add $0x02, %di # skip argv[0] (cmd)
	sub $0x01, %cx # skip argv[0]

	# {task} (opt_c == 0)
	test %ax, %ax
	jz .run
	jmp .opt

# <PRE>
# *si == hyphen
.opt:
	mov %ax, %dx # opt_c

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
	jmp .hdl_opt_err

.opt__set_e:
	bts $0x00, %bx
	jmp .opt__set_chk

.opt__set_n:
	bts $0x01, %bx
	jmp .opt__set_chk

.opt__set_chk:
	add $0x01, %si

	# {end.step} (opt_chr == null)
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

	call outnl

.run__lp:
	# {step} (opt == e)
	bt $0x00, %bx
	jc .run__exec_e

	push %si
	call print_str
	add $0x02, %sp

	# {step}
	jmp .run__skip_e

.run__exec_e:
	push %si
	call print_esc
	add $0x02, %sp

.run__skip_e:
	# {step.skip} (opt != n)
	bt $0x1, %bx
	jnc .run__skip_n

	# {end} (argc == last)
	cmp $0x01, %cx
	je .run__end

.run__skip_n:
	call outsp

.run__chk:
	sub $0x01, %cx # argc

	# {end} (arg_c == 0)
	test %cx, %cx
	jz .run__end

	# {lp.init}
	mov $raw_buf, %si
	add $0x02, %si # skip len

	add $0x02, %di # argv[n+1]
	mov (%di), %ax
	add %ax, %si

	# {lp}
	jmp .run__lp

.run__end:
	test %cx, %cx
	jz .nl_done
	jmp .done

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
