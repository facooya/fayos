# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# [File System] Remove directory or file

.include "chr.s"
.include "fs/fs.s"
.include "fs/de.s"
.section .text
.code16
.global fs_rm

# fs_rm(ub8 *path, ub16 f_type)
# <ret> ax = {done:0, exit:1}
fs_rm:
	push %bp
	mov %sp, %bp
	push %si
	push %di
	push %bx

	# {{{ path
	push 0x04(%bp) # (&path)
	call fs_path
	add $0x02, %sp
	# <mod: (fsp &dir, &base)>
	# <ax = {done:0, exit:1, neq_last:2}>

	# (fs_path() == exit) ? {err}
	cmp $0x01, %ax
	je .err_inv_path
	# (fs_path() != neq_last) ? {pass}
	cmp $0x02, %ax
	jne .pass

	# (f_type == file) ? {err.file}
	mov 0x06(%bp), %ax
	cmp $F_TYPE_FILE, %ax
	je .err_file_no
	# (f_type == dir) ? {err.dir} : {err.path}
	cmp $F_TYPE_DIR, %ax
	je .err_dir_no
	jmp .err_inv_path
	# }}}

.err_type:
	mov 0x06(%bp), %ax
	cmp $F_TYPE_FILE, %ax
	je .err_file_type
	cmp $F_TYPE_DIR, %ax
	je .err_dir_type
	jmp .exit

.pass:
	xor %ax, %ax
	mov $fsp+FSP_OFF_BASE, %si
	mov FSP_OFF_F_TYPE(%si), %al
	mov 0x06(%bp), %cx
	cmp %ax, %cx
	jne .err_type

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
	add %ax, %si # name

	push %si # (&name)
	push $fsp+FSP_OFF_DIR # (fsp &src)
	call de_seek
	add $0x04, %sp
	# <ax = {true:off, false:1}>
	add %ax, %bx

	# (f_type == dir) ? {dir}
	mov %es:DE_OFF_F_TYPE(%bx), %al
	cmp $F_TYPE_DIR, %al
	je .dir__chk

	# (f_type == file) ? {file} : {exit}
	cmp $F_TYPE_FILE, %al
	je .file__rm
	jmp .exit

.file__rm:
	mov %es:DE_OFF_INUM(%bx), %ax
	mov %es:DE_OFF_INUM+0x02(%bx), %dx
	jmp .last__rm

.dir__chk:
	# (path_c == 1) ? {err}
	mov $path_cv, %si
	mov (%si), %ax
	cmp $0x01, %ax
	je .dir__dot_chk
	jmp .dir__down

.dir__dot_chk:
	mov $path_sbuf, %si
	add $0x02, %si
	mov (%si), %ax
	cmp $0x002E, %ax
	je .err_dir_self
	cmp $0x2E2E, %ax
	je .dir__dots_chk
	jmp .dir__down
	# }}}

.dir__dots_chk:
	mov 0x02(%si), %al
	test %al, %al
	jz .err_dir_self
	jmp .dir__down

.dir__down:
	mov $fsp+FSP_OFF_TMP, %si
	mov %es:DE_OFF_INUM(%bx), %ax
	mov %es:DE_OFF_INUM+0x02(%bx), %dx
	push %ax # (inum_lo)
	push %dx # (inum_hi)
	push %si # (fsp &dst)
	call fsp_read
	add $0x06, %sp

	push %si # (fsp &src)
	call disk_read_fsp
	add $0x02, %sp
	# <dx:ax = seg:off>
	mov %dx, %es
	mov %ax, %bx

	add $0x18, %bx
	mov $0x18, %cx

	mov FSP_OFF_F_SIZE(%si), %dx
	sub $0x18, %dx
	cmp $0x00, %dx
	jle .dir__rm
	jmp .dir__find_lp

.dir__find_lp:
	# (inum == 0) ? {step}
	mov %es:DE_OFF_INUM(%bx), %ax
	test %ax, %ax
	or %es:DE_OFF_INUM+0x02(%bx), %ax
	jz .dir__find_step

	# (f_type == dir) ? {chk}
	mov %es:DE_OFF_F_TYPE(%bx), %al
	cmp $F_TYPE_DIR, %al
	je .dir__find_chk
	jmp .dir__find_step

.dir__find_step:
	mov %es:DE_OFF_REC_SIZE(%bx), %ax
	add %ax, %bx # mem
	add %ax, %cx # rec_size

	# (file_size <= 0) ? {end} : {lp}
	sub %ax, %dx # f_size
	cmp $0x00, %dx
	jle .dir__rm
	jmp .dir__find_lp

.dir__find_chk:
	push %dx # [s.f0:f_size]
	push %cx # [s.f1:rec_size]
	mov %es:DE_OFF_INUM(%bx), %ax
	mov %es:DE_OFF_INUM(%bx), %dx
	push %ax # (inum_lo)
	push %dx # (inum_hi)
	push $fsp+FSP_OFF_BASE # (fsp &dst) HACK
	call fsp_read
	add $0x06, %sp
	pop %cx # [s.f1:rec_size]
	pop %dx # [s.f0:f_size]

	# (f_size == dots) ? {find_step} : {down_lp}
	mov $fsp+FSP_OFF_BASE, %di # HACK
	mov FSP_OFF_F_SIZE(%di), %ax
	cmp $0x18, %ax
	je .dir__find_step
	jmp .dir__down

.dir__rm:
	mov $fsp+FSP_OFF_TMP, %si
	push %si # (fsp &src)
	call disk_read_fsp
	add $0x02, %sp
	# <dx:ax = seg:off>
	mov %dx, %es
	mov %ax, %bx

	# { pre upd
	mov FSP_OFF_F_SIZE(%si), %dx
	mov $0x18, %ax
	mov %ax, FSP_OFF_F_SIZE(%si)

	push %ax # [s.f0:dots_size]
	push %dx # [s.f1:f_size]
	push %si # (fsp &src)
	call fsp_write
	add $0x02, %sp
	pop %dx # [s.f1:f_size]
	pop %ax # [s.f0:dots_size]
	# }

	mov %ax, %cx # pos = dots
	sub %ax, %dx # f_size - dots
	add %ax, %bx # mem + dots

.dir__rm_lp:
	# (inum == 0) ? {step}
	mov %es:DE_OFF_INUM(%bx), %ax
	test %ax, %ax
	or %es:DE_OFF_INUM+0x02(%bx), %ax
	jz .dir__rm_step

	push %cx # [s.0:rec_size]
	push %dx # [s.1:f_size]
	push %es:DE_OFF_INUM(%bx) # (inum_lo)
	push %es:DE_OFF_INUM+0x02(%bx) # (inum_hi)
	call ind_clr
	add $0x04, %sp

	# clr inum
	xor %ax, %ax
	mov %ax, %es:DE_OFF_INUM(%bx)
	mov %ax, %es:DE_OFF_INUM+0x02(%bx)

	push %si # (fsp &src)
	call disk_write_fsp
	add $0x02, %sp
	pop %dx # [s.1:f_size]
	pop %cx # [s.0:rec_size]

.dir__rm_step:
	mov %es:DE_OFF_REC_SIZE(%bx), %ax
	add %ax, %bx
	add %ax, %cx
	sub %ax, %dx

	# (f_size <= 0) ? {end} : {lp}
	cmp $0x00, %dx
	jle .dir__rm_end
	jmp .dir__rm_lp

.dir__rm_end:
	push $fsp+FSP_OFF_DIR # (fsp &src)
	call disk_read_fsp
	add $0x02, %sp
	# <dx:ax = seg:off>
	mov %dx, %es
	mov %ax, %bx

	mov $path_cv, %si
	mov (%si), %ax
	add %ax, %si
	add %ax, %si
	mov (%si), %ax
	mov $path_sbuf, %si
	add $0x02, %si
	add %ax, %si

	push %si # (&name)
	push $fsp+FSP_OFF_DIR # (fsp &src)
	call de_seek
	add $0x04, %sp
	# <ax = {true:off, false:1}>
	add %ax, %bx

	# (del_inum != sel_inum) ? {dir.down} : {clr}
	mov %es:DE_OFF_INUM(%bx), %ax
	mov %es:DE_OFF_INUM+0x02(%bx), %dx
	mov $fsp+FSP_OFF_TMP, %si
	mov FSP_OFF_INUM(%si), %cx
	cmp %ax, %cx
	jne .dir__down
	mov FSP_OFF_INUM+0x02(%si), %cx
	cmp %dx, %cx
	jne .dir__down

.last__rm:
	push %ax # (inum_lo)
	push %dx # (inum_hi)
	call ind_clr
	add $0x04, %sp

	# clr inum
	xor %ax, %ax
	mov %ax, %es:DE_OFF_INUM(%bx)
	mov %ax, %es:DE_OFF_INUM+0x02(%bx)

	push $fsp+FSP_OFF_DIR
	call disk_write_fsp
	add $0x02, %sp
	jmp .done

# {DONE}
.done:
	xor %ax, %ax # <ret.0:ret_code>
	jmp .epil

.exit:
	mov $0x01, %ax # <ret.1:ret_code>
	jmp .epil

.epil:
	pop %bx
	pop %di
	pop %si
	pop %bp
	ret

# {ERR}
.err_inv_path:
	push $emsg_inv_path
	jmp .err_hdl

.err_name_inv:
	push $emsg_name_inv
	jmp .err_hdl

.err_file_no:
	call ._err_print_name
	push $emsg_file_no
	jmp .err_hdl

.err_file_type:
	push $emsg_file_type
	jmp .err_hdl

.err_dir_no:
	call ._err_print_name
	push $emsg_dir_no
	jmp .err_hdl

.err_dir_type:
	push $emsg_dir_type
	jmp .err_hdl

.err_dir_self:
	push $emsg_dir_self
	jmp .err_hdl

.err_hdl:
	call vga_puts
	add $0x02, %sp
	mov $CHR_CR, %al
	call vga_putc
	mov $CHR_LF, %al
	call vga_putc
	jmp .exit

._err_print_name:
	mov $path_cv, %si
	mov (%si), %ax # pathc
	add %ax, %si
	add %ax, %si
	mov (%si), %ax # pathv[last]
	mov $path_sbuf, %si
	add $0x02, %si
	add %ax, %si # name

	xor %ax, %ax
	push %si # (&off)
	call vga_puts
	add $0x02, %sp

	mov $CHR_COL, %al
	call vga_putc
	mov $CHR_SP, %al
	call vga_putc
	ret
