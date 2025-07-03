# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Command list - show file and directory list

.include "fayfs/de.s"

.section .text
.code16
.global cmd_ls

# cmd_ls()
cmd_ls:
	push %si
	push %di
	push %bx

	# {{{
	# read_inode(i_num_hi, i_num_lo)
	# ret: i_file_size
	# ret: i_blk
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

	# {task}
	jmp .run

# {TASK}
.run:
.run__lp:
	# {chk} (i_num == 0)
	mov DE_I_NUM_LO_OFF(%bx), %ax
	test %ax, %ax
	or %ax, DE_I_NUM_HI_OFF(%bx)
	jz .run__chk

	# set name ptr
	mov %bx, %si
	add $DE_NAME_OFF, %si

	# get name len
	xor %cx, %cx
	mov DE_NAME_LEN_OFF(%bx), %cl

.run__name_lp:
	# {end} (name_len == 0)
	test %cx, %cx
	jz .run__name_end

	# copy
	mov (%si), %al
	call putc

	# {lp}
	add $0x01, %si
	sub $0x01, %cx
	jmp .run__name_lp

.run__name_end:
	# add rec_len
	mov DE_REC_LEN_OFF(%bx), %ax
	add %ax, %bx

	# {end.done} (rec_len == null)
	test %ax, %ax
	jz .done

	# {lp}
	call putsp
	call putsp
	jmp .run__lp

.run__chk:
	# add rec_len
	mov DE_REC_LEN_OFF(%bx), %ax
	add %ax, %bx

	# {end.done} (rec_len == null)
	test %ax, %ax
	jz .done

	# {lp}
	jmp .run__lp

# {DONE}
.done:
	call putnl
	xor %ax, %ax
	jmp .epli

.epli:
	pop %bx
	pop %di
	pop %si
	ret
