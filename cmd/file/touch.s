# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Command touch - create file

.include "fayfs/de.s"
.section .text
.code16
.global cmd_touch

# cmd_touch()
cmd_touch:
	push %si
	push %di
	push %bx

	# {{{ read block
	# read_inode(i_num_hi, i_num_lo)
	mov (i_num), %ax
	push %ax
	mov (i_num+0x02), %ax
	push %ax
	call read_inode
	add $0x04, %sp

	call set_blk_lba
	call read_block
	mov $0x8000, %bx
	# }}}

	# {{{ get arg_len
	mov $args, %si
	mov 0x06(%si), %ax # ax = argv[1]
	mov $raw_buf, %si
	add $0x02, %si
	add %ax, %si # si = raw_buf[argv[1]]

	# strlen(raw_buf[argv[1]])
	push %si
	call strlen
	add $0x02, %sp
	mov %ax, %dx
	# dx = arg_len
	# si = arg_name
	# }}}

.lp:
	# {{{ find free mem
	mov %bx, %cx
	sub $0x8000, %cx
	mov (i_file_size), %ax

	# {task} (mem >= i_file_size)
	cmp %ax, %cx
	jge .run
	# }}}

	# {{{ check file duplicate
	# {lp} (arg_len != file_name_len)
	xor %cx, %cx
	mov DE_NAME_LEN_OFF(%bx), %cl
	cmp %cx, %dx
	jne .lp_step

	# strncmp(arg_name, file_name, file_name_len)
	# ret: ax = true:0, false:1
	push %dx
	push %cx # file_name_len
	mov %bx, %di
	add $DE_NAME_OFF, %di
	push %di # file_name
	push %si # arg_name
	call strncmp
	add $0x06, %sp
	pop %dx

	# {err} (ret_code == true)
	test %ax, %ax
	jz .err_name_dup
	# }}}

.lp_step:
	mov DE_REC_LEN_OFF(%bx), %ax
	add %ax, %bx

	# {lp}
	jmp .lp

# {TASK}
.run:
	# {{{ add inode
	mov $0x80, %ch
	mov $0x01, %cl
	push %cx
	mov (next_i_blk), %ax
	push %ax
	mov (next_i_blk+0x02), %ax
	push %ax
	mov (next_i_num), %ax
	push %ax
	mov (next_i_num+0x02), %ax
	push %ax
	call add_inode
	add $0x0A, %sp
	# }}}

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

	mov %al, %cl
	mov $0x80, %ch
	push %si
	push %cx
	mov (next_i_num), %ax
	push %ax
	mov (next_i_num+0x02), %ax
	push %ax
	mov (i_num), %ax
	push %ax
	mov (i_num+0x02), %ax
	push %ax
	call add_dentry
	add $0x0C, %sp
	# }}}

	# update i file_size
	mov (dentry_ptr), %ax
	push %ax
	mov (i_num), %ax
	push %ax
	mov (i_num+0x02), %ax
	push %ax
	call update_i_file_size
	add $0x06, %sp

	# update sb
	mov (next_i_num), %ax
	add $0x01, %ax
	mov %ax, (next_i_num)
	mov (next_i_blk), %ax
	add $0x01, %ax
	mov %ax, (next_i_blk)
	call write_sb

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
