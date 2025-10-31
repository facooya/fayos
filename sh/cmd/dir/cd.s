# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Command change directory

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
	# <ax = ret_code>

	# (fs_path() != done) ? {err}
	test %ax, %ax
	jnz .err_inv_path
	# }}}

	# upd
	mov $fsp+FSP_OFF_PATH, %si
	push FSP_OFF_INUM(%si)
	push FSP_OFF_INUM+0x02(%si)
	push $fsp+FSP_OFF_CUR
	call fsp_read
	add $0x06, %sp

	call build_ps1_path
	jmp .ps

.path_pass:
	# {{{
	push $fsp+FSP_OFF_CUR # (fsp &src)
	call disk_read_fsp
	add $0x02, %sp
	mov %dx, %es
	mov %ax, %bx

	push %si # (&name)
	push $fsp+FSP_OFF_CUR # (fsp &src)
	call de_seek
	add $0x04, %sp
	# <ax = {true:off, false:1}>

	# (de_seek() == no_match)
	# ? {err} : off+=ax;{run}
	cmp $0x01, %ax
	je .err_dir_no
	add %ax, %bx
	# }}}

	# (file_type != dir) ? {err} : {run}
	mov %es:DE_OFF_FILE_TYPE(%bx), %al
	cmp $0x40, %al
	jne .err_dir_type

	# upd
	mov %es:DE_OFF_INUM(%bx), %ax
	mov %es:DE_OFF_INUM+0x02(%bx), %dx
	push %ax
	push %dx
	push $fsp+FSP_OFF_CUR
	call fsp_read
	add $0x06, %sp

	# {{{ add ps1 path
	mov $args, %si
	mov 0x06(%si), %ax # argv[1]
	mov $cl_lbuf, %si
	add $0x02, %si
	add %ax, %si # cl_lbuf[argv[1]]

	# (arg == dots) ? {sub}
	mov (%si), %ax
	cmp $0x2E2E, %ax
	je .ps__sub

	# (arg == dot) ? {pass}
	cmp $0x002E, %ax
	je .ps__pass

	push %si
	xor %ax, %ax
	push %ax
	call mem_size
	add $0x04, %sp

	push %ax
	push %si
	xor %ax, %ax
	push %ax
	call add_ps1_path
	add $0x06, %sp
	# }}}
	jmp .ps

.ps:
	# {{{ prompt
	mov $args, %si
	mov 0x06(%si), %ax # argv[1]
	mov $cl_lbuf, %si
	add $0x02, %si
	add %ax, %si # cl_lbuf[argv[1]]
	mov (%si), %ax

	# (arg == dots) ? {sub}
	cmp $0x2E2E, %ax
	je .ps__sub

	# (arg == dot) ? {pass} : {ps1}
	cmp $0x002E, %ax
	je .ps__pass
	jmp .ps__ps1

.ps__sub:
	call sub_ps1_path
	call build_ps1
	jmp .ps__pass

.ps__ps1:
	call build_ps1

.ps__pass:
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
