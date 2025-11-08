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

	# {{{ path
	push %si # (&name)
	call fs_path
	add $0x02, %sp
	# <mod: (fsp &dir, &base)>
	# <ax = {done:0, exit:1, neq_last:2}>
	mov %ax, %cx

	# (pathc == 1) ? {chk}
	mov $path_cv, %si
	mov (%si), %ax
	cmp $0x01, %ax
	je .single__chk
	jmp .single__ok

.single__chk:
	mov $path_sbuf, %si
	add $0x02, %si
	mov (%si), %al

	# (single_chr == slash) ? {err}
	cmp $CHR_SL, %al
	je .err_dir_root
	jmp .single__ok

.single__ok:
	# (fs_path() == exit) ? {err}
	cmp $0x01, %cx
	je .err_inv_path
	# (fs_path() != neq_last) ? {err}
	cmp $0x02, %cx
	jne .err_name_dup
	# }}}

	push $F_TYPE_DIR # (f_type)
	call ind_add
	add $0x02, %sp
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

	push $fsp+FSP_OFF_DIR
	call disk_read_fsp
	add $0x02, %sp
	mov %dx, %es
	mov %ax, %bx

	push $F_TYPE_DIR # (f_type)
	push %si # (&name)
	push $fsp+FSP_OFF_DIR # (fsp &src)
	push $fsp+FSP_OFF_TMP # (fsp &dst)
	call de_add
	add $0x08, %sp
	# <ax = rec_size>

	mov $fsp+FSP_OFF_DIR, %si
	mov FSP_OFF_F_SIZE(%si), %cx
	add %ax, %cx
	mov %cx, FSP_OFF_F_SIZE(%si)
	push %si # (fsp &src)
	call fsp_write
	add $0x02, %sp

	push $fsp+FSP_OFF_DIR # (fsp &src)
	push $fsp+FSP_OFF_TMP # (fsp &dst)
	call de_add_dots
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
