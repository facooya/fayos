# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Command concatenate - show file data

.include "fayfs/de.s"
.section .text
.code16
.global cmd_cat

# cmd_cat()
cmd_cat:
	push %si
	push %di
	push %bx

	# read_inode(i_num_hi, i_num_lo)
	# ret: i_file_size
	# ret: i_blk
	mov (i_num), %ax
	push %ax
	mov (i_num+0x02), %ax
	push %ax
	call read_inode
	add $0x04, %sp

	# read block
	call set_blk_lba
	call read_block
	mov $0x8000, %bx

.lp:
	# {init}
	mov $args, %si
	mov 0x06(%si), %ax
	mov $raw_buf, %si
	add $0x02, %si
	add %ax, %si

	# strlen(str)
	# ret: ax = len
	push %si
	call strlen
	add $0x02, %sp

	# set name len
	xor %cx, %cx
	mov DE_NAME_LEN_OFF(%bx), %cl

	# {err} (name_len == 0)
	test %cx, %cx
	jz .err_file_no

	# {lp.step} (arg_len != name_len)
	cmp %cx, %ax
	jne .lp_step

	# set name ptr
	mov %bx, %di
	add $DE_NAME_OFF, %di

	# {{{
	# strncmp(src, dst, n)
	# ret: ax = true:0, false:1
	push %cx
	push %di
	push %si
	call strncmp
	add $0x06, %sp

	# {end} (ret_code == true)
	test %ax, %ax
	jz .end
	# }}}

.lp_step:
	# add rec len
	mov DE_REC_LEN_OFF(%bx), %cx
	add %cx, %bx

	# {lp}
	jmp .lp

.end:
	# get file_type
	mov DE_FILE_TYPE_OFF(%bx), %al

	# {err} (file_type != file)
	cmp $0x80, %al
	jne .err_file_type

	# save i_num
	mov (i_num), %ax
	push %ax
	mov (i_num+0x02), %ax
	push %ax
	push %bx

	# set i_num
	mov DE_I_NUM_LO_OFF(%bx), %ax
	mov %ax, (i_num)
	mov DE_I_NUM_HI_OFF(%bx), %ax
	mov %ax, (i_num+0x02)

	# read_inode(i_num_hi, i_num_lo)
	# ret: i_file_size
	# ret: i_blk
	mov (i_num), %ax
	push %ax
	mov (i_num+0x02), %ax
	push %ax
	call read_inode
	add $0x04, %sp

	# read block
	call set_blk_lba
	call read_block
	mov $0x8000, %bx

	# puts
	push %bx
	call puts
	add $0x02, %sp

	# restore
	pop %bx
	pop %ax
	mov %ax, (i_num+0x02)
	pop %ax
	mov %ax, (i_num)

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
