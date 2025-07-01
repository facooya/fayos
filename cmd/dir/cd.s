# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Command change directory

.include "fayfs/de.s"
.section .text
.code16
.global cmd_cd

# cmd_cd()
cmd_cd:
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

	# {{{ get arg
	mov $args, %si
	mov 0x06(%si), %ax # ax = argv[1]
	mov $raw_buf, %si
	add $0x02, %si
	add %ax, %si # si = raw_buf[argv[1]]

	# strlen(raw_buf[argv[1]]) <ret> ax = len
	push %si
	call strlen
	add $0x02, %sp
	mov %ax, %dx # arg_len
	# }}}

.lp:
	# {{{ set name len
	xor %cx, %cx
	mov DE_NAME_LEN_OFF(%bx), %cl

	# {err} (name_len == null)
	test %cx, %cx
	jz .err_dir_no

	# {lp} (arg_len != name_len)
	cmp %cx, %dx
	jne .lp_step
	# }}}

	# {{{
	mov %bx, %di
	add $DE_NAME_OFF, %di # name

	# strncmp(arg_name, name, name_len)
	# <ret> ax = true:0, false:1
	push %dx
	push %cx # name_len
	push %di # name
	push %si # arg_name
	call strncmp
	add $0x06, %sp
	pop %dx

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
	# {{{
	# load file_type
	mov DE_FILE_TYPE_OFF(%bx), %al

	# {err} (file_type != dir)
	cmp $0x40, %al
	jne .err_dir_type
	# }}}

	# get dst inode num
	mov DE_I_NUM_LO_OFF(%bx), %ax
	mov %ax, (i_num)
	mov DE_I_NUM_HI_OFF(%bx), %ax
	mov %ax, (i_num+0x02)

	# get i blk
	mov (i_num), %ax
	push %ax
	mov (i_num+0x02), %ax
	push %ax
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
