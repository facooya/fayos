# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Command remove directory

.include "chr.s"
.include "fs/fs.s"
.include "fs/de.s"
.section .text
.code16
.global cmd_rmdir

# cmd_rmdir()
cmd_rmdir:
	push %es
	push %si
	push %di
	push %bx

	mov $args, %di

	# (argc == 1) ? {err}
	mov (%di), %cx
	cmp $0x01, %cx
	je .err_arg_req
	add $0x06, %di # skip arg_c, opt_c, cmd
	dec %cx # tgt_c

.lp:
	# (tgt_c == 0) ? {done}
	test %cx, %cx
	jz .done

	mov (%di), %ax # argv[1+i]
	mov $cl_sbuf, %si
	add $0x02, %si
	add %ax, %si # cl_sbuf[argv[1+i]]

	# {{{ path
	push %cx # [s.f0:tgt_c]
	push %si # (&name)
	call fs_path
	add $0x02, %sp
	# <mod: (fsp &dir, &base)>
	# <ax = {done:0, exit:1, neq_last:2}>
	mov %ax, %dx
	pop %cx # [s.f0:tgt_c]

	# (pathc == 1) ? {err}
	mov $path_cv, %si
	mov (%si), %ax
	cmp $0x01, %ax
	je .single__chk
	jmp .single__ok

.single__chk:
	mov $path_sbuf, %si
	add $0x02, %si
	mov (%si), %ax
	cmp $0x002E, %ax
	je .err_dir_self
	cmp $0x2E2E, %ax
	je .single__chk_par
	jmp .single__ok
	# }}}

.single__chk_par:
	mov 0x02(%si), %al
	test %al, %al
	jz .err_dir_self
	jmp .single__ok

.single__ok:
	# (fs_path() == exit) ? {err}
	cmp $0x01, %dx
	je .err_inv_path
	# (fs_path() == neq_last) ? {err}
	cmp $0x02, %dx
	je .err_dir_no

	push %cx # [s.0:tgt_c]
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
	push $fsp+FSP_OFF_DIR # (fsp &src)
	call de_seek
	add $0x04, %sp
	# <ax = {eq:off, neq:1}>
	add %ax, %bx
	pop %cx # [s.0:tgt_c]

	# (f_type != dir) ? {err}
	mov %es:DE_OFF_F_TYPE(%bx), %al
	cmp $F_TYPE_DIR, %al
	jne .err_dir_type

	push %cx # [s.f0:tgt_c]
	push %si # (&name)
	push $fsp+FSP_OFF_DIR # (fsp &src)
	call fs_rm
	add $0x04, %sp
	pop %cx # [s.f0:tgt_c]

	add $0x02, %di
	dec %cx
	jmp .lp

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

.err_dir_self:
	push $emsg_dir_self
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
