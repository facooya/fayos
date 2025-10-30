# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Command touch - create file

.include "chr.s"
.include "drv/disk.s"
.include "fs/fs.s"
.include "fs/de.s"
.include "fs/dentry.s"
.include "fs/inode.s"
.include "fs/ind.s"
.section .text
.code16
.global cmd_touch

# cmd_touch()
cmd_touch:
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
	call fs_path
	add $0x02, %sp

	# (fs_path() == 1) ? {err}
	cmp $0x01, %cx
	je .err_inv_path

	# (fs_path() != 2) ? {err}
	cmp $0x02, %cx
	jne .err_name_dup

	mov %ax, %bx
	mov %dx, %es
	# }}}

	call ind_add
	# <dx:ax = inum_hi:inum_lo>

	push %ax # (inum_lo)
	push %dx # (inum_hi)
	push $fsp+FSP_OFF_TMP # (fsp &dst)
	call fsp_read
	add $0x06, %sp

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

	push %si
	mov $fsp+FSP_OFF_PATH, %si
	mov FSP_OFF_IND_FILE_SIZE(%si), %ax
	add %ax, %bx
	pop %si

	push $0x80 # (f_type)
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
	jmp .done

.path_pass:
	# TODO: delete
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
	# }}}

.run:
	call ind_add
	# <dx:ax = inum_hi:inum_lo>

	mov $fsp+FSP_OFF_TMP, %si
	push %ax # (inum_lo)
	push %dx # (inum_hi)
	push %si # (fsp &dst)
	call fsp_read
	add $0x06, %sp

	# {{{ add dentry
	mov $args, %si
	mov 0x06(%si), %ax
	mov $cl_lbuf, %si
	add $0x02, %si
	add %ax, %si

	mov $0x80, %ax
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

.err_name_dup:
	push $emsg_name_dup
	jmp .err_hdl

.err_inv_path:
	push $emsg_inv_path
	jmp .err_hdl

.err_hdl:
	call vga_puts
	add $0x02, %sp
	mov $CHR_CR, %al
	call vga_putc
	mov $CHR_LF, %al
	call vga_putc
	jmp .exit
