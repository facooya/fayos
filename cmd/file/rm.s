# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Command remove - remove file

.include "fayfs/de.s"
.section .text
.code16
.global cmd_rm

# cmd_rm()
cmd_rm:
	push %si
	push %di
	push %bx

	# {{{ read block
	# read_inode(i_num_hi, i_num_lo)
	# <ret> i_file_size, i_blk
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

	# {{{ get arg info
	# <ret> si = arg_name, dx = arg_len
	mov $args, %si
	mov 0x06(%si), %ax # ax = argv[1]
	mov $raw_buf, %si
	add $0x02, %si
	add %ax, %si # si = raw_buf[argv[1]]

	# strlen(raw_buf[argv[1]]) <ret> ax:len
	push %si
	call strlen
	add $0x02, %sp
	mov %ax, %dx # arg_len
	# }}}

.lp:
	# FIXME: touch abc def, rm def => file not found
	# {{{ set file_name_len
	xor %cx, %cx
	mov DE_NAME_LEN_OFF(%bx), %cl

	# {err} (file_name_len == null)
	test %cx, %cx
	jz .err_file_no
	# }}}

	# {lp} (arg_len != file_name_len)
	cmp %cx, %dx
	jne .lp_step

	# {{{ check file exists
	# set file_name
	mov %bx, %di
	add $DE_NAME_OFF, %di # file_name

	# strncmp(arg_name, file_name, file_name_len)
	# <ret> ax = true:0, false:1
	push %cx # file_name_len
	push %di # file_name
	push %si # arg_name
	call strncmp
	add $0x06, %sp

	# {task} (strncmp == true)
	test %ax, %ax
	jz .run
	# }}}

.lp_step:
	# {step} add rec len
	mov DE_REC_LEN_OFF(%bx), %cx
	add %cx, %bx

	# {lp}
	jmp .lp

# {TASK}
.run:
	# {{{ check file_type
	# load file_type
	mov DE_FILE_TYPE_OFF(%bx), %al
	
	# {err} (file_type != file)
	cmp $0x80, %al
	jne .err_file_type
	# }}}

	# {{{
	# FIXME: remove inode, dentry
	# remove i_num
	xor %ax, %ax
	mov %ax, DE_I_NUM_LO_OFF(%bx)
	mov %ax, DE_I_NUM_HI_OFF(%bx)

	# write
	call write_block
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
