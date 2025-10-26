# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Execute redirection

.include "chr.s"
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

	# {{{ proc paths
	push %si
	call proc_paths
	add $0x02, %sp

	# (proc_paths() != done) ? {err}
	test %cx, %cx
	jnz .err_inv_path

	mov %ax, %bx
	mov %dx, %es
	# }}}

	# (file_type != file) ? {err} : {run}
	mov %es:DE_FILE_TYPE_OFF(%bx), %al
	cmp $0x80, %al
	jne .err_file_type
	jmp .run

.path_pass:
	push $inode
	push $inum
	call ind_read_old
	add $0x04, %sp

	push $inode
	call set_dap_blk_lba
	add $0x02, %sp

	mov $dap, %bx
	push $0x08 # sect_cnt
	mov 0x08(%bx), %ax
	push %ax # lba_lo
	mov 0x0A(%bx), %ax
	push %ax # lba_hi
	mov 0x04(%bx), %ax
	push %ax # off
	mov 0x06(%bx), %ax
	push %ax # seg
	call ata_read_sect
	add $0x0A, %sp
	mov %ax, %bx
	mov %dx, %es

	mov $redir_buf, %si
	mov (%si), %ax # type:len
	add $0x02, %si

	xor %cx, %cx
	mov %al, %cl # buf.len

	# {{{ lookup dentry
	push %si # name
	push %cx # name_len
	mov $inode, %si
	mov I_FILE_SIZE_OFF(%si), %ax
	push %ax # file_size
	push %bx # start_off
	push %es
	call lookup_dentry
	add $0x0A, %sp

	# {err} (lookup_dentry() == no_match)
	cmp $0x01, %ax
	je .err_file_no

	add %ax, %bx
	# }}}

	# {err} (file_type != file)
	mov %es:DE_FILE_TYPE_OFF(%bx), %al
	cmp $0x80, %al
	jne .err_file_type

	# {task}
	jmp .run

# {TASK}
.run:
	# get dest i num
	mov %es:DE_INUM_OFF(%bx), %ax
	mov %ax, (inum)
	mov %es:DE_INUM_OFF+0x02(%bx), %ax
	mov %ax, (inum+0x02)

	# read i node
	push $inode
	push $inum
	call ind_read_old
	add $0x04, %sp

.run__p:
	push $inode
	call set_dap_blk_lba
	add $0x02, %sp

	mov $dap, %bx
	push $0x08 # sect_cnt
	mov 0x08(%bx), %ax
	push %ax # lba_lo
	mov 0x0A(%bx), %ax
	push %ax # lba_hi
	mov 0x04(%bx), %ax
	push %ax # off
	mov 0x06(%bx), %ax
	push %ax # seg
	call ata_read_sect
	add $0x0A, %sp
	mov %ax, %bx
	mov %dx, %es
	push %bx # s.1

	mov $inode, %si
	mov I_FILE_SIZE_OFF(%si), %cx
	xor %ax, %ax

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

	# {end} (len == 0)
	test %cx, %cx
	jz .run__write_end

	mov %al, %es:(%bx)

	# {lp}
	add $0x01, %si # chr
	add $0x01, %bx # mem
	add $0x01, %dx # size
	sub $0x01, %cx # buf.len
	jmp .run__write_lp

.run__write_end:
	push %dx
	mov $dap, %bx
	push $0x08 # sect_cnt
	mov 0x08(%bx), %ax
	push %ax # lba_lo
	mov 0x0A(%bx), %ax
	push %ax # lba_hi
	mov 0x04(%bx), %ax
	push %ax # off
	mov 0x06(%bx), %ax
	push %ax # seg
	call ata_write_sect
	add $0x0A, %sp
	pop %dx

.run__end:
	mov $inode, %si
	mov %dx, I_FILE_SIZE_OFF(%si)

	push $inode
	push $inum
	call ind_upd
	add $0x04, %sp

	# {end.done}
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
