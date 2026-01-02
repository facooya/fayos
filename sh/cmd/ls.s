# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# [Command] list - show file and directory list

.include "chr.inc"
.include "fs/fs.inc"
.include "fs/de.inc"
.section .text
.code16
.global cmd_ls

# cmd_ls()
cmd_ls:
	push %es
	push %si
	push %di
	push %bx

	mov $arg_ccv, %si

	# (argc == 1) ? {cmd_only}
	mov (%si), %ax # argc
	cmp $0x01, %ax
	je .cmd_only

	mov 0x06(%si), %ax # argv[1]
	mov $cl_sbuf, %si
	add $0x02, %si
	add %ax, %si # cl_sbuf[argv[1]]

	# {{{ path
	push %si # (&name)
	call path_parse
	add $0x02, %sp
	# <mod: (fsp &dir, &base)>
	# <ax = {done:0, exit:1, neq_last:2}>

	# (path_parse() == exit) ? {err}
	cmp $0x01, %ax
	je .err_inv_path
	# (path_parse() == neq_last) ? {err}
	cmp $0x02, %ax
	je .err_dir_no
	# }}}

	# (f_type != dir) ? {err}
	mov $fsp+FSP_OFF_BASE, %di
	mov FSP_OFF_F_TYPE(%di), %al
	cmp $F_TYPE_DIR, %al
	jne .err_dir_type

	push $fsp+FSP_OFF_BASE # (fsp &src)
	call disk_read_fsp
	add $0x02, %sp
	# <dx:ax = seg:off>
	mov %dx, %es
	mov %ax, %bx

	mov $fsp+FSP_OFF_BASE, %di
	mov FSP_OFF_F_SIZE(%di), %dx # f_size
	jmp .run

.cmd_only:
	push $fsp+FSP_OFF_CUR # (fsp &src)
	call disk_read_fsp
	add $0x02, %sp
	# <dx:ax = seg:off>
	mov %dx, %es
	mov %ax, %bx

	mov $fsp+FSP_OFF_CUR, %di
	mov FSP_OFF_F_SIZE(%di), %dx # f_size
	jmp .run

.run:
.run__lp:
	# (inum == 0) ? {chk}
	mov %es:DE_OFF_INUM(%bx), %ax
	test %ax, %ax
	jz .run__lp_step

	# set name ptr
	mov %bx, %si
	add $DE_OFF_NAME, %si

	# get name size
	xor %cx, %cx
	mov %es:DE_OFF_NAME_SIZE(%bx), %cl

.run__name_lp:
	# (name_size == 0) ? {end}
	test %cx, %cx
	jz .run__name_end

	# cpy
	mov %es:(%si), %al
	call putc

	inc %si
	dec %cx
	jmp .run__name_lp

.run__name_end:
	call putsp
	call putsp

.run__lp_step:
	# add rec_size
	mov %es:DE_OFF_REC_SIZE(%bx), %ax
	add %ax, %bx
	sub %ax, %dx # file_size--

	# (f_size <= 0) ? {done} : {lp}
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
