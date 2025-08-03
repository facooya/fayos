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
	# {{{ fptr len
	mov $raw_buf, %si
	add $0x02, %si # *buf_data

	push %es
	xor %ax, %ax
	mov %ax, %es

	push %si
	push %es
	call fptrlen
	add $0x04, %sp

	mov %ax, %bx # cmd_len
	pop %es
	# }}}

	# {init}
	mov $cmd_map, %di
	add $0x02, %di # map_chr

.map__lp:
	# {{{ fptr len
	push %es
	xor %ax, %ax
	mov %ax, %es

	push %di
	push %es
	call fptrlen
	add $0x04, %sp

	mov %ax, %cx # map_chr_len
	pop %es
	# }}}

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
	# {{{ fptr n cmp
	push %cx # s.1 map_chr_len
	push %es # s.2

	xor %ax, %ax
	mov %ax, %es

	push %cx
	push %di
	push %es
	push %si
	push %es
	call fptrncmp
	add $0x0A, %sp

	pop %es # s.2
	pop %cx # s.1 map_chr_len
	# }}}

	# {end} (fptrncmp() == true)
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
	# save inum
	mov (inum), %ax
	push %ax
	mov (inum+0x02), %ax
	push %ax

	# call
	call exec_redir

	# restore inum
	pop %ax
	mov %ax, (inum+0x02)
	pop %ax
	mov %ax, (inum)

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
