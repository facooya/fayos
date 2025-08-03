# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Command remove directory

.include "fayfs/dentry.s"
.include "fayfs/inode.s"
.section .text
.code16
.global cmd_rmdir

# cmd_rmdir()
cmd_rmdir:
	push %es
	push %si
	push %di
	push %bx

	# {{{ lookup dentry
	mov $args, %si
	mov 0x06(%si), %ax # argv[1]
	mov $raw_buf, %si
	add $0x02, %si
	add %ax, %si # raw_buf[argv[1]]

	# {{ fptr len
	push %es
	xor %ax, %ax
	mov %ax, %es

	push %si
	push %es
	call fptrlen
	add $0x04, %sp

	mov %ax, %cx
	pop %es
	# }}

	push %cx
	push $inode
	push $inum
	call read_inode
	add $0x04, %sp

	push $inode
	call set_dap_blk_lba
	add $0x02, %sp

	push $dap
	call read_disk
	add $0x02, %sp
	mov %ax, %bx
	mov %dx, %es
	pop %cx

	push %si # src_name
	push %cx # src_name_len
	mov $inode, %si
	mov I_FILE_SIZE_OFF(%si), %ax
	push %ax
	push %bx
	push %es
	call lookup_dentry
	add $0x0A, %sp
	add %ax, %bx # set mem

	# {err} (lookup_dentry() == no_match)
	cmp $0x01, %ax
	je .err_dir_no

	# {err} (file_type != dir)
	mov %es:DE_FILE_TYPE_OFF(%bx), %al
	cmp $0x40, %al
	jne .err_dir_type

	# {task}
	jmp .run

.run:
	mov %es:DE_INUM_OFF(%bx), %ax
	mov %ax, (rmdir_inum)
	mov %es:DE_INUM_OFF+0x02(%bx), %ax
	mov %ax, (rmdir_inum+0x02)

.run__lp:
	push $rmdir_inum
	call get_bottom_dir
	add $0x02, %sp
	# <ret> tmp_inum

	push $tmp_inum
	call rm_dir
	add $0x02, %sp

	# {lp} (rmdir_inum != tmp_inum)
	mov (tmp_inum), %ax
	mov (rmdir_inum), %dx
	cmp %ax, %dx
	jne .run__lp
	mov (tmp_inum+0x02), %ax
	mov (rmdir_inum+0x02), %dx
	cmp %ax, %dx
	jne .run__lp

	# {end}
	jmp .run__end

.run__end:
	# {{{ last remove
	mov $args, %si
	mov 0x06(%si), %ax # argv[1]
	mov $raw_buf, %si
	add $0x02, %si
	add %ax, %si # raw_buf[argv[1]]

	# {{
	push %es
	xor %ax, %ax
	mov %ax, %es

	push %si
	push %es
	call fptrlen
	add $0x04, %sp

	mov %ax, %cx
	pop %es
	# }}

	push %cx
	push $inode
	push $inum
	call read_inode
	add $0x04, %sp

	push $inode
	call set_dap_blk_lba
	add $0x02, %sp

	push $dap
	call read_disk
	add $0x02, %sp
	mov %ax, %bx
	mov %dx, %es
	pop %cx

	push %si # src_name
	push %cx # src_name_len
	mov $inode, %si
	mov I_FILE_SIZE_OFF(%si), %ax
	push %ax
	push %bx
	push %es
	call lookup_dentry
	add $0x0A, %sp
	add %ax, %bx # set mem

	xor %ax, %ax
	mov %ax, %es:DE_INUM_OFF(%bx)
	mov %ax, %es:DE_INUM_OFF+0x02(%bx)
	
	push $dap
	call write_disk
	add $0x02, %sp

	push $rmdir_inum
	call clear_inode
	add $0x02, %sp
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
.err_dir_no:
	push $emsg_dir_no
	jmp .err_hdl

.err_dir_type:
	push $emsg_dir_type
	jmp .err_hdl

.err_hdl:
	call outs
	add $0x02, %sp
	call outnl
	jmp .exit
