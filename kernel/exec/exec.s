# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Execute command

.section .data
.global cmd_map

cmd_map:
	.word cmd_clear
	.asciz "clear"
	.word cmd_echo
	.asciz "echo"
	.word cmd_touch
	.asciz "touch"
	.word cmd_rm
	.asciz "rm"
	.word cmd_ls
	.asciz "ls"
	.word cmd_cat
	.asciz "cat"
	.word cmd_help
	.asciz "help"
	.word cmd_mkdir
	.asciz "mkdir"
	.word cmd_cd
	.asciz "cd"
	.word 0x00
	.asciz ""

.no_cmd_err_msg: .asciz "Command not found. Try \"help\" for a list of commands."

.section .text
.code16
.global exec_cmd

# ENTRY
# exec_cmd()
exec_cmd:
	# prol
	push %si
	push %di
	push %ax
	push %bx
	push %cx

	# TODO: vaild args
	# tok
	# call trim_raw
	# TEST
	# call trim_args
	# call split_args
	call tok_args
	jmp .exec_cmd__pre_done

	call split_raw

	# cond: ax == 1 ? done
	cmp $0x01, %ax
	je .exec_cmd__done

	call build_args

	# load argc
	mov $argc, %di
	mov (%di), %cx

	# cond: cx == 0 ? pre_done
	test %cx, %cx
	jz .exec_cmd__pre_done

	# init
	mov $raw_buf, %si
	mov $cmd_map, %di

# CHK
.exec_cmd__chk_addr_lp:
	# load
	mov (%di), %bx

	# cond: null ? hdl_no_cmd_err
	test %bx, %bx
	jz .hdl_no_cmd_err

	# char
	add $0x02, %di

.exec_cmd__chk_char_lp:
	# load
	mov (%di), %al

	# cond: al != si ? skip_char_lp
	cmp (%si), %al
	jne .exec_cmd__skip_char_lp

	# cond: null ? call
	test %al, %al
	jz .exec_cmd__call

	# step
	add $0x01, %si
	add $0x01, %di
	jmp .exec_cmd__chk_char_lp

# SKIP_CHAR
.exec_cmd__skip_char_lp:
	# load
	mov (%di), %al

	# cond: null ? skip_char_end
	test %al, %al
	jz .exec_cmd__skip_char_end

	# step
	add $0x01, %di
	jmp .exec_cmd__skip_char_lp

.exec_cmd__skip_char_end:
	# step
	mov $raw_buf, %si
	add $0x01, %di
	jmp .exec_cmd__chk_addr_lp

# CALL
.exec_cmd__call:
	# pre: bx = cmd_addr

	call *%bx

	# init and load
	# mov $redir_buf, %si
	# mov (%si), %al

	# (chr != 0) ? exec_redir
	# test %al, %al
	# jne .exec_cmd__exec_redir

	# (redir_buf_len != 0) ? exec_redir
	mov $redir_buf, %si
	mov (%si), %cx
	test %cx, %cx
	jnz .exec_cmd__exec_redir

	# done
	jmp .exec_cmd__done

# REDIR
.exec_cmd__exec_redir:
	# save i_num
	mov (i_num), %ax
	push %ax
	mov (i_num+0x02), %ax
	push %ax

	# call
	call exec_redir

	# restore i_num
	pop %ax
	mov %ax, (i_num+0x02)
	pop %ax
	mov %ax, (i_num)

	# done
	jmp .exec_cmd__done

# DONE
.exec_cmd__pre_done:
	call outnl

.exec_cmd__done:
	# epil
	pop %cx
	pop %bx
	pop %ax
	pop %di
	pop %si
	ret

# ERROR
.hdl_no_cmd_err:
	call outnl

	push $.no_cmd_err_msg
	call puts
	add $0x02, %sp

	call outnl

	jmp .exec_cmd__done
