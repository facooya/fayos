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
# si,bx = (raw_buf) len, chr
# di,cx = (raw_buf) len, chr
parse_args:
	push %si
	push %di
	push %bx

	# {init}
	mov $raw_buf, %si
	mov (%si), %bx
	add $0x02, %si

	# {exit}
	test %bx, %bx
	jz .exit

	# re_alpha(&chr) [a-zA-Z]
	# ret: ax = 0(true), ax = 1(false)
	push %si
	call re_alpha
	add $0x02, %sp

	test %ax, %ax
	jz .pass_cmd
	jmp .call_hdl_cmd_syn_err

.pass_cmd:
	mov (%si), %al
	test %al, %al
	jz .pass_cmd_end

	add $0x01, %si
	sub $0x01, %bx
	jmp .pass_cmd

.pass_cmd_end:
	add $0x01, %si
	sub $0x01, %bx

	mov (%si), %al

	cmp $CHR_HYPHEN, %al
	je .parse_opt
	jmp .pass_opt

.parse_opt:
	# {next}
	add $0x01, %si
	sub $0x01, %bx

	# {valid}
	push %si
	call re_alpha
	add $0x02, %sp

	# {err}
	test %ax, %ax
	jz .next_opt
	jmp .call_hdl_opt_syn_err

.next_opt:
	mov 0x01(%si), %al

	test %al, %al
	jz .pass_opt
	jmp .parse_opt

.pass_opt:
	add $0x01, %si
	sub $0x01, %bx

	test %bx, %bx
	jz .call_hdl_arg_req_err

# arg
.chk_syn:

.chk_syn_end:

# redir
.chk_redir:

.exit:
	mov $0x01, %ax

.done:
	pop %bx
	pop %di
	pop %si
	ret

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
