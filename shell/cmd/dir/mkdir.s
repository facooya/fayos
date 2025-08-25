# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Command make directory

.include "chr.s"
.include "fayfs/dentry.s"
.include "fayfs/inode.s"
.section .text
.code16
.global cmd_mkdir

# cmd_mkdir()
cmd_mkdir:
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

	# (pathc == 1) ? {err}
	push %si # [s.1:raw_buf]
	push %cx # [s.0:proc_paths()]
	mov $paths, %si
	mov (%si), %ax
	cmp $0x01, %ax
	je .err_dir_root
	pop %cx # [s.0:proc_paths()]
	pop %si # [s.1:raw_buf]

	# (proc_paths() == 1) ? {err}
	cmp $0x01, %cx
	je .err_inv_path

	# (proc_paths() != 2) ? {err}
	cmp $0x02, %cx
	jne .err_name_dup

	mov %ax, %bx
	mov %dx, %es
	# }}}

	call add_inode

	# {{{ add dentry
	mov $paths, %si
	mov (%si), %cx # pathc
	add $0x02, %si
	add %cx, %si
	add %cx, %si
	sub $0x02, %si # pathv[last]

	mov (%si), %ax
	mov $path_buf, %si
	add $0x02, %si
	add %ax, %si

	xor %ax, %ax
	push %si
	push %ax
	call strlen
	add $0x04, %sp

	mov %al, %cl
	mov $0x40, %ch
	push %si
	push %cx
	push $path_inum
	push $tmp_inum
	call add_dentry
	add $0x08, %sp
	push %ax

	push $inode
	push $path_inum
	call read_inode
	add $0x04, %sp

	pop %ax
	mov $inode, %si
	mov I_FILE_SIZE_OFF(%si), %cx
	add %cx, %ax
	mov %ax, I_FILE_SIZE_OFF(%si)

	push $inode
	push $path_inum
	call update_inode
	add $0x04, %sp
	# }}}

	# {{{ add dot
	mov $de_dots, %si
	mov 0x02(%si), %cx
	push %si
	push %cx
	push $tmp_inum
	push $tmp_inum
	call add_dentry
	add $0x08, %sp
	push %ax

	push $inode
	push $tmp_inum
	call read_inode
	add $0x04, %sp

	pop %ax
	mov $inode, %si
	mov %ax, I_FILE_SIZE_OFF(%si)

	push $inode
	push $tmp_inum
	call update_inode
	add $0x04, %sp
	# }}}

	# {{{ add dentry dotdot
	mov $de_dots, %si
	add $0x04, %si
	mov 0x02(%si), %cx
	push %si
	push %cx
	push $tmp_inum
	push $path_inum
	call add_dentry
	add $0x08, %sp
	push %ax

	push $inode
	push $tmp_inum
	call read_inode
	add $0x04, %sp

	pop %cx
	mov $inode, %si
	mov I_FILE_SIZE_OFF(%si), %ax
	add %cx, %ax
	mov %ax, I_FILE_SIZE_OFF(%si)

	push $inode
	push $tmp_inum
	call update_inode
	add $0x04, %sp
	# }}}

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
	push %ax # file_size
	push %bx # *off
	push %es # *seg
	call lookup_dentry
	add $0x0A, %sp

	# (lookup_dentry() != 1) ? {err} : {run}
	cmp $0x01, %ax
	jne .err_name_dup
	jmp .run
	# }}}

# {TASK}
.run:
	call add_inode

	# {init} for add_dentry
	mov $args, %si
	mov 0x06(%si), %ax
	mov $raw_buf, %si
	add $0x02, %si
	add %ax, %si

	xor %ax, %ax
	push %si
	push %ax
	call strlen
	add $0x04, %sp

	# {{{ add directory
	mov %al, %cl
	mov $0x40, %ch
	push %si
	push %cx
	push $inum
	push $tmp_inum
	call add_dentry
	add $0x08, %sp
	push %ax

	push $inode
	push $inum
	call read_inode
	add $0x04, %sp

	pop %ax
	mov $inode, %si
	mov I_FILE_SIZE_OFF(%si), %cx
	add %cx, %ax
	mov %ax, I_FILE_SIZE_OFF(%si)

	push $inode
	push $inum
	call update_inode
	add $0x04, %sp
	# }}}

	# {{{ add dot
	mov $de_dots, %si
	mov 0x02(%si), %cx
	push %si
	push %cx
	push $tmp_inum
	push $tmp_inum
	call add_dentry
	add $0x08, %sp
	push %ax

	push $inode
	push $tmp_inum
	call read_inode
	add $0x04, %sp

	pop %ax
	mov $inode, %si
	mov %ax, I_FILE_SIZE_OFF(%si)

	push $inode
	push $tmp_inum
	call update_inode
	add $0x04, %sp
	# }}}

	# {{{ add dentry dotdot
	mov $de_dots, %si
	add $0x04, %si
	mov 0x02(%si), %cx
	push %si
	push %cx
	push $tmp_inum
	push $inum
	call add_dentry
	add $0x08, %sp
	push %ax

	push $inode
	push $tmp_inum
	call read_inode
	add $0x04, %sp

	pop %cx
	mov $inode, %si
	mov I_FILE_SIZE_OFF(%si), %ax
	add %cx, %ax
	mov %ax, I_FILE_SIZE_OFF(%si)

	push $inode
	push $tmp_inum
	call update_inode
	add $0x04, %sp
	# }}}

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

.err_dir_root:
	pop %si
	pop %cx
	push $emsg_dir_root
	jmp .err_hdl

.err_inv_path:
	push $emsg_inv_path
	jmp .err_hdl

.err_name_dup:
	push $emsg_name_dup
	jmp .err_hdl

.err_hdl:
	call outs
	add $0x02, %sp
	call outnl
	jmp .exit
