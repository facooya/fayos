# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Parse for arguments

.include "chr.s"
.section .text
.code16
.global parse_args

# {ENTRY}
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
	mov $argc, %si
	mov (%si), %cx
	mov $raw_buf, %si
	add $0x02, %si

	# re_alpha(&chr) [a-zA-Z]
	# ret: ax = 0(true), ax = 1(false)
	push %cx
	push %si
	call re_alpha
	add $0x02, %sp
	pop %cx

	# {err}
	test %ax, %ax
	jnz .call_hdl_cmd_syn_err

# {MAIN} CMD
.parse_cmd:
	mov (%si), %al

	# {end}
	test %al, %al
	jz .parse_cmd__end

	# {loop}
	add $0x01, %si
	jmp .parse_cmd

.parse_cmd__end:
	# {init}
	add $0x01, %si
	sub $0x01, %cx

	# {done}
	xor %ax, %ax
	test %cx, %cx
	jz .done
	jmp .parse_arg

# {MAIN} ARG
# <PRE>
# *si == 0
.parse_arg:
	# {loop}
	add $0x01, %si

	mov (%si), %al

	# {end}
	test %al, %al
	jz .parse_arg__end

	# {loop}
	jmp .parse_arg

# <PRE>
# *si == 0
.parse_arg__end:
	# {init}
	sub $0x01, %cx

	# {end}
	xor %ax, %ax
	test %cx, %cx
	jz .done

	mov 0x01(%si), %al

	# {end}
	mov $0x01, %ah
	cmp $CHR_GT, %al
	je .parse_redir
	mov $0x03, %ah
	cmp $CHR_LT, %al
	je .parse_redir

	# {loop}
	jmp .parse_arg

# {MAIN} REDIR
# <PRE>
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
