# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025-2026 Facooya and Fanone Facooya

.include "chr.inc"
.include "fs/fs.inc"
.include "fs/de.inc"
.include "fs/ind.inc"
.section .text
.code16
.global cmd_cd

# cmd_cd()
# <mod: fsp *cur>
cmd_cd:
	push %es
	push %si
	push %di
	push %bx

	mov $arg_ccv, %si

	# (argc == 1) ? {err}
	mov (%si), %ax
	cmp $0x01, %ax
	je .err_arg_req

	mov 0x06(%si), %ax # argv[1]
	mov $cl_sbuf, %si
	add $0x02, %si
	add %ax, %si # cl_sbuf[argv[1]]

	# { path
	push %si # (&path)
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
	# }

	call cwd_build
	# <req: path_cv, path_sbuf>
	# <mod: cwd>

	# { %si
	mov $fsp+FSP_OFF_BASE, %si
	# (f_type != dir) ? {err}
	mov FSP_OFF_F_TYPE(%si), %al
	cmp $F_TYPE_DIR, %al
	jne .err_dir_type

	push FSP_OFF_INUM(%si) # (inum)
	push $fsp+FSP_OFF_CUR # (fsp &dst)
	call fsp_read
	add $0x04, %sp
	# }

	# { %si
	mov $fsp+FSP_OFF_DIR, %si
	push FSP_OFF_INUM(%si) # (inum)
	push $fsp+FSP_OFF_PAR # (fsp &dst)
	call fsp_read
	add $0x04, %sp
	# }

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
	call vga_outs
	add $0x02, %sp
	NEWLINE
	jmp .exit
