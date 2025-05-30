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
# di:dx = &argv:argc
cmd_echo:
	push %si
	push %bx

	# {init}
	mov $raw_buf, %si
	add $0x02, %si
	add $0x05, %si # HACK
	# add (argv_1), %si

	# {init} args
	# mov $argv, %di
	# mov (argc), %dx
	mov $args, %di
	mov (%di), %dx
	add $0x02, %di

	# FIXME
	# arg opt
	# mov (argc_opt), %ax
	# mov (argv_opt), %dx

	# (argc_opt == 0)
	# test %dx, %dx
	# jnz .parse_opt

	# (argc_arg == 0)
	# test %dx, %dx
	# jz .err

	# {init} opt flag
	xor %bx, %bx
	# bx = opt_flag [n_opt_flag]

# <PRE>
# *si == fst_chr
.cmd_echo__chk_opt:
	mov (%si), %al

	# (chr == hyphen)
	cmp $CHR_HYPHEN, %al
	je .cmd_echo__parse_opt

	# cond: null ? hdl_arg_err
	test %al, %al
	jz .hdl_arg_err

	# skip option
	jmp .cmd_echo__parse_arg

# OPT_FLAG
.cmd_echo__parse_opt:
	# pre: (si) = hyphen
	# load
	add $0x01, %si
	mov (%si), %al

	# cond: e ? set_flag_e
	cmp $0x65, %al
	jz .cmd_echo__set_flag_e

	# cond: n ? set_flag_n
	cmp $0x6E, %al
	jz .cmd_echo__set_flag_n

	# opt err
	jmp .hdl_opt_err

.cmd_echo__set_flag_e:
	# set
	bts $0x00, %bx

	# step
	add $0x02, %si
	add $0x02, %cx
	jmp .cmd_echo__chk_opt

.cmd_echo__set_flag_n:
	# set
	bts $0x01, %bx

	# step
	add $0x02, %si
	add $0x02, %cx
	jmp .cmd_echo__chk_opt

# ARG
.cmd_echo__parse_arg:
	# get {init}
	# mov $argv, %si
	# add $0x02, %si # skip cmd
	# add %cx, %si # skip opt
	# mov (%si), %ax # get offset
	# TEST!!!
	mov $args, %si
	add $0x04, %si # skip argc, cmd
	mov (%si), %ax

	# cond: ax == 0 ? hdl_arg_err
	test %ax, %ax
	jz .hdl_arg_err

	# set offset {init}
	mov $raw_buf, %si
	add $0x02, %si
	add %ax, %si # set offset

	# exec
	call outnl
	jmp .cmd_echo__exec

.cmd_echo__next_arg:
	# step
	add $0x02, %cx

	# get offset {init}
	mov $argv, %si
	add $0x02, %si # skip cmd
	add %cx, %si # skip opt+arg
	mov (%si), %ax # get offset

	# cond: ax == 0 ? done {escape}
	test %ax, %ax
	jz .cmd_echo__nl_done

	# set offset {init}
	mov $raw_buf, %si
	add $0x02, %si
	add %ax, %si # set offset

	# load
	mov (%si), %al

# EXEC
.cmd_echo__exec:
	# cond: e ? exec_opt_e
	bt $0x00, %bx
	jc .cmd_echo__exec_opt_e

	# default
	push %si
	call print_str
	add $0x02, %sp

	# jmp
	jmp .cmd_echo__skip_opt_e

.cmd_echo__exec_opt_e:
	push %si
	call print_esc
	add $0x02, %sp

.cmd_echo__skip_opt_e:
	# cond: n ? exec_opt_n
	bt $0x1, %bx
	jc .cmd_echo__exec_opt_n

	# default
	call outsp

	# jmp
	jmp .cmd_echo__next_arg

.cmd_echo__exec_opt_n:
	# get offset {init}
	mov $argv, %si
	add $0x02, %si # skip cmd
	add %cx, %si # skip opt+arg
	add $0x02, %si # skip this arg
	mov (%si), %ax # get offset

	# cond: ax == 0 ? done {pre-done}
	test %ax, %ax
	jz .cmd_echo__done

	call outsp

	jmp .cmd_echo__next_arg

# DONE
.cmd_echo__nl_done:
	call outnl

.cmd_echo__done:
	# epil
	pop %bx
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

	jmp .cmd_echo__done

.hdl_arg_err:
	call outnl
	call hdl_arg_err
	jmp .cmd_echo__done
