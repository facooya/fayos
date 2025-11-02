# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# [Command] list - show file and directory list

.include "chr.s"
.include "fs/fs.s"
.include "fs/de.s"
.section .text
.code16
.global cmd_ls

# cmd_ls()
cmd_ls:
	push %es
	push %si
	push %di
	push %bx

	mov $args, %si
	mov 0x06(%si), %ax # argv[1]
	mov $cl_lbuf, %si
	add $0x02, %si
	add %ax, %si # cl_lbuf[argv[1]]

	# (path_buf[0] != slash) ? {pass}
	mov (%si), %al
	cmp $CHR_SL, %al
	jne .path_pass

	# {{{ path
	push %si # (&name)
	call fs_path
	add $0x02, %sp
	# <mod: (fsp &dir, &base)>
	# <ax = {done:0, exit:1, ne_last:2}>

	# (fs_path() == 1) ? {err}
	cmp $0x01, %ax
	je .err_inv_path

	# (fs_path() == 2) ? {err}
	cmp $0x02, %ax
	je .err_dir_no
	# }}}

	push $fsp+FSP_OFF_BASE # (fsp &src)
	call disk_read_fsp
	add $0x02, %sp
	# <dx:ax = seg:off>
	mov %dx, %es
	mov %ax, %bx

	mov $fsp+FSP_OFF_BASE, %di
	mov FSP_OFF_IND_FILE_SIZE(%di), %dx # f_size
	jmp .run

.path_pass:
	mov $fsp+FSP_OFF_CUR, %di
	push FSP_OFF_INUM(%di)
	push FSP_OFF_INUM+0x02(%di)
	push $fsp+FSP_OFF_CUR
	call fsp_read
	add $0x06, %sp

	push $fsp+FSP_OFF_CUR
	call disk_read_fsp
	add $0x02, %sp
	mov %dx, %es
	mov %ax, %bx

	mov FSP_OFF_IND_FILE_SIZE(%di), %dx # f_size

	# {{{ argc 1
	# (argc == 1) ? {run} : lookup_dentry()
	mov $args, %si
	mov (%si), %ax
	cmp $0x01, %ax
	je .run
	# }}}

	# {{{ de seek
	mov 0x06(%si), %ax # argv[1]
	mov $cl_lbuf, %si
	add $0x02, %si
	add %ax, %si

	push %si # (&name)
	push $fsp+FSP_OFF_CUR # (fsp &src)
	call de_seek
	add $0x04, %sp
	# <ax = {true:off, false:1}>

	# (de_seek() == false) ? {err}
	cmp $0x01, %ax
	je .err_dir_no
	add %ax, %bx
	# }}}

	# {{{ cl_lbuf[argv[1]]
	# (file_type != dir) ? {err}
	mov %es:DE_OFF_FILE_TYPE(%bx), %al
	cmp $0x40, %al
	jne .err_dir_type

	mov %es:DE_OFF_INUM(%bx), %ax
	mov %es:DE_OFF_INUM+0x02(%bx), %dx
	push %ax
	push %dx
	push $fsp+FSP_OFF_TMP
	call fsp_read
	add $0x06, %sp

	push $fsp+FSP_OFF_TMP
	call disk_read_fsp
	add $0x02, %sp
	# <dx:ax = seg:off>
	mov %dx, %es
	mov %ax, %bx

	mov $fsp+FSP_OFF_TMP, %si
	mov FSP_OFF_IND_FILE_SIZE(%si), %dx # f_size
	jmp .run
	# }}}

.run:
.run__lp:
	# (inum == 0) ? {chk}
	mov %es:DE_OFF_INUM(%bx), %ax
	test %ax, %ax
	or %es:DE_OFF_INUM+0x02(%bx), %ax
	jz .run__lp_step

	# set name ptr
	mov %bx, %si
	add $DE_OFF_NAME, %si

	# get name size
	xor %cx, %cx
	mov %es:DE_OFF_NAME_SIZE(%bx), %cl

.run__name_lp:
	# (name_len == 0) ? {end}
	test %cx, %cx
	jz .run__name_end

	# copy
	mov %es:(%si), %al
	call putc

	add $0x01, %si
	sub $0x01, %cx
	jmp .run__name_lp

.run__name_end:
	call putsp
	call putsp

.run__lp_step:
	# add rec_size
	mov %es:DE_OFF_REC_SIZE(%bx), %ax
	add %ax, %bx
	sub %ax, %dx # file_size--

	# (file_size <= 0) ? {done} : {lp}
	cmp $0x00, %dx
	jle .done
	jmp .run__lp

# {DONE}
.done:
	call putnl
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
	call vga_puts
	add $0x02, %sp
	mov $CHR_CR, %al
	call vga_putc
	mov $CHR_LF, %al
	call vga_putc
	jmp .exit
