# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Command change directory

.include "fayfs/dentry.s"
.section .text
.code16
.global cmd_cd

# cmd_cd()
cmd_cd:
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
	push $inum
	call lookup_dentry
	add $0x06, %sp

	# {err} (lookup_dentry == no_match)
	test %ax, %ax
	jz .err_dir_no

	# {task}
	mov %ax, %bx
	jmp .run
	# }}}

# {TASK}
.run:
	# {err} (file_type != dir)
	mov DE_FILE_TYPE_OFF(%bx), %al
	cmp $0x40, %al
	jne .err_dir_type

	# get dst inode num
	mov DE_INUM_OFF(%bx), %ax
	mov %ax, (inum)
	mov DE_INUM_OFF+0x02(%bx), %ax
	mov %ax, (inum+0x02)

	# get i blk
	mov $inode, %si
	push %si
	mov (inum), %ax
	push %ax
	mov (inum+0x02), %ax
	push %ax
	call read_inode
	add $0x06, %sp

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
	pop %si
	pop %di
	pop %bx
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
