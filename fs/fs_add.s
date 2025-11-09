# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# [File System] Add file or directory

.include "chr.s"
.include "fs/fs.s"
.include "fs/ind.s"
.section .text
.code16
.global fs_add

# fs_add(ub8 *path, ub16 f_type)
# <ret> ax = {done:0, exit:1}
fs_add:
	push %bp
	mov %sp, %bp
	push %es
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
	# (fs_path() != neq_last) ? {err}
	cmp $0x02, %ax
	jne .err_name_dup
	# }}}

	push 0x06(%bp) # (f_type)
	call ind_add
	add $0x02, %sp
	# <dx:ax = inum_hi:inum_lo>

	push %ax # (inum_lo)
	push %dx # (inum_hi)
	push $fsp+FSP_OFF_TMP # (fsp &dst)
	call fsp_read
	add $0x06, %sp

	# { de_add
	mov $path_cv, %si
	mov (%si), %ax # pathc
	add %ax, %si
	add %ax, %si
	mov (%si), %ax # pathv[last]
	mov $path_sbuf, %si
	add $0x02, %si
	add %ax, %si # name

	push $fsp+FSP_OFF_DIR # (fsp &src)
	call disk_read_fsp
	add $0x02, %sp
	# <dx:ax = seg:off>
	mov %dx, %es
	mov %ax, %bx

	push 0x06(%bp) # (f_type)
	push %si # (&name)
	push $fsp+FSP_OFF_DIR # (fsp &src)
	push $fsp+FSP_OFF_TMP # (fsp &dst)
	call de_add
	add $0x08, %sp
	# <ax = rec_size>
	# }

	mov $fsp+FSP_OFF_DIR, %si
	mov FSP_OFF_F_SIZE(%si), %cx
	add %ax, %cx
	mov %cx, FSP_OFF_F_SIZE(%si)
	push %si # (fsp &src)
	call fsp_write
	add $0x02, %sp

	# { upd f_size if fsp_dir is fsp_cur, fsp_par
	mov $fsp+FSP_OFF_CUR, %si
	push FSP_OFF_INUM(%si)
	push FSP_OFF_INUM+0x02(%si)
	push $fsp+FSP_OFF_CUR
	call fsp_read
	add $0x06, %sp

	mov $fsp+FSP_OFF_PAR, %si
	push FSP_OFF_INUM(%si)
	push FSP_OFF_INUM+0x02(%si)
	push $fsp+FSP_OFF_PAR
	call fsp_read
	add $0x06, %sp
	# }

	# (f_type != dir) ? {done} : {add_dots}
	mov 0x06(%bp), %ax
	cmp $F_TYPE_DIR, %ax
	jne .done

	push $fsp+FSP_OFF_DIR # (fsp &src)
	push $fsp+FSP_OFF_TMP # (fsp &dst)
	call de_add_dots
	add $0x04, %sp
	jmp .done

# {DONE}
.exit:
	mov $0x01, %ax
	jmp .epil

.done:
	xor %ax, %ax
	jmp .epil

.epil:
	pop %bx
	pop %di
	pop %si
	pop %es
	pop %bp
	ret

# {ERR}
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
