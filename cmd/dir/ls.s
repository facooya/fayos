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
	# read_inode(inum_hi, inum_lo)
	mov (inum), %ax
	push %ax
	mov (inum+0x02), %ax
	push %ax
	call read_inode
	add $0x04, %sp

	mov $inode, %si
	mov I_BLK_0_LO_OFF(%si), %ax
	push %ax
	mov I_BLK_0_HI_OFF(%si), %ax
	push %ax
	call set_dap_blk_lba
	add $0x04, %sp

	push $dap
	call read_disk
	add $0x02, %sp
	mov %ax, %bx
	# }}}

	# {task}
	jmp .run

# {TASK}
.run:
.run__lp:
	# {chk} (inum == 0)
	mov DE_INUM_LO_OFF(%bx), %ax
	test %ax, %ax
	or %ax, DE_INUM_HI_OFF(%bx)
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
