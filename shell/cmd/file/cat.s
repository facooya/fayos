# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Command concatenate - show file data

.include "chr.s"
.include "fayfs/dentry.s"
.include "fayfs/inode.s"
.section .text
.code16
.global cmd_cat

# cmd_cat()
cmd_cat:
	push %es
	push %si
	push %di
	push %bx

	mov $args, %si

	# (argc == 1) ? {err}
	mov (%si), %ax
	cmp $0x01, %ax
	je .err_arg_req

	mov 0x06(%si), %ax # argv[1]
	mov $raw_buf, %si
	add $0x02, %si
	add %ax, %si # raw_buf[argv[1]]

	# (path_buf[0] != slash) ? {pass}
	mov (%si), %al
	cmp $CHR_SL, %al
	jne .path_pass

	# {{{ proc paths
	push %si
	call proc_paths
	add $0x02, %sp

	# (proc_paths() == 1) ? {err}
	cmp $0x01, %cx
	je .err_inv_path

	# (proc_paths() == 2) ? {err}
	cmp $0x02, %cx
	je .err_file_no

	mov %ax, %bx
	mov %dx, %es
	# }}}

	# (file_type != file) ? {err}
	mov %es:DE_FILE_TYPE_OFF(%bx), %al
	cmp $0x80, %al
	jne .err_file_type

	push $inode
	push $path_inum
	call read_inode
	add $0x04, %sp

	push $inode
	call set_dap_blk_lba
	add $0x02, %sp

	push $dap
	call read_disk
	add $0x02, %sp
	mov %ax, %bx
	mov %dx, %es

	mov $inode, %si
	mov I_FILE_SIZE_OFF(%si), %cx

	push %cx
	push %bx
	push %es
	call putns
	add $0x06, %sp

	# {end.done}
	jmp .done

.path_pass:
	# {{{ lookup dentry
	xor %ax, %ax
	push %si
	push %ax
	call strlen
	add $0x04, %sp

	push %ax # [s.0:strlen]
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
	mov %ax, %bx
	mov %dx, %es
	pop %cx # [s.0:strlen]

	push %si # src_name
	push %cx # src_name_len
	mov $inode, %si
	mov I_FILE_SIZE_OFF(%si), %ax
	push %ax
	push %bx
	push %es
	call lookup_dentry
	add $0x0A, %sp

	# (lookup_dentry() == no_match)
	# ? {err} : off+=ax;{run}
	cmp $0x01, %ax
	je .err_file_no
	add %ax, %bx
	jmp .run
	# }}}

.run:
	# {err} (file_type != file)
	mov %es:DE_FILE_TYPE_OFF(%bx), %al
	cmp $0x80, %al
	jne .err_file_type

	# save inum
	mov (inum), %ax
	push %ax # s.1 inum_lo
	mov (inum+0x02), %ax
	push %ax # s.2 inum_hi
	push %bx # s.3 off

	# set inum
	mov %es:DE_INUM_OFF(%bx), %ax
	mov %ax, (inum)
	mov %es:DE_INUM_OFF+0x02(%bx), %ax
	mov %ax, (inum+0x02)

	push $inode
	push $inum
	call read_inode
	add $0x04, %sp

	mov $inode, %si
	mov I_FILE_SIZE_OFF(%si), %ax
	push %ax # s.4 file_size

	push $inode
	call set_dap_blk_lba
	add $0x02, %sp

	push $dap
	call read_disk
	add $0x02, %sp
	mov %ax, %bx
	mov %dx, %es

	# putns
	pop %cx # s.4 file_size
	push %cx
	push %bx
	push %es
	call putns
	add $0x06, %sp

	# restore
	pop %bx # s.3 off
	pop %ax # s.2 inum_hi
	mov %ax, (inum+0x02)
	pop %ax # s.1 inum_lo
	mov %ax, (inum)

	# {end.done}
	jmp .done

# {DONE}
.done:
	xor %ax, %ax
	jmp .epil

.exit:
	mov $0x01, %ax
	jmp .epil

.epil:
	pop %bx
	pop %di
	pop %si
	pop %es
	ret

# {ERR}
.err_arg_req:
	push $emsg_arg_req
	jmp .err_hdl

.err_inv_path:
	push $emsg_inv_path
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
