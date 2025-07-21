# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Get bottom directory inum

.include "fayfs/dentry.s"
.include "fayfs/inode.s"
.section .text
.code16
.global get_bottom_dir

# get_bottom_dir(inum_hi, inum_lo)
# <ret> dx:ax bottom dir inum
get_bottom_dir:
	push %bp
	mov %sp, %bp
	push %si
	push %di
	push %bx

	mov 0x06(%bp), %ax
	mov %ax, (tmp_inum)
	mov 0x04(%bp), %ax
	mov %ax, (tmp_inum+0x02)

.down__lp:
	mov $tmp_inode, %si
	push %si
	mov (tmp_inum), %ax
	push %ax
	mov (tmp_inum+0x02), %ax
	push %ax
	call read_inode
	add $0x06, %sp

	mov I_FILE_SIZE_OFF(%si), %dx
	push %dx

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

	add $0x18, %bx
	mov $0x18, %cx # rm_rec_len++
	pop %dx # file_size--

	# {end} (file_size <= 0)
	sub $0x18, %dx
	cmp $0x00, %dx
	jle .down__end

.find__lp:
	# {step} (inum == 0)
	mov DE_INUM_LO_OFF(%bx), %ax
	test %ax, %ax
	or DE_INUM_HI_OFF(%bx), %ax
	jz .find__lp_step

	# (file_type == dir)
	mov DE_FILE_TYPE_OFF(%bx), %al
	cmp $0x40, %al
	je .find__chk

.find__lp_step:
	mov DE_REC_LEN_OFF(%bx), %ax
	add %ax, %bx

	add %ax, %cx # rm_rec_len++

	# {end} (file_size <= 0)
	sub %ax, %dx # file_size--
	cmp $0x00, %dx
	jle .down__end

	# {lp}
	jmp .find__lp

.find__chk:
	push %dx
	push %cx

	mov $tmp_inode, %si
	push %si
	mov DE_INUM_LO_OFF(%bx), %ax
	mov %ax, (tmp_dir_inum)
	push %ax
	mov DE_INUM_HI_OFF(%bx), %ax
	mov %ax, (tmp_dir_inum+0x02)
	push %ax
	call read_inode
	add $0x06, %sp

	# (file_size == dots)
	mov I_FILE_SIZE_OFF(%si), %ax
	cmp $0x18, %ax
	je .find__continue
	jmp .down__continue

.find__continue:
	push $dap
	call read_disk
	add $0x02, %sp
	mov %ax, %bx

	pop %cx # rm_rec_len++
	pop %dx # file_size--

	add %cx, %bx
	jmp .find__lp_step

.down__continue:
	pop %ax # rm_rec_len++
	pop %ax # file_size--

	mov (tmp_dir_inum), %ax
	mov %ax, (tmp_inum)
	mov (tmp_dir_inum+0x02), %ax
	mov %ax, (tmp_inum+0x02)

	jmp .down__lp

.down__end:
	jmp .done

# {DONE}
.done:
	mov (tmp_inum), %ax
	mov (tmp_inum+0x02), %dx
	jmp .epil

.epil:
	pop %bx
	pop %di
	pop %si
	pop %bp
	ret
