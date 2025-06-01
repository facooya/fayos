# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Show file data

.include "fayfs/de.s"

.section .text
.code16
.global cmd_cat

# ENTRY
# cmd_cat()
cmd_cat:
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

	# read block
	call set_blk_lba
	call read_block
	mov $0x8000, %bx

.cmd_cat__cmp_name:
	# init
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

	# (name_len == 0) ? not_found_err
	test %cx, %cx
	jz .call_hdl_not_found_err

	# (arg_len != name_len) ? ne
	cmp %cx, %ax
	jne .cmd_cat__cmp_name_ne

	# set name ptr
	mov %bx, %di
	add $DE_NAME_OFF, %di

	# strncmp(src, dst, n)
	# ret: ax = true(0), false(1)
	push %cx
	push %di
	push %si
	call strncmp
	add $0x06, %sp

	# (ret_code == true) ? e : ne
	test %ax, %ax
	jz .cmd_cat__cmp_name_e
	jmp .cmd_cat__cmp_name_ne

.cmd_cat__cmp_name_e:
	# get file_type
	mov DE_FILE_TYPE_OFF(%bx), %al

	# (file_type != file) ? err
	cmp $0x80, %al
	jne .call_hdl_not_file_err

	call outnl

	# save
	mov (i_num), %ax
	push %ax
	mov (i_num+0x02), %ax
	push %ax
	push %bx

	# set
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

	# done
	call outnl
	jmp .cmd_cat__done

.cmd_cat__cmp_name_ne:
	# add rec len
	mov DE_REC_LEN_OFF(%bx), %cx
	add %cx, %bx

	# step
	jmp .cmd_cat__cmp_name

.cmd_cat__done:
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

	jmp .cmd_cat__done

.call_hdl_not_file_err:
	call outnl
	call hdl_not_file_err
	call outnl

	jmp .cmd_cat__done
