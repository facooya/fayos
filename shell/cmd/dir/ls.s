# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Command list - show file and directory list

.include "fayfs/dentry.s"
.include "fayfs/inode.s"
.section .text
.code16
.global cmd_ls

# cmd_ls()
cmd_ls:
	push %si
	push %di
	push %bx

	# {{{
	push $inode
	push $inum
	call read_inode
	add $0x04, %sp

	mov $inode, %si
	mov I_FILE_SIZE_OFF(%si), %dx
	push %dx

	push $inode
	call set_dap_blk_lba
	add $0x02, %sp

	push $dap
	call read_disk
	add $0x02, %sp
	mov %ax, %bx
	mov %dx, %ds
	# }}}

	# {task}
	pop %dx # file_size
	jmp .run

# {TASK}
.run:
.run__lp:
	# {chk} (inum == 0)
	mov DE_INUM_OFF(%bx), %ax
	test %ax, %ax
	or DE_INUM_OFF+0x02(%bx), %ax
	jz .run__lp_step

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
	call putsp
	call putsp

.run__lp_step:
	# add rec_len
	mov DE_REC_LEN_OFF(%bx), %ax
	add %ax, %bx
	sub %ax, %dx # file_size--

	# {end.done} (file_size <= 0)
	cmp $0x00, %dx
	jle .done

	# {lp}
	jmp .run__lp

# {DONE}
.done:
	call putnl
	xor %ax, %ax
	mov %ax, %ds
	jmp .epli

.epli:
	pop %bx
	pop %di
	pop %si
	ret
