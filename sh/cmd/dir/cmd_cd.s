# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# [Command] Change directory

.include "chr.s"
.include "fs/fs.s"
.include "fs/de.s"
.include "fs/ind.s"
.section .text
.code16
.global cmd_cd

# cmd_cd()
# <mod> fsp *cur
cmd_cd:
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
	mov $cl_sbuf, %si
	add $0x02, %si
	add %ax, %si # cl_sbuf[argv[1]]

	# {{{ path
	push %si # (&name)
	call fs_path
	add $0x02, %sp
	# <mod: (fsp &dir, &base)>
	# <ax = {done:0, exit:1, neq_last:2}>

	# (fs_path() == exit) ? {err}
	cmp $0x01, %ax
	je .err_inv_path
	# (fs_path() == neq_last) ? {err}
	cmp $0x02, %ax
	je .err_dir_no
	# }}}

	mov $fsp+FSP_OFF_BASE, %si

	# (f_type != dir) ? {err}
	mov FSP_OFF_F_TYPE(%si), %ax
	cmp $F_TYPE_DIR, %ax
	jne .err_dir_type

	push FSP_OFF_INUM(%si) # (inum_lo)
	push FSP_OFF_INUM+0x02(%si) # (inum_hi)
	push $fsp+FSP_OFF_CUR # (fsp &dst)
	call fsp_read
	add $0x06, %sp

	call ps1_build_path
	call ps1_build
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
