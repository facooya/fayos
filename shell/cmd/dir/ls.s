# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Command list - show file and directory list

.include "chr.s"
.include "fayfs/dentry.s"
.include "fayfs/inode.s"
.section .text
.code16
.global cmd_ls

# cmd_ls()
cmd_ls:
	push %es
	push %si
	push %di
	push %bx

	mov $args, %si
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
	je .err_dir_no

	mov %ax, %bx
	mov %dx, %es
	# }}}

	# {{{
	push $inode
	push $path_inum
	call read_inode
	add $0x04, %sp

	mov $inode, %si
	mov I_FILE_SIZE_OFF(%si), %dx
	push %dx

	push $inode
	call set_dap_blk_lba
	add $0x02, %sp

	push $dap
	call read_disk
	add $0x02, %sp
	mov %ax, %bx
	mov %dx, %es
	# }}}

	# {task}
	pop %dx # file_size
	jmp .run

.path_pass:
	# {{{
	push $inode
	push $inum
	call read_inode
	add $0x04, %sp

	mov $inode, %si
	mov I_FILE_SIZE_OFF(%si), %dx
	push %dx

	push $inode
	call set_dap_blk_lba
	add $0x02, %sp

	push $dap
	call read_disk
	add $0x02, %sp
	mov %ax, %bx
	mov %dx, %es
	# }}}

	# {task}
	pop %dx # file_size
	jmp .run

# {TASK}
.run:
.run__lp:
	# {chk} (inum == 0)
	mov %es:DE_INUM_OFF(%bx), %ax
	test %ax, %ax
	or %es:DE_INUM_OFF+0x02(%bx), %ax
	jz .run__lp_step

	# set name ptr
	mov %bx, %si
	add $DE_NAME_OFF, %si

	# get name len
	xor %cx, %cx
	mov %es:DE_NAME_LEN_OFF(%bx), %cl

.run__name_lp:
	# {end} (name_len == 0)
	test %cx, %cx
	jz .run__name_end

	# copy
	mov %es:(%si), %al
	call putc

	# {lp}
	add $0x01, %si
	sub $0x01, %cx
	jmp .run__name_lp

.run__name_end:
	call putsp
	call putsp

.run__lp_step:
	# add rec_len
	mov %es:DE_REC_LEN_OFF(%bx), %ax
	add %ax, %bx
	sub %ax, %dx # file_size--

	# {end.done} (file_size <= 0)
	cmp $0x00, %dx
	jle .done

	# {lp}
	jmp .run__lp

# {DONE}
.done:
	call putnl
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
.err_inv_path:
	push $emsg_inv_path
	jmp .err_hdl

.err_dir_no:
	push $emsg_dir_no
	jmp .err_hdl

.err_hdl:
	call outs
	add $0x02, %sp
	call outnl
	jmp .exit
