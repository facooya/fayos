# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Command change directory

.include "chr.s"
.include "fs/dentry.s"
.include "fs/inode.s"
.section .text
.code16
.global cmd_cd

# cmd_cd()
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
	call build_ps1_path
	jmp .run

.path_pass:
	# {{{ lookup dentry
	xor %ax, %ax
	push %si
	push %ax
	call mem_size
	add $0x04, %sp

	push %ax # [s.0:str_size]
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
	pop %cx # [s.0:str_size]

	push %cx # [s.0:str_size]
	push %si # src_name
	push %cx # src_name_len
	mov $inode, %si
	mov I_FILE_SIZE_OFF(%si), %ax
	push %ax
	push %bx
	push %es
	call lookup_dentry
	add $0x0A, %sp
	pop %cx # [s.0:str_size]

	# (lookup_dentry() == no_match)
	# ? {err} : off+=ax;{run}
	cmp $0x01, %ax
	je .err_dir_no
	add %ax, %bx
	# }}}

	# (file_type != dir) ? {err} : {run}
	mov %es:DE_FILE_TYPE_OFF(%bx), %al
	cmp $0x40, %al
	jne .err_dir_type

	# {{{ add ps1 path
	mov $args, %si
	mov 0x06(%si), %ax # argv[1]
	mov $cl_lbuf, %si
	add $0x02, %si
	add %ax, %si # cl_lbuf[argv[1]]

	# (arg == dots) ? {sub}
	mov (%si), %ax
	cmp $0x2E2E, %ax
	je .run__sub

	# (arg == dot) ? {pass}
	cmp $0x002E, %ax
	je .run__pass

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

	jmp .run

# {TASK}
.run:
	# {{{ prompt
	mov $args, %si
	mov 0x06(%si), %ax # argv[1]
	mov $cl_lbuf, %si
	add $0x02, %si
	add %ax, %si # cl_lbuf[argv[1]]
	mov (%si), %ax

	# (arg == dots) ? {sub}
	cmp $0x2E2E, %ax
	je .run__sub

	# (arg == dot) ? {pass} : {ps1}
	cmp $0x002E, %ax
	je .run__pass
	jmp .run__ps1

.run__sub:
	call sub_ps1_path
	call build_ps1
	jmp .run__pass

.run__ps1:
	call build_ps1

.run__pass:
	# }}}

	# get dest inode num
	mov %es:DE_INUM_OFF(%bx), %ax
	mov %ax, (inum)
	mov %es:DE_INUM_OFF+0x02(%bx), %ax
	mov %ax, (inum+0x02)

	# get i blk
	push $inode
	push $inum
	call ind_read_old
	add $0x04, %sp

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
