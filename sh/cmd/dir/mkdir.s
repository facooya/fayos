# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# [Command] Make directory

.include "chr.s"
.include "fs/fs.s"
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
	mov $cl_lbuf, %si
	add $0x02, %si
	add %ax, %si # cl_lbuf[argv[1]]

	# (path_buf[0] != slash) ? {pass}
	mov (%si), %al
	cmp $CHR_SL, %al
	jne .path_pass

	# {{{ path
	push %si # (&name)
	push $fsp+FSP_OFF_PATH # (fsp &dst)
	call fs_path
	add $0x04, %sp
	# <ax = {done:0, exit:1, ne_last:2}>

	# (pathc == 1) ? {err}
	push %si # [s.1:cl_lbuf]
	push %ax # [s.0:fs_path()]
	mov $path_cv, %si
	mov (%si), %ax
	cmp $0x01, %ax
	je .err_dir_root
	pop %ax # [s.0:fs_path()]
	pop %si # [s.1:cl_lbuf]

	# (fs_path() == 1) ? {err}
	cmp $0x01, %ax
	je .err_inv_path

	# (fs_path() != 2) ? {err}
	cmp $0x02, %ax
	jne .err_name_dup
	# }}}

	call ind_add
	# <dx:ax = inum_hi:inum_lo>

	push %ax # (inum_lo)
	push %dx # (inum_hi)
	push $fsp+FSP_OFF_TMP # (fsp &dst)
	call fsp_read
	add $0x06, %sp

	# {{{ de add
	mov $path_cv, %si
	mov (%si), %cx # pathc
	add $0x02, %si
	add %cx, %si
	add %cx, %si
	sub $0x02, %si # pathv[last]

	mov (%si), %ax
	mov $path_sbuf, %si
	add $0x02, %si
	add %ax, %si

	push $fsp+FSP_OFF_PATH
	call disk_read_fsp
	add $0x02, %sp
	mov %dx, %es
	mov %ax, %bx

	push $0x40 # (f_type)
	push %si # (&name)
	push $fsp+FSP_OFF_PATH # (fsp &src)
	push $fsp+FSP_OFF_TMP # (fsp &dst)
	call de_add
	add $0x08, %sp
	# <ax = rec_size>

	mov $fsp+FSP_OFF_PATH, %si
	mov FSP_OFF_IND_FILE_SIZE(%si), %cx
	add %ax, %cx
	mov %cx, FSP_OFF_IND_FILE_SIZE(%si)
	push %si # (fsp &src)
	call fsp_write
	add $0x02, %sp

	push $fsp+FSP_OFF_PATH # (fsp &src)
	push $fsp+FSP_OFF_TMP # (fsp &dst)
	call de_add_dots
	add $0x04, %sp
	# }}}
	jmp .done

.path_pass:
	mov $fsp+FSP_OFF_CUR, %di
	push FSP_OFF_INUM(%di)
	push FSP_OFF_INUM+0x02(%di)
	push $fsp+FSP_OFF_CUR
	call fsp_read
	add $0x06, %sp

	push $fsp+FSP_OFF_CUR # (fsp &src)
	call disk_read_fsp
	add $0x02, %sp
	mov %dx, %es
	mov %ax, %bx

	# {{{ de seek
	push %si # (&name)
	push $fsp+FSP_OFF_CUR # (fsp &src)
	call de_seek
	add $0x04, %sp
	# <ax = true:off, false:1>

	# (de_seek() != false) ? {err} : {run}
	cmp $0x01, %ax
	jnz .err_name_dup
	jmp .run

.run:
	call ind_add
	# <dx:ax = inum_hi:inum_lo>

	push %ax # (inum_lo)
	push %dx # (inum_hi)
	push $fsp+FSP_OFF_TMP # (fsp &dst)
	call fsp_read
	add $0x06, %sp

	push $fsp+FSP_OFF_CUR # (fsp &src)
	push $fsp+FSP_OFF_TMP # (fsp &dst)
	call de_add_dots
	add $0x04, %sp

	mov $args, %si
	mov 0x06(%si), %ax
	mov $cl_lbuf, %si
	add $0x02, %si
	add %ax, %si

	mov $0x40, %ax
	push %ax # (f_type)
	push %si # (&name)
	push $fsp+FSP_OFF_CUR # (fsp &src)
	push $fsp+FSP_OFF_TMP # (fsp &dst)
	call de_add
	add $0x08, %sp
	# <ax = rec_size>

	mov $fsp+FSP_OFF_CUR, %si
	mov FSP_OFF_IND_FILE_SIZE(%si), %cx
	add %ax, %cx
	mov %cx, FSP_OFF_IND_FILE_SIZE(%si)
	push %si # (fsp &src)
	call fsp_write
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
	call vga_puts
	add $0x02, %sp
	mov $CHR_CR, %al
	call vga_putc
	mov $CHR_LF, %al
	call vga_putc
	jmp .exit
