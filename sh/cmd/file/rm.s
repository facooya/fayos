# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Command remove - remove file

.include "chr.s"
.include "fs/dentry.s"
.include "fs/inode.s"
.section .text
.code16
.global cmd_rm

# cmd_rm()
cmd_rm:
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
	mov $raw_buf, %si
	add $0x02, %si
	add %ax, %si # raw_buf[argv[1]]

	# (path_buf[0] != slash) ? {pass}
	mov (%si), %al
	cmp $CHR_SL, %al
	jne .path_pass

	# {{{ proc paths
	push %si
	call proc_paths
	add $0x02, %sp

	# (proc_path() == 1) ? {err}
	cmp $0x01, %cx
	je .err_inv_path

	# (proc_path() == 2) ? {err}
	cmp $0x02, %cx
	je .err_file_no

	mov %ax, %bx
	mov %dx, %es
	# }}}

	# (file_type != file) ? {err}
	mov %es:DE_FILE_TYPE_OFF(%bx), %al
	cmp $0x80, %al
	jne .err_file_type

	# {{{ remove
	mov %es:DE_INUM_OFF(%bx), %ax
	mov %ax, (clear_inum)
	mov %es:DE_INUM_OFF+0x02(%bx), %ax
	mov %ax, (clear_inum+0x02)

	# clear inum
	xor %ax, %ax
	mov %ax, %es:DE_INUM_OFF(%bx)
	mov %ax, %es:DE_INUM_OFF+0x02(%bx)

	# write
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

	push $clear_inum
	call clear_inode
	add $0x02, %sp
	# }}}

	# {end.done}
	jmp .done

.path_pass:
	# {{{ lookup dentry
	xor %ax, %ax
	push %si
	push %ax
	call strlen
	add $0x04, %sp

	push %ax # [s.0:strlen]
	push $inode
	push $inum
	call read_inode
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
	pop %cx # [s.0:strlen]

	push %si # src_name
	push %cx # src_name_len
	mov $inode, %si
	mov I_FILE_SIZE_OFF(%si), %ax
	push %ax
	push %bx
	push %es
	call lookup_dentry
	add $0x0A, %sp

	# (lookup_dentry() == no_match)
	# ? {err} : off+=ax;{run}
	cmp $0x01, %ax
	je .err_file_no
	add %ax, %bx
	jmp .run
	# }}}

# {TASK}
.run:
	# {err} (file_type != file)
	mov %es:DE_FILE_TYPE_OFF(%bx), %al
	cmp $0x80, %al
	jne .err_file_type

	# {{{
	mov %es:DE_INUM_OFF(%bx), %ax
	mov %ax, (clear_inum)
	mov %es:DE_INUM_OFF+0x02(%bx), %ax
	mov %ax, (clear_inum+0x02)

	# clear inum
	xor %ax, %ax
	mov %ax, %es:DE_INUM_OFF(%bx)
	mov %ax, %es:DE_INUM_OFF+0x02(%bx)

	# write
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

	push $clear_inum
	call clear_inode
	add $0x02, %sp
	# }}}

	# {end.done}
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
