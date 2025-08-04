# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Command make directory

.include "fayfs/dentry.s"
.include "fayfs/inode.s"
.section .text
.code16
.global cmd_mkdir

# cmd_mkdir()
cmd_mkdir:
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

	# {{ len
	push %es
	xor %ax, %ax
	mov %ax, %es

	push %si
	push %es
	call strlen
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
	push %ax # file_size
	push %bx # *off
	push %es # *seg
	call lookup_dentry
	add $0x0A, %sp

	# {err} (lookup_dentry() != 1)
	cmp $0x01, %ax
	jne .err_name_dup

	# {task}
	jmp .run
	# }}}

# {TASK}
.run:
	call add_inode

	# {init} for add_dentry
	mov $args, %si
	mov 0x06(%si), %ax
	mov $raw_buf, %si
	add $0x02, %si
	add %ax, %si

	# {{{ len
	push %es
	xor %ax, %ax
	mov %ax, %es

	push %si
	push %es
	call strlen
	add $0x04, %sp
	pop %es
	# ax = len
	# }}}

	# {{{ add directory
	mov %al, %cl
	mov $0x40, %ch
	push %si
	push %cx
	push $tmp_inum
	push $inum
	call add_dentry
	add $0x08, %sp
	push %ax

	push $inode
	push $inum
	call read_inode
	add $0x04, %sp

	pop %ax
	mov $inode, %si
	mov I_FILE_SIZE_OFF(%si), %cx
	add %cx, %ax
	mov %ax, I_FILE_SIZE_OFF(%si)

	push $inode
	push $inum
	call update_inode
	add $0x04, %sp
	# }}}

	# {{{ add dot
	mov $de_dots, %si
	mov 0x02(%si), %cx
	push %si
	push %cx
	push $tmp_inum
	push $tmp_inum
	call add_dentry
	add $0x08, %sp
	push %ax

	push $inode
	push $tmp_inum
	call read_inode
	add $0x04, %sp

	pop %ax
	mov $inode, %si
	mov %ax, I_FILE_SIZE_OFF(%si)

	push $inode
	push $tmp_inum
	call update_inode
	add $0x04, %sp
	# }}}

	# {{{ add dentry dotdot
	mov $de_dots, %si
	add $0x04, %si
	mov 0x02(%si), %cx
	push %si
	push %cx
	push $inum
	push $tmp_inum
	call add_dentry
	add $0x08, %sp
	push %ax

	push $inode
	push $tmp_inum
	call read_inode
	add $0x04, %sp

	pop %cx
	mov $inode, %si
	mov I_FILE_SIZE_OFF(%si), %ax
	add %cx, %ax
	mov %ax, I_FILE_SIZE_OFF(%si)

	push $inode
	push $tmp_inum
	call update_inode
	add $0x04, %sp
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
.err_name_dup:
	push $emsg_name_dup
	jmp .err_hdl

.err_hdl:
	call outs
	add $0x02, %sp
	call outnl
	jmp .exit
