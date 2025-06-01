# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Parse for arguments, And option count

.include "chr.s"
.section .text
.code16
.global parse_args

# parse_args()
# <INFO>
# si = &raw_buf
# di:dx = &args:v_idx
# cx = argc
parse_args:
	push %si
	push %di
	push %bx

	# {init}
	mov $raw_buf, %si
	add $0x02, %si # skip len
	mov $args, %di
	mov (%di), %cx # argc

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

# {TASK}
# <PRE>
# (*si == valid_chr)
.cmd:
.cmd__lp:
	# {end} (chr == null)
	mov (%si), %al
	test %al, %al
	jz .cmd__end

	# {lp}
	add $0x01, %si
	jmp .cmd__lp

.cmd__end:
	# {step}
	add $0x01, %si # buf_idx
	sub $0x01, %cx # argc

	# {end.done} (argc == 0)
	xor %ax, %ax
	test %cx, %cx
	jz .done

	# {task}
	jmp .opt

# {TASK}
# <PRE>
# *si == hyphen || [a-zA-Z]
.opt:
	xor %bx, %bx # optc
	mov $args, %di
	mov %bx, 0x02(%di) # optc = 0
	sub $0x01, %si # *si == null
	jmp .opt__chk

# <PRE>
# (*si == opt_chr)
.opt__lp:
	# {chk} (opt_chr == null)
	mov (%si), %al
	test %al, %al
	jz .opt__chk

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
	jmp .opt__lp

# <PRE>
# (*si == null)
.opt__chk:
	# {step}
	add $0x01, %si

	# {end} (chr != hyphen)
	mov (%si), %al
	cmp $CHR_HYPHEN, %al
	jne .opt__end

	# {step}
	add $0x01, %si # opt_chr
	add $0x01, %bx # optc

	# {end.err} (opt_chr == null)
	mov (%si), %al
	test %al, %al
	jz .call_hdl_opt_syn_err

	# {lp}
	jmp .opt__lp

.opt__end:
	# store optc
	mov $args, %di
	mov %bx, 0x02(%di)

	# {task}
	jmp .arg

# {TASK}
# <PRE>
# (*si == [a-zA-Z])
.arg:
.arg__lp:
	# {chk}
	mov (%si), %al
	test %al, %al
	jz .arg__chk

	# {lp}
	add $0x01, %si
	jmp .arg__lp

# <PRE>
# *si == 0
.arg__chk:
	# {end}
	sub $0x01, %cx # argc
	xor %ax, %ax # ret
	test %cx, %cx
	jz .arg__end

	# {task}
	# ah = redir_type
	mov 0x01(%si), %al
	mov $0x01, %ah
	cmp $CHR_GT, %al
	je .redir
	mov $0x03, %ah
	cmp $CHR_LT, %al
	je .redir

	# {lp}
	jmp .arg__lp

.arg__end:
	# {end.done}
	xor %ax, %ax
	jmp .done

# {TASK}
# <PRE>
# (*si == 0)
# ah = redir_type
.redir:
	# {init}
	mov $redir_buf, %di
	mov %ah, (%di)
	add $0x02, %di # skip type+len

	# {init}
	add $0x02, %si # skip null+type=null
	sub $0x01, %cx # argc

	mov (%si), %al

	# {end.err} (chr != 0)
	test %al, %al
	jnz .hdl_redir_type_err

	# {end.err} (argc == 0)
	test %cx, %cx
	jz .hdl_redir_req_err

	# {init}
	add $0x01, %si # skip null
	xor %dx, %dx # len

# <PRE>
# (*si == fst_chr)
# di:dx = &redir_buf:len
.redir__lp:
	mov (%si), %al

	# {end}
	test %al, %al
	jz .redir__end

	mov %al, (%di)

	# {lp}
	add $0x01, %si
	add $0x01, %di
	add $0x01, %dx # len
	jmp .redir__lp

.redir__end:
	# store last null
	mov %al, (%di)
	add $0x01, %dx

	# store len
	mov $redir_buf, %di
	add $0x01, %di
	mov %dl, (%di)

	sub $0x01, %cx # argc

	# {end.err} (argc != 0)
	test %cx, %cx
	jnz .hdl_redir_extra_err

	# update argc
	mov $args, %di
	mov (%di), %ax # argc
	sub $0x02, %ax # argc - redir_token_count
	mov %ax, (%di) # argc

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
