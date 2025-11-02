# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Command remove directory

.include "chr.s"
.include "fs/fs.s"
.include "fs/de.s"
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

	# {{{ path
	push %si
	call fs_path
	add $0x02, %sp
	# <mod: (fsp &dir, &base)>
	# <ax = {done:0, exit:1, ne_last:2}>

	# (fs_path() != done) ? {err}
	test %ax, %ax
	jnz .err_inv_path

	# (pathc == 1) ? {err}
	mov $path_cv, %si
	mov (%si), %cx
	cmp $0x01, %cx
	je .err_dir_root
	# }}}

	push $fsp+FSP_OFF_DIR # (fsp &src)
	call disk_read_fsp
	add $0x02, %sp
	# <dx:ax = seg:off>
	mov %dx, %es
	mov %ax, %bx

	mov $path_cv, %si
	mov (%si), %ax # pathc
	add %ax, %si
	add %ax, %si
	mov (%si), %ax # pathv[last]
	mov $path_sbuf, %si
	add $0x02, %si
	add %ax, %si

	push %si # (&name)
	push $fsp+FSP_OFF_DIR # (fsp &dst)
	call de_seek
	add $0x04, %sp
	# <ax = {true:off, false:1}>
	add %ax, %bx

	# (file_type != dir) ? {err} : {run.lp}
	mov %es:DE_OFF_FILE_TYPE(%bx), %al
	cmp $0x40, %al
	jne .err_dir_type

	mov %es:DE_OFF_INUM(%bx), %ax
	mov %ax, (rmdir_inum)
	mov %es:DE_OFF_INUM+0x02(%bx), %ax
	mov %ax, (rmdir_inum+0x02)

.run__lp_p:
	push $rmdir_inum
	call get_bottom_dir
	add $0x02, %sp
	# <ret> tmp_inum

	push $tmp_inum
	call rm_dir
	add $0x02, %sp

	# (rmdir_inum != tmp_inum) ? {lp}
	mov (tmp_inum), %ax
	mov (rmdir_inum), %dx
	cmp %ax, %dx
	jne .run__lp_p
	mov (tmp_inum+0x02), %ax
	mov (rmdir_inum+0x02), %dx
	cmp %ax, %dx
	jne .run__lp_p

	mov $path_cv, %si
	mov (%si), %cx # pathc
	add %cx, %si
	add %cx, %si # pathv[last]

	mov (%si), %ax
	mov $path_sbuf, %si
	add $0x02, %si
	add %ax, %si
	jmp .run__end_path

.path_pass:
	# {{{ de_seek
	push $fsp+FSP_OFF_CUR # (fsp &src)
	call disk_read_fsp
	add $0x02, %sp
	# <dx:ax = seg:off>
	mov %dx, %es
	mov %ax, %bx

	push %si # (&name)
	push $fsp+FSP_OFF_CUR # (fsp &src)
	call de_seek
	add $0x04, %sp
	# <ax = {true:off, false:1}>
	add %ax, %bx

	# (de_seek() == no_match) ? {err}
	cmp $0x01, %ax
	je .err_dir_no

	xor %ax, %ax
	push $FSP_SIZE # (size)
	push $fsp+FSP_OFF_CUR # (&s_off)
	push %ax # (&s_seg)
	push $fsp+FSP_OFF_DIR # (&d_off)
	push %ax # (&d_seg)
	call mem_cpy
	add $0x0A, %sp

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
	mov %es:DE_OFF_FILE_TYPE(%bx), %al
	cmp $0x40, %al
	jne .err_dir_type
	jmp .run

.run:
	mov %es:DE_OFF_INUM(%bx), %ax
	mov %ax, (rmdir_inum)
	mov %es:DE_OFF_INUM+0x02(%bx), %ax
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
	push $fsp+FSP_OFF_DIR # (fsp &src)
	call disk_read_fsp
	add $0x02, %sp
	# <dx:ax = seg:off>
	mov %dx, %es
	mov %ax, %bx

	push %si # (&name)
	push $fsp+FSP_OFF_DIR # (fsp &src)
	call de_seek
	add $0x04, %sp
	# <ax = {true:off, false:1}>
	add %ax, %bx

	# (de_seek() == false) ? {err}
	cmp $0x01, %ax
	je .err_inv_path

	mov %es:DE_OFF_INUM(%bx), %ax
	mov %ax, (clear_inum)
	mov %es:DE_OFF_INUM+0x02(%bx), %ax
	mov %ax, (clear_inum+0x02)

	# clear inum
	xor %ax, %ax
	mov %ax, %es:DE_OFF_INUM(%bx)
	mov %ax, %es:DE_OFF_INUM+0x02(%bx)

	push $fsp+FSP_OFF_DIR # (fsp &src)
	call disk_write_fsp
	add $0x02, %sp

	push $clear_inum
	call ind_clr
	add $0x02, %sp

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
