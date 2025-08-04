# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Command change directory

.include "fayfs/dentry.s"
.include "fayfs/inode.s"
.section .text
.code16
.global cmd_cd

# cmd_cd()
cmd_cd:
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
	push %ax
	push %bx
	push %es
	call lookup_dentry
	add $0x0A, %sp

	# {err} (lookup_dentry() == no_match)
	cmp $0x01, %ax
	je .err_dir_no

	add %ax, %bx

	# {task}
	jmp .run
	# }}}

# {TASK}
.run:
	# {err} (file_type != dir)
	mov %es:DE_FILE_TYPE_OFF(%bx), %al
	cmp $0x40, %al
	jne .err_dir_type

	# get dst inode num
	mov %es:DE_INUM_OFF(%bx), %ax
	mov %ax, (inum)
	mov %es:DE_INUM_OFF+0x02(%bx), %ax
	mov %ax, (inum+0x02)

	# get i blk
	push $inode
	push $inum
	call read_inode
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
