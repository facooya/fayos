# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Make directory

.include "fayfs/de.s"

.section .data

.name_dot: .ascii "."
.name_dotdot: .ascii ".."

.section .text
.code16
.global cmd_mkdir

# ENTRY
# cmd_mkdir()
cmd_mkdir:
	# prol
	push %si
	push %di
	push %bx

	# read inode
	mov (i_num), %ax
	push %ax
	mov (i_num+0x02), %ax
	push %ax
	call read_inode
	add $0x04, %sp

	# read block {dir}
	call set_blk_lba
	call read_block
	mov $0x8000, %bx

	# strlen(str)
	# ret: ax = len
	# cpy: dx = ax
	# mov (arg_ptr), %si
	mov $raw_buf, %si
	add $0x02, %si
	add (argv_1), %si
	push %si
	call strlen
	add $0x02, %sp
	mov %ax, %dx

.cmd_mkdir__cmp_name:
	# (mem >= i_file_size) ? main
	mov %bx, %cx
	sub $0x8000, %cx
	mov (i_file_size), %ax
	cmp %ax, %cx
	jge .cmd_mkdir__main

	# (arg_len != file_name_len) ? ne
	xor %cx, %cx
	mov DE_NAME_LEN_OFF(%bx), %cl
	cmp %cx, %dx
	jne .cmd_mkdir__ne

	# strncmp(src, dst, n)
	# ret: ax = true(0), false(1)
	push %dx
	push %cx # n
	mov %bx, %di
	add $DE_NAME_OFF, %di
	push %di # dst
	push %si # src
	call strncmp
	add $0x06, %sp
	pop %dx
	
	# (ret_code == true) ? err : ne
	test %ax, %ax
	jz .call_hdl_dup_err
	jmp .cmd_mkdir__ne

.cmd_mkdir__ne:
	# step
	mov DE_REC_LEN_OFF(%bx), %ax
	add %ax, %bx
	jmp .cmd_mkdir__cmp_name

.cmd_mkdir__main:
	call outnl

	# add inode
	mov $0x40, %ch
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

	# add dentry
	# mov (arg_ptr), %si
	mov $raw_buf, %si
	add $0x02, %si
	add (argv_1), %si
	push %si
	call strlen
	add $0x02, %sp
	# ax = len
	mov %al, %cl
	mov $0x40, %ch
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

	# add dentry dot
	mov $.name_dot, %si
	mov $0x01, %cl # name len
	mov $0x40, %ch
	push %si
	push %cx
	mov (next_i_num), %ax
	push %ax
	mov (next_i_num+0x02), %ax
	push %ax
	mov (next_i_num), %ax
	push %ax
	mov (next_i_num+0x02), %ax
	push %ax
	call add_dentry
	add $0x0C, %sp

	# add dentry dotdot
	mov $.name_dotdot, %si
	mov $0x02, %cl # name len
	mov $0x40, %ch
	push %si
	push %cx
	mov (i_num), %ax
	push %ax
	mov (i_num+0x02), %ax
	push %ax
	mov (next_i_num), %ax
	push %ax
	mov (next_i_num+0x02), %ax
	push %ax
	call add_dentry
	add $0x0C, %sp

	# update child i_file_size
	mov (dentry_ptr), %ax # HACK!!! dentry_ptr
	push %ax
	mov (next_i_num), %ax
	push %ax
	mov (next_i_num+0x02), %ax
	push %ax
	call update_i_file_size
	add $0x06, %sp

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
	call alloc_dentry

	# update i file_size # HACK!!! dentry_ptr
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

.cmd_mkdir__done:
	# epil
	pop %bx
	pop %di
	pop %si
	ret

.call_hdl_dup_err:
	call outnl
	call hdl_dup_err
	call outnl
	jmp .cmd_mkdir__done
