# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Command remove directory

.include "chr.s"
.include "fayfs/dentry.s"
.include "fayfs/inode.s"
.section .text
.code16
.global cmd_rmdir

# cmd_rmdir()
cmd_rmdir:
	push %es
	push %si
	push %di
	push %bx

	mov $args, %si
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

	# (proc_paths() != done) ? {err}
	test %cx, %cx
	jnz .err_inv_path

	mov %ax, %bx
	mov %dx, %es
	# }}}

	# (file_type != dir) ? {err} : {run.lp}
	mov %es:DE_FILE_TYPE_OFF(%bx), %al
	cmp $0x40, %al
	jne .err_dir_type

	mov %es:DE_INUM_OFF(%bx), %ax
	mov %ax, (rmdir_inum)
	mov %es:DE_INUM_OFF+0x02(%bx), %ax
	mov %ax, (rmdir_inum+0x02)

.run__lp_p:
	push $rmdir_inum
	call get_bottom_dir
	add $0x02, %sp
	# <ret> tmp_inum

	push $tmp_inum
	call rm_dir
	add $0x02, %sp

	# {lp} (rmdir_inum != tmp_inum)
	mov (tmp_inum), %ax
	mov (rmdir_inum), %dx
	cmp %ax, %dx
	jne .run__lp_p
	mov (tmp_inum+0x02), %ax
	mov (rmdir_inum+0x02), %dx
	cmp %ax, %dx
	jne .run__lp_p

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

	jmp .run__end_path

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
	add %ax, %bx # set mem

	# (lookup_dentry() == no_match) ? {err}
	cmp $0x01, %ax
	je .err_dir_no
	# }}}

.chk_err:
	# (file_type != dir) ? {err} : {run}
	mov %es:DE_FILE_TYPE_OFF(%bx), %al
	cmp $0x40, %al
	jne .err_dir_type
	jmp .run

.run:
	mov %es:DE_INUM_OFF(%bx), %ax
	mov %ax, (rmdir_inum)
	mov %es:DE_INUM_OFF+0x02(%bx), %ax
	mov %ax, (rmdir_inum+0x02)

.run__lp:
	push $rmdir_inum
	call get_bottom_dir
	add $0x02, %sp
	# <ret> tmp_inum

	push $tmp_inum
	call rm_dir
	add $0x02, %sp

	# {lp} (rmdir_inum != tmp_inum)
	mov (tmp_inum), %ax
	mov (rmdir_inum), %dx
	cmp %ax, %dx
	jne .run__lp
	mov (tmp_inum+0x02), %ax
	mov (rmdir_inum+0x02), %dx
	cmp %ax, %dx
	jne .run__lp

	# {end}
	jmp .run__end

.run__end:
	# {{{ last remove
	mov $args, %si
	mov 0x06(%si), %ax # argv[1]
	mov $raw_buf, %si
	add $0x02, %si
	add %ax, %si # raw_buf[argv[1]]

	mov (inum), %ax
	mov %ax, (parent_path_inum)
	mov (inum+0x02), %ax
	mov %ax, (parent_path_inum+0x02)

.run__end_path:
	xor %ax, %ax
	push %si
	push %ax
	call strlen
	add $0x04, %sp

	push %ax # [s.0:strlen]
	push $inode
	push $parent_path_inum
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
	add %ax, %bx # set mem

	# (lookup_dentry() == false) ? {err}
	cmp $0x01, %ax
	je .err_inv_path

	xor %ax, %ax
	mov %ax, %es:DE_INUM_OFF(%bx)
	mov %ax, %es:DE_INUM_OFF+0x02(%bx)

	push $dap
	call write_disk
	add $0x02, %sp

	push $rmdir_inum
	call clear_inode
	add $0x02, %sp
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
.err_inv_path:
	push $emsg_inv_path
	jmp .err_hdl

.err_dir_no:
	push $emsg_dir_no
	jmp .err_hdl

.err_dir_type:
	push $emsg_dir_type
	jmp .err_hdl

.err_hdl:
	call outs
	add $0x02, %sp
	call outnl
	jmp .exit
