# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Command touch - create file

.include "fayfs/dentry.s"
.include "fayfs/inode.s"
.section .text
.code16
.global cmd_touch

# cmd_touch()
cmd_touch:
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

	# {err} (lookup_dentry != 0)
	test %ax, %ax
	jnz .err_name_dup

	# {task}
	jmp .run
	# }}}

# {TASK}
.run:
	call add_inode

	# {{{ add dentry
	mov $args, %si
	mov 0x06(%si), %ax
	mov $raw_buf, %si
	add $0x02, %si
	add %ax, %si
	push %si
	call strlen
	add $0x02, %sp
	# ax = len

	mov $0x80, %ch # (info) file_type
	mov %al, %cl # (info) name_len
	push %si # name
	push %cx # info

	mov (tmp_inum), %ax
	push %ax
	mov (tmp_inum+0x02), %ax
	push %ax

	mov (inum), %ax
	push %ax
	mov (inum+0x02), %ax
	push %ax
	call add_dentry
	add $0x0C, %sp
	push %ax
	# }}}

	mov $inode, %si
	push %si
	mov (inum), %ax
	push %ax
	mov (inum+0x02), %ax
	push %ax
	call read_inode
	add $0x06, %sp

	pop %ax
	mov I_FILE_SIZE_OFF(%si), %cx
	add %cx, %ax
	mov %ax, I_FILE_SIZE_OFF(%si)
	push %si
	mov (inum), %ax
	push %ax
	mov (inum+0x02), %ax
	push %ax
	call update_inode
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
	pop %bx
	pop %di
	pop %si
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
