# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Command remove directory

.include "chr.s"
.include "fs/dentry.s"
.include "fs/inode.s"
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

	# (argc == 1) ? {err}
	mov (%si), %ax
	cmp $0x01, %ax
	je .err_arg_req

	mov 0x06(%si), %ax # argv[1]
	mov $cl_lbuf, %si
	add $0x02, %si
	add %ax, %si # cl_lbuf[argv[1]]

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

	# (pathc == 1) ? {err}
	mov $paths, %si
	mov (%si), %cx
	cmp $0x01, %cx
	je .err_dir_root

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
	call ind_read_old
	add $0x04, %sp

	push $inode
	call set_dap_blk_lba
	add $0x02, %sp

	mov $dap, %bx
	push $0x08 # sect_cnt
	mov 0x08(%bx), %ax
	push %ax # lba_lo
	mov 0x0A(%bx), %ax
	push %ax # lba_hi
	mov 0x04(%bx), %ax
	push %ax # off
	mov 0x06(%bx), %ax
	push %ax # seg
	call ata_read_sect
	add $0x0A, %sp
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

	mov $args, %si
	mov 0x06(%si), %ax # argv[1]
	mov $cl_lbuf, %si
	add $0x02, %si
	add %ax, %si # cl_lbuf[argv[1]]

	# (arg == dots) ? {err}
	mov (%si), %ax
	cmp $0x2E2E, %ax
	je .err_inv_arg

	# (arg == dot) ? {err}
	cmp $0x002E, %ax
	je .err_inv_arg
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
	mov $cl_lbuf, %si
	add $0x02, %si
	add %ax, %si # cl_lbuf[argv[1]]

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
	call ind_read_old
	add $0x04, %sp

	push $inode
	call set_dap_blk_lba
	add $0x02, %sp

	mov $dap, %bx
	push $0x08 # sect_cnt
	mov 0x08(%bx), %ax
	push %ax # lba_lo
	mov 0x0A(%bx), %ax
	push %ax # lba_hi
	mov 0x04(%bx), %ax
	push %ax # off
	mov 0x06(%bx), %ax
	push %ax # seg
	call ata_read_sect
	add $0x0A, %sp
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

	mov $dap, %bx
	push $0x08 # sect_cnt
	mov 0x08(%bx), %ax
	push %ax # lba_lo
	mov 0x0A(%bx), %ax
	push %ax # lba_hi
	mov 0x04(%bx), %ax
	push %ax # off
	mov 0x06(%bx), %ax
	push %ax # seg
	call ata_write_sect
	add $0x0A, %sp

	push $rmdir_inum
	call ind_clr
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
.err_inv_arg:
	push $emsg_inv_arg
	jmp .err_hdl

.err_arg_req:
	push $emsg_arg_req
	jmp .err_hdl

.err_dir_root:
	push $emsg_dir_root
	jmp .err_hdl

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
	call vga_puts
	add $0x02, %sp
	mov $CHR_CR, %al
	call vga_putc
	mov $CHR_LF, %al
	call vga_putc
	jmp .exit
