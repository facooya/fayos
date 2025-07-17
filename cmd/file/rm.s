# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Command remove - remove file

.include "fayfs/dentry.s"
.section .text
.code16
.global cmd_rm

# cmd_rm()
cmd_rm:
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
	jz .err_file_no

	# {task}
	mov %ax, %bx # set mem
	jmp .run
	# }}}

# {TASK}
.run:
	# {err} (file_type != file)
	mov DE_FILE_TYPE_OFF(%bx), %al
	cmp $0x80, %al
	jne .err_file_type

	# {{{
	mov DE_INUM_LO_OFF(%bx), %ax
	push %ax
	mov DE_INUM_HI_OFF(%bx), %ax
	push %ax

	# remove inum
	xor %ax, %ax
	mov %ax, DE_INUM_LO_OFF(%bx)
	mov %ax, DE_INUM_HI_OFF(%bx)

	# write
	push $dap
	call write_disk
	add $0x02, %sp

	call clear_inode
	add $0x04, %sp
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
	ret

# {ERR}
.err_file_no:
	push $emsg_file_no
	jmp .err_hdl

.err_file_type:
	push $emsg_file_type
	jmp .err_hdl

.err_hdl:
	call outs
	add $0x02, %sp
	call outnl
	jmp .exit
