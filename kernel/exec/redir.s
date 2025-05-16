# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Execute redirection

.include "fayfs/de.s"

.section .text
.code16
.global exec_redir

# ENTRY
# exec_redir()
exec_redir:
	# prol
	push %si
	push %di
	push %bx

	# init
	mov $redir_buf, %si
	mov (%si), %al

	# (chr == gt) ? type_write
	cmp $0x3E, %al
	je .exec_redir__type_write

	# TODO: add chk type

	# done {escape}
	jmp .exec_redir__done

.exec_redir__type_write:
	# pre: al = gt
	
	# init
	add $0x02, %si

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

.exec_redir__cmp_name:
	# get redir name len
	# ret: ax = len
	push %si
	call strlen
	add $0x02, %sp

	# set dentry name len
	xor %cx, %cx
	mov DE_NAME_LEN_OFF(%bx), %cl

	# (de_name_len == 0) ? done
	test %cx, %cx
	jz .exec_redir__done

	# (redir_name_len != de_name_len) ? ne : name_cmp
	cmp %cx, %ax
	jne .exec_redir__cmp_name_ne

	# set name ptr
	mov %bx, %di
	add $DE_NAME_OFF, %di

	# cmp
	# ret: ax = true(0), false(1)
	push %cx
	push %di
	push %si
	call strncmp
	add $0x06, %sp

	# (cmp == true) ? e : ne
	test %ax, %ax
	jz .exec_redir__cmp_name_e
	jmp .exec_redir__cmp_name_ne

.exec_redir__cmp_name_e:
	# TODO chk file type, only file

	# get dst i num
	mov DE_I_NUM_LO_OFF(%bx), %ax
	mov %ax, (i_num)
	mov DE_I_NUM_HI_OFF(%bx), %ax
	mov %ax, (i_num+0x02)

	# read i node
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

	# init
	mov (arg_ptr), %si

.exec_redir__file_write:
	# load
	mov (%si), %al

	# (chr == 0) ? end
	test %al, %al
	jz .exec_redir__file_write_end

	# store
	mov %al, (%bx)

	# step
	add $0x01, %si
	add $0x01, %bx
	jmp .exec_redir__file_write

.exec_redir__file_write_end:
	# load
	add $0x01, %si
	mov (%si), %al

	# (chr != 0) ? file_write
	test %al, %al
	jnz .exec_redir__file_write

	# write block
	call write_block

	# done
	jmp .exec_redir__done

.exec_redir__cmp_name_ne:
	# add rec len
	mov DE_REC_LEN_OFF(%bx), %cx
	add %cx, %bx

	# step
	jmp .exec_redir__cmp_name

.exec_redir__done:
	# epil
	pop %bx
	pop %di
	pop %si
	ret
