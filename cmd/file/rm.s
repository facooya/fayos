# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Remove File

.include "fayfs/de.s"

.section .text
.code16
.global cmd_rm

# ENTRY
# cmd_rm()
cmd_rm:
	# prol
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

	# read
	call set_blk_lba
	call read_block
	mov $0x8000, %bx

.cmd_rm__cmp_name:
	# set arg_ptr
	mov (arg_ptr), %si

	# strlen(str)
	# ret: ax = len
	push %si
	call strlen
	add $0x02, %sp

	# set name len
	xor %cx, %cx
	mov DE_NAME_LEN_OFF(%bx), %cl

	# cond: 0 ? done
	test %cx, %cx
	jz .call_hdl_not_found_err

	# cond: != ? cmp_name_ne
	cmp %cx, %ax
	jne .cmd_rm__cmp_name_ne

	# set name ptr
	mov %bx, %di
	add $DE_NAME_OFF, %di

	# cmp
	push %cx
	push %di
	push %si
	call strncmp
	add $0x06, %sp
	# ax = 0: true, 1: false

	# cond: true ? cmp_name_e
	test %ax, %ax
	jz .cmd_rm__cmp_name_e

	# ne
	jmp .cmd_rm__cmp_name_ne

.cmd_rm__cmp_name_e:
	# TODO chk file_type

	# load file_type
	mov DE_FILE_TYPE_OFF(%bx), %al
	
	# (file_type != file) ? err
	cmp $0x80, %al
	jne .call_hdl_not_file_err

	# rm i_num
	xor %ax, %ax
	mov %ax, DE_I_NUM_LO_OFF(%bx)
	mov %ax, DE_I_NUM_HI_OFF(%bx)

	# write
	call write_block

	# done
	call outnl
	jmp .cmd_rm__done

.cmd_rm__cmp_name_ne:
	# add rec len
	mov DE_REC_LEN_OFF(%bx), %cx
	add %cx, %bx

	# next name
	jmp .cmd_rm__cmp_name

.cmd_rm__done:
	# epil
	pop %bx
	pop %di
	pop %si
	ret

# ERR
.call_hdl_not_found_err:
	call outnl
	call hdl_not_found_err
	call outnl
	jmp .cmd_rm__done

.call_hdl_not_file_err:
	call outnl
	call hdl_not_file_err
	call outnl
	jmp .cmd_rm__done
	
