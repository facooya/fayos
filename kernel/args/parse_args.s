# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Parse for arguments

.include "chr.s"
.section .text
.code16
.global parse_args

# parse_args()
# <INFO>
# si = &raw_buf
# di:dx = &argv:argv_off
# cx = argc
parse_args:
	push %si
	push %di
	push %bx

	# {init}
	# mov $argc, %si
	mov $args, %di
	mov (%di), %cx

	mov $raw_buf, %si
	add $0x02, %si

	# re_alpha(&chr) [a-zA-Z]
	# ret: ax = 0(true), ax = 1(false)
	push %cx
	push %si
	call re_alpha
	add $0x02, %sp
	pop %cx

	# {end.err} (re_alpha != true)
	test %ax, %ax
	jnz .call_hdl_cmd_syn_err

	# {task}
	jmp .cmd

.cmd:
.cmd__lp:
	# {end.step} (chr == null)
	mov (%si), %al
	test %al, %al
	jz .cmd__end

	# {step}
	add $0x01, %si
	jmp .cmd__lp

.cmd__end:
	# {step.adv}
	add $0x01, %si # buf_idx
	sub $0x01, %cx # argc

	# {end.done} (argc == 0)
	xor %ax, %ax
	test %cx, %cx
	jz .done

	# {task}
	jmp .opt

# <PRE>
# *si == hyphen || [a-zA-Z]
.opt:
	xor %bx, %bx # opt_c

.opt__chk:
	# {end} (chr != hyphen)
	mov (%si), %al
	cmp $CHR_HYPHEN, %al
	jne .opt__end

	# {step.adv} opt_chr
	add $0x01, %si
	add $0x01, %bx # opt_c

	# {end.err} (opt_chr == null)
	mov (%si), %al
	test %al, %al
	jz .call_hdl_opt_syn_err

# <PRE>
# *si == opt_chr
.opt__chr_lp:
	# {end.step} (opt_chr == null)
	mov (%si), %al
	test %al, %al
	jz .opt__chr_end

	# re_alpha(&chr)
	push %cx # save argc
	push %si # &chr
	call re_alpha
	add $0x02, %sp
	pop %cx # restore argc

	# {end.err} (re_alpha != true)
	test %ax, %ax
	jnz .call_hdl_opt_syn_err

	# {step}
	add $0x01, %si
	jmp .opt__chr_lp

.opt__chr_end:
	# {step.adv}
	add $0x01, %si
	jmp .opt__chk

.opt__end:
	# get opt_idx
	mov $args, %di
	add $0x04, %di
	mov (%di), %dx # opt_idx

	# set args_info
	mov $args_info, %di
	mov %bx, (%di) # opt_c
	mov %dx, 0x02(%di) # opt_idx

	# {task}
	jmp .arg

# <PRE>
# *si == [a-zA-Z]
.arg:
	xor %bx, %bx # arg_c

.arg__lp:
	# {end.step}
	mov (%si), %al
	test %al, %al
	jz .arg__chk

	# {step}
	add $0x01, %si
	jmp .arg__lp

# <PRE>
# *si == 0
.arg__chk:
	# {end}
	add $0x01, %bx
	sub $0x01, %cx # argc
	xor %ax, %ax # ret
	test %cx, %cx
	jz .arg__end

	# {task} # FIXME!!!
	# ah = redir_type
	mov 0x01(%si), %al
	mov $0x01, %ah
	cmp $CHR_GT, %al
	je .parse_redir
	mov $0x03, %ah
	cmp $CHR_LT, %al
	je .parse_redir

	# {step}
	jmp .arg__lp

.arg__end:
	# get opt_c
	push %cx
	mov $args_info, %di
	mov (%di), %ax # opt_c
	mov $0x02, %cx
	mul %cx
	pop %cx

	# calc arg_idx
	mov $args, %di
	add $0x04, %di # skip argc+cmd
	add %ax, %di # skip opt_c
	mov (%di), %dx # arg_idx

	# set args_info
	mov $args_info, %di
	mov %bx, 0x04(%di) # arg_c
	mov %dx, 0x06(%di) # arg_idx

	# {end.done}
	xor %ax, %ax
	jmp .done

# <PRE> # FIXME
# *si == 0
# ah = redir_type
.parse_redir:
	# {init}
	mov $redir_buf, %di
	mov %ah, (%di)
	add $0x02, %di

	# {init}
	add $0x02, %si
	sub $0x01, %cx

	mov (%si), %al

	# {err}
	test %al, %al
	jnz .hdl_redir_type_err
	test %cx, %cx
	jz .hdl_redir_req_err

	# {init} cpy
	add $0x01, %si
	xor %dx, %dx

# <PRE>
# *si == fst_chr
# di = &redir_buf
# dx = len (redir_buf)
.parse_redir__cpy:
	mov (%si), %al

	# {end}
	test %al, %al
	jz .parse_redir__end

	mov %al, (%di)

	# {loop}
	add $0x01, %si
	add $0x01, %di
	add $0x01, %dx
	jmp .parse_redir__cpy

.parse_redir__end:
	# save null
	mov %al, (%di)
	add $0x01, %dx

	# save len
	mov $redir_buf, %di
	add $0x01, %di
	mov %dl, (%di)

	sub $0x01, %cx

	# {err}
	test %cx, %cx
	jnz .hdl_redir_extra_err

	# update argc
	mov $argc, %di
	mov (%di), %ax
	sub $0x02, %ax
	mov %ax, (%di)

	# {end}
	xor %ax, %ax
	jmp .done

# {DONE}
.exit:
	mov $0x01, %ax
	jmp .done

.done:
	# TODO: opt_idx, arg_idx
	pop %bx
	pop %di
	pop %si
	ret

# {ERR}
.call_hdl_cmd_syn_err:
	call outnl
	call hdl_cmd_syn_err
	call outnl
	jmp .exit

.call_hdl_opt_syn_err:
	call outnl
	call hdl_opt_syn_err
	call outnl
	jmp .exit

.call_hdl_arg_req_err:
	call outnl
	call hdl_arg_req_err
	call outnl
	jmp .exit

.hdl_redir_type_err:
	call outnl
	push $redir_type_err_msg
	jmp .hdl_err

.hdl_redir_req_err:
	call outnl
	push $redir_req_err_msg
	jmp .hdl_err

.hdl_redir_extra_err:
	call outnl
	push $redir_extra_err_msg
	jmp .hdl_err

.hdl_err:
	call puts
	add $0x02, %sp
	call outnl
	jmp .exit
