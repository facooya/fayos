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
	push %si
	push %di
	push %bx

	# {{{ lookup dentry
	mov $args, %si
	mov 0x06(%si), %ax # argv[1]
	mov $raw_buf, %si
	add $0x02, %si
	add %ax, %si # raw_buf[argv[1]]

	push %si # arg
	call strlen
	add $0x02, %sp
	mov %ax, %cx

	push %si # src_name
	push %cx # src_name_len
	mov (inum), %ax
	push %ax # inum_lo
	mov (inum+0x02), %ax
	push %ax # inum_hi
	call lookup_dentry
	add $0x08, %sp

	# {err} (lookup_dentry == no_match)
	test %ax, %ax
	jz .err_dir_no

	# {task}
	mov %ax, %bx # set mem
	jmp .run

.run:
	# {err} (file_type != dir)
	mov DE_FILE_TYPE_OFF(%bx), %al
	cmp $0x40, %al
	jne .err_dir_type

	mov DE_INUM_LO_OFF(%bx), %ax
	mov %ax, (rmdir_inum)
	mov DE_INUM_HI_OFF(%bx), %ax
	mov %ax, (rmdir_inum+0x02)

.run__lp:
	mov DE_INUM_LO_OFF(%bx), %ax
	push %ax
	mov DE_INUM_HI_OFF(%bx), %ax
	push %ax
	call get_bottom_dir
	add $0x04, %sp
	# <ret> dx:ax

	push %ax
	add $0x30, %al
	call outc
	pop %ax

	push %ax # lo
	push %dx # hi
	call rm_dir
	add $0x04, %sp

	jmp .done
	# }}}

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
	ret

# {TASK}
._dir_chk:
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
