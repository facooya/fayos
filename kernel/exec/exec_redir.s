# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Execute redirection

.include "fayfs/de.s"
.section .text
.code16
.global exec_redir

# exec_redir()
exec_redir:
	push %si
	push %di
	push %bx

	# init
	mov $redir_buf, %si
	mov (%si), %ax # type:len
	add $0x02, %si

	xor %cx, %cx
	mov %al, %cl # len

	# {task} (redir_type == 1)
	cmp $0x01, %ah # type
	je .type__write

	# {end.err}
	jmp .err_redir_type

# {TASK}
.type__write:
	# {{{ lookup dentry
	push %si # name
	push %cx # name_len
	mov (i_num), %ax
	push %ax # i_num_lo
	mov (i_num+0x02), %ax
	push %ax # i_num_hi
	call lookup_dentry
	add $0x08, %sp
	mov %ax, %bx

	# {err} (lookup_dentry == no_match)
	test %ax, %ax
	jz .err_file_no

	# {err} (file_type != file)
	mov DE_FILE_TYPE_OFF(%bx), %al
	cmp $0x80, %al
	jne .err_file_type

	# {task}
	jmp .run
	# }}}

# {TASK}
.run:
	# get dst i num
	mov DE_I_NUM_LO_OFF(%bx), %ax
	mov %ax, (i_num)
	mov DE_I_NUM_HI_OFF(%bx), %ax
	mov %ax, (i_num+0x02)

	# read i node
	mov (i_num), %ax
	push %ax
	mov (i_num+0x02), %ax
	push %ax
	call read_inode
	add $0x04, %sp

	# init mem
	mov $0x8000, %bx
	xor %dx, %dx # file_size

	mov $write_buf, %si
	mov (%si), %cx # buf.len
	add $0x02, %si # skip len

.run__write_lp:
	mov (%si), %al

	# {end} (len == 0)
	test %cx, %cx
	jz .run__write_end

	mov %al, (%bx)

	# {lp}
	add $0x01, %si # chr
	add $0x01, %bx # mem
	add $0x01, %dx # size
	sub $0x01, %cx # buf.len
	jmp .run__write_lp

.run__write_end:
	call set_blk_lba
	call write_block

.run__end:
	# update_i_file_size
	push %dx # file_size
	mov (i_num), %ax
	push %ax # inum_lo
	mov (i_num+0x02), %ax
	push %ax # inum_hi
	call update_i_file_size
	add $0x06, %sp

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
.err_redir_type:
	push $emsg_redir_type
	jmp .err_hdl

.err_file_no:
	push $emsg_file_no
	jmp .err_hdl

.err_file_type:
	push $emsg_file_type
	jmp .err_hdl

.err_hdl:
	call outs
	add $0x02, %sp
	call outnl
	jmp .exit
