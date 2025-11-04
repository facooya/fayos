# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Command remove - remove file

.include "chr.s"
.include "fs/fs.s"
.include "fs/de.s"
.section .text
.code16
.global cmd_rm

# cmd_rm()
cmd_rm:
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
	call fs_path
	add $0x02, %sp
	# <mod: fsp &dir, fsp &base>
	# <ax = {done:0, exit:1, ne_last:2}>

	# (fs_path() == 1) ? {err}
	cmp $0x01, %ax
	je .err_inv_path

	# (fs_path() == 2) ? {err}
	cmp $0x02, %ax
	je .err_file_no
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

	push %si
	push $fsp+FSP_OFF_DIR
	call de_seek
	add $0x04, %sp
	# <ax = {true:off, false:1}>
	add %ax, %bx

	# (file_type != file) ? {err}
	mov %es:DE_OFF_FILE_TYPE(%bx), %al
	cmp $0x80, %al
	jne .err_file_type

	# {{{ remove
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

	push (clear_inum)
	push (clear_inum+0x02)
	call ind_clr
	add $0x04, %sp
	# }}}
	jmp .done

.path_pass:
	# {{{ de_seek
	push $fsp+FSP_OFF_CUR
	call disk_read_fsp
	add $0x02, %sp
	# <dx:ax = seg:off>
	mov %dx, %es
	mov %ax, %bx

	push %si # (&name)
	push $fsp+FSP_OFF_CUR # (fsp &src)
	call de_seek
	add $0x04, %sp

	# (de_seek() == false) ? {err} : {run}
	cmp $0x01, %ax
	je .err_file_no
	add %ax, %bx
	jmp .run
	# }}}

# {TASK}
.run:
	# (file_type != file) ? {err}
	mov %es:DE_OFF_FILE_TYPE(%bx), %al
	cmp $0x80, %al
	jne .err_file_type

	# {{{
	mov %es:DE_OFF_INUM(%bx), %ax
	mov %ax, (clear_inum)
	mov %es:DE_OFF_INUM+0x02(%bx), %ax
	mov %ax, (clear_inum+0x02)

	# clear inum
	xor %ax, %ax
	mov %ax, %es:DE_OFF_INUM(%bx)
	mov %ax, %es:DE_OFF_INUM+0x02(%bx)

	# write
	push $fsp+FSP_OFF_CUR
	call disk_write_fsp
	add $0x02, %sp

	push (clear_inum)
	push (clear_inum+0x02)
	call ind_clr
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
	call vga_puts
	add $0x02, %sp
	mov $CHR_CR, %al
	call vga_putc
	mov $CHR_LF, %al
	call vga_putc
	jmp .exit
