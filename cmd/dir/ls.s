# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Show list

.include "fayfs/de.s"

.section .text
.code16
.global cmd_ls

# ENTRY
# cmd_ls()
cmd_ls:
	# prol
	push %si
	push %di
	push %bx

	call outnl

	# read_inode(i_num_hi, i_num_lo)
	# ret: i_file_size
	# ret: i_blk
	mov (i_num), %ax
	push %ax
	mov (i_num+0x02), %ax
	push %ax
	call read_inode
	add $0x04, %sp

	# set blk lba
	call set_blk_lba

	# read block
	call read_block
	mov $0x8000, %bx

	# file_size count
	xor %dx, %dx

.cmd_ls__out_name:
	# load i_num_lo
	mov DE_I_NUM_LO_OFF(%bx), %ax

	# (i_num == 0) ? out_skip {skip}
	test %ax, %ax
	or %ax, DE_I_NUM_HI_OFF(%bx)
	jz .cmd_ls__out_skip

	# set name ptr
	mov %bx, %si
	add $DE_NAME_OFF, %si

	# get name len
	xor %cx, %cx
	mov DE_NAME_LEN_OFF(%bx), %cl

.cmd_ls__out_str:
	# cond: 0 ? out_str_end
	test %cx, %cx
	jz .cmd_ls__out_str_end

	# copy
	mov (%si), %al
	call outc # HACK

	# step
	add $0x01, %si
	sub $0x01, %cx
	jmp .cmd_ls__out_str

.cmd_ls__out_str_end:
	# add rec_len
	mov DE_REC_LEN_OFF(%bx), %ax
	add %ax, %bx
	add %ax, %dx

	# load file_size
	mov (i_file_size), %ax

	# (file_size <= count) ? done
	cmp %ax, %dx
	jge .cmd_ls__done

	# loop
	call outsp
	call outsp
	jmp .cmd_ls__out_name

.cmd_ls__out_skip:
	# add rec_len
	mov DE_REC_LEN_OFF(%bx), %ax
	add %ax, %bx
	add %ax, %dx

	# load file_size
	mov (i_file_size), %ax

	# (file_size <= count) ? done
	cmp %ax, %dx
	jge .cmd_ls__done

	# loop
	jmp .cmd_ls__out_name

.cmd_ls__done:
	call outnl

	# epil
	pop %bx
	pop %di
	pop %si
	ret
