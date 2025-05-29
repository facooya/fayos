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
	add $0x02, %si
	mov (%si), %al

	# (redir_buf[off] == gt) ? type_write
	cmp $0x3E, %al
	je .exec_redir__type_write

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

	# (redir_name_len != de_name_len) ? ne
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
	# load file_type
	mov DE_FILE_TYPE_OFF(%bx), %al

	# (file_type != file) ? err : file_write
	cmp $0x80, %al
	jnz .call_hdl_not_file_err

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

	# init mem
	mov $0x8000, %bx

	# init
	# mov (arg_ptr), %si
	# TEST!!!
	mov $raw_buf, %si
	add $0x02, %si
	add (argv_1), %si
	jmp .exec_redir__file_write

.exec_redir__update_file_size:
	# strlen(str)
	# ret: ax = len
	# mov (arg_ptr), %si
	# TEST!!!
	mov $raw_buf, %si
	add $0x02, %si
	add (argv_1), %si
	push %si
	call strlen
	add $0x02, %sp

	# update_i_file_size
	push %ax
	mov (i_num), %ax
	push %ax
	mov (i_num+0x02), %ax
	push %ax
	call update_i_file_size
	add $0x06, %sp

	# done
	jmp .exec_redir__done

.exec_redir__cmp_name_ne:
	# add rec len
	mov DE_REC_LEN_OFF(%bx), %cx
	add %cx, %bx

	# step
	jmp .exec_redir__cmp_name

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
	# store tmp space
	mov $0x20, %al
	mov %al, (%bx)
	add $0x01, %bx

	# load
	add $0x01, %si
	mov (%si), %al

	# (chr != 0) ? file_write
	test %al, %al
	jnz .exec_redir__file_write

	# remove tmp space
	sub $0x01, %bx
	xor %al, %al
	mov %al, (%bx)

	# TODO update i_file_size

	# write block
	call set_blk_lba
	call write_block

	# done
	jmp .exec_redir__update_file_size

.exec_redir__done:
	# epil
	pop %bx
	pop %di
	pop %si
	ret

# ERR
.call_hdl_not_file_err:
	call outnl
	call hdl_not_file_err
	call outnl
	jmp .exec_redir__done
