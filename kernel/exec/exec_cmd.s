# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Execute command

.section .text
.code16
.global exec_cmd

# exec_cmd()
exec_cmd:
	push %si
	push %di
	push %bx

	call outnl

	# {end.done} (ret.code != 0)
	call proc_args
	test %ax, %ax
	jnz .done

	# {task}
	jmp .map

# {TASK}
# <INFO>
# si:bx = (argv[0]) chr:len
# di:cx = (map) chr:len
.map:
	# {{{
	# {init}
	mov $raw_buf, %si
	add $0x02, %si # *buf_data

	# bx = strlen(&str)
	push %si
	call strlen
	add $0x02, %sp
	mov %ax, %bx # cmd_len
	# }}}

	# {init}
	mov $cmd_map, %di
	add $0x02, %di # map_chr

.map__lp:
	# strlen(&str)
	# <ret> ax = len
	push %di
	call strlen
	add $0x02, %sp
	mov %ax, %cx # map_chr_len

	# {chk} (map_chr_len == cmd_len)
	cmp %bx, %cx
	je .map__chk

.map__lp_step:
	# {step}
	add $0x03, %cx # add null+addr_size
	add %cx, %di # *map_chr
	mov -0x02(%di), %ax # map_addr

	# {end.err} (map_addr == null)
	test %ax, %ax
	jz .err_cmd_not

	# {lp}
	jmp .map__lp

.map__chk:
	# strcmp(&s1, &s2)
	# <ret> ax = ret.code
	push %cx # map_chr_len
	push %di # s2
	push %si # s1
	call strcmp
	add $0x04, %sp
	pop %cx # map_chr_len

	# {end} (ret.code == true)
	test %ax, %ax
	jz .map__end

	# {lp}
	jmp .map__lp_step

.map__end:
	mov -0x02(%di), %bx # map_addr
	call *%bx
	test %ax, %ax
	jnz .done

	# {task} (redir.hdr != 0)
	mov $redir_buf, %si
	mov (%si), %cx
	test %cx, %cx
	jnz .redir

	# print
	mov $write_buf, %si
	mov (%si), %cx # buf.len
	add $0x02, %si # skip len

	push %si
	call outs
	add $0x02, %sp

	# {end.done}
	jmp .done

# {TASK}
.redir:
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

	# {end.done}
	jmp .done

# {DONE}
.done:
	push $write_buf
	call clear_buf
	add $0x02, %sp

	pop %bx
	pop %di
	pop %si
	ret

# {ERR}
.err_cmd_not:
	push $emsg_cmd_not
	jmp .err_hdl

.err_hdl:
	call outs
	add $0x02, %sp
	call outnl
	jmp .done
