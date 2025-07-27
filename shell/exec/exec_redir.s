# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Execute redirection

.include "fayfs/dentry.s"
.include "fayfs/inode.s"
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
	push $inum
	call lookup_dentry
	add $0x06, %sp
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
	mov DE_INUM_OFF(%bx), %ax
	mov %ax, (inum)
	mov DE_INUM_OFF+0x02(%bx), %ax
	mov %ax, (inum+0x02)

	# read i node
	push $inode
	push $inum
	call read_inode
	add $0x04, %sp

	push $inode
	call set_dap_blk_lba
	add $0x02, %sp

	push $dap
	call read_disk
	add $0x02, %sp
	mov %ax, %bx # mem
	mov %ax, %dx # backup mem

	mov $inode, %si
	mov I_FILE_SIZE_OFF(%si), %cx
	xor %ax, %ax

.run__clear_lp:
	# {end} (file_size <= 0)
	cmp $0x00, %cx
	jle .run__clear_end

	mov %ax, (%bx)

	add $0x02, %bx
	sub $0x02, %cx
	jmp .run__clear_lp

.run__clear_end:
	mov %dx, %bx # set mem
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
	push %dx
	push $dap
	call write_disk
	add $0x02, %sp
	pop %dx

.run__end:
	mov $inode, %si
	mov %dx, I_FILE_SIZE_OFF(%si)

	push $inode
	push $inum
	call update_inode
	add $0x04, %sp

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
