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
	# }}}

# {TASK}
.run:
	# {err} (file_type != dir)
	mov DE_FILE_TYPE_OFF(%bx), %al
	cmp $0x40, %al
	jne .err_dir_type

	mov DE_INUM_LO_OFF(%bx), %ax
	mov %ax, (tmp_inum)
	mov DE_INUM_HI_OFF(%bx), %ax
	mov %ax, (tmp_inum+0x02)

	xor %ax, %ax
	mov %ax, DE_INUM_LO_OFF(%bx)
	mov %ax, DE_INUM_HI_OFF(%bx)

	# write
	push $dap
	call write_disk
	add $0x02, %sp

	mov $tmp_inode, %si
	push %si
	mov (tmp_inum), %ax
	push %ax
	mov (tmp_inum+0x02), %ax
	push %ax
	call read_inode
	add $0x06, %sp

	mov (tmp_inum), %ax
	push %ax
	mov (tmp_inum+0x02), %ax
	push %ax
	call clear_inode
	add $0x04, %sp

	# {{{ read sub
	mov I_FILE_SIZE_OFF(%si), %ax
	push %ax

	mov I_BLK_0_LO_OFF(%si), %ax
	push %ax
	mov I_BLK_0_HI_OFF(%si), %ax
	push %ax
	call set_dap_blk_lba
	add $0x04, %sp

	push $dap
	call read_disk
	add $0x02, %sp
	mov %ax, %bx
	# }}}

	# {end} (file_size <= 0)
	pop %dx
	sub $0x18, %dx # HACK: default dots
	cmp $0x00, %dx
	jle .run__end

	xor %cx, %cx # rm_rec_len
	mov $0x18, %cx # HACK: default dots

.run__lp:
	# TODO: bottom to up remove sequence
	mov DE_FILE_TYPE_OFF(%bx), %al
	cmp $0x80, %al
	je .run__rm_file

	cmp $0x40, %al
	je .run__rm_file

.run__rm_file:
	# {{{
	mov DE_REC_LEN_OFF(%bx), %ax
	push %ax

	push %cx # rm_rec_len++
	push %dx # file_size--

	mov DE_INUM_LO_OFF(%bx), %ax
	push %ax
	mov DE_INUM_HI_OFF(%bx), %ax
	push %ax

	xor %ax, %ax
	mov %ax, DE_INUM_LO_OFF(%bx)
	mov %ax, DE_INUM_HI_OFF(%bx)

	# write
	push $dap
	call write_disk
	add $0x02, %sp

	call clear_inode
	add $0x04, %sp
	pop %dx
	pop %cx
	# }}}

	pop %ax # rec_len
	sub %ax, %dx # file_size
	add %ax, %cx # rm_rec_len
	jmp .run__chk

.run__chk:
	# {end} (file_size <= 0)
	cmp $0x00, %dx
	jle .run__end

	push %cx
	push %dx
	push $dap
	call read_disk
	add $0x02, %sp
	mov %ax, %bx
	pop %dx
	pop %cx
	add %cx, %bx

	# {lp}
	jmp .run__lp

.run__end:
	mov (tmp_inum), %ax
	push %ax
	mov (tmp_inum+0x02), %ax
	push %ax
	call clear_inode
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
