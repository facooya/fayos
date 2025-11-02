# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Execute redirection

.include "chr.s"
.include "fs/fs.s"
.include "fs/de.s"
.include "fs/ind.s"
.include "fs/dentry.s"
.include "fs/inode.s"
.section .text
.code16
.global exec_redir

# exec_redir()
exec_redir:
	push %es
	push %si
	push %di
	push %bx

	# init
	mov $redir_buf, %si
	mov (%si), %ax # type:len
	add $0x02, %si

	xor %cx, %cx
	mov %al, %cl # buf.len

	# (redir_type == 1) ? {type.write} : {err}
	cmp $0x01, %ah # type
	je .type__write
	jmp .err_redir_type

# {TASK}
.type__write:
	# (path_buf[0] != slash) ? {pass}
	mov (%si), %al
	cmp $CHR_SL, %al
	jne .path_pass

	# {{{ path
	push %si # (&name)
	push $fsp+FSP_OFF_PATH # (fsp &dst)
	call fs_path
	add $0x04, %sp
	# <ax = {done:0, exit:1, ne_last:2}>

	# (fs_path() != done) ? {err}
	test %ax, %ax
	jnz .err_inv_path
	# }}}

	# TODO: file type chk

	xor %ax, %ax
	push $FSP_SIZE # (size)
	push $fsp+FSP_OFF_PATH # (&s_off)
	push %ax # (&s_seg)
	push $fsp+FSP_OFF_TMP # (&d_off)
	push %ax # (&d_seg)
	call mem_cpy
	add $0x0A, %sp

	push $fsp+FSP_OFF_TMP # (fsp &src)
	call disk_read_fsp
	add $0x02, %sp
	# <dx:ax = seg:off>
	mov %dx, %es
	mov %ax, %bx

	mov $fsp+FSP_OFF_TMP, %si
	mov FSP_OFF_IND_FILE_SIZE(%si), %cx # f_size
	xor %ax, %ax
	push %bx
	jmp .run

.path_pass:
	push $fsp+FSP_OFF_CUR # (fsp &src)
	call disk_read_fsp
	add $0x02, %sp
	# <dx:ax = seg:off>
	mov %ax, %bx
	mov %dx, %es

	# {{{ de_seek
	mov $redir_buf, %si
	mov (%si), %ax # type:len
	add $0x02, %si

	push %si # (&name)
	push $fsp+FSP_OFF_CUR # (fsp &src)
	call de_seek
	add $0x04, %sp
	# <ax = {true:off, false:1}>

	# (de_seek() == false) ? {err}
	cmp $0x01, %ax
	je .err_file_no
	add %ax, %bx
	# }}}

	# (file_type != file) ? {err} : {run}
	mov %es:DE_OFF_FILE_TYPE(%bx), %al
	cmp $0x80, %al
	jne .err_file_type

	mov %es:DE_OFF_INUM(%bx), %ax
	mov %es:DE_OFF_INUM+0x02(%bx), %dx
	push %ax
	push %dx
	push $fsp+FSP_OFF_TMP
	call fsp_read
	add $0x06, %sp

	push $fsp+FSP_OFF_TMP
	call disk_read_fsp
	add $0x02, %sp
	# <dx:ax = seg:off>
	mov %dx, %es
	mov %ax, %bx

	mov $fsp+FSP_OFF_TMP, %si
	mov FSP_OFF_IND_FILE_SIZE(%si), %cx
	xor %ax, %ax
	push %bx
	jmp .run

.run:
.run__clear_lp:
	# {end} (file_size <= 0)
	cmp $0x00, %cx
	jle .run__clear_end

	mov %ax, %es:(%bx)

	add $0x02, %bx
	sub $0x02, %cx
	jmp .run__clear_lp

.run__clear_end:
	pop %bx # s.1
	xor %dx, %dx # file_size
	mov $write_buf, %si
	mov (%si), %cx # buf.len
	add $0x02, %si # skip len

.run__write_lp:
	mov (%si), %al

	# (len == 0) ? {end}
	test %cx, %cx
	jz .run__write_end

	mov %al, %es:(%bx)

	add $0x01, %si # chr
	add $0x01, %bx # mem
	add $0x01, %dx # size
	sub $0x01, %cx # buf.len
	jmp .run__write_lp

.run__write_end:
	push %dx
	push $fsp+FSP_OFF_TMP
	call disk_write_fsp
	add $0x02, %sp
	pop %dx

.run__end:
	mov $fsp+FSP_OFF_TMP, %si
	mov %dx, FSP_OFF_IND_FILE_SIZE(%si)
	push $fsp+FSP_OFF_TMP # (fsp &src)
	call fsp_write
	add $0x02, %sp
	jmp .done

# {DONE}
.exit:
	mov $0x01, %ax
	jmp .done

.done:
	pop %bx
	pop %di
	pop %si
	pop %es
	ret

# {ERR}
.err_inv_path:
	push $emsg_inv_path
	jmp .err_hdl

.err_redir_type:
	push $emsg_redir_type
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
