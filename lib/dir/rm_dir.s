# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Remove empty directory base inum

.include "fayfs/dentry.s"
.include "fayfs/inode.s"
.section .text
.code16
.global rm_dir

# rm_dir(inum_hi, inum_lo)
rm_dir:
	push %bp
	mov %sp, %bp
	push %si
	push %di
	push %bx

	mov $tmp_inode, %si
	push %si
	mov 0x06(%bp), %ax
	push %ax
	mov 0x04(%bp), %ax
	push %ax
	call read_inode
	add $0x06, %sp

	mov I_FILE_SIZE_OFF(%si), %dx
	push %dx

	mov $tmp_inode, %si
	mov $0x18, I_FILE_SIZE_OFF(%si)
	push %si
	mov 0x06(%bp), %ax
	push %ax
	mov 0x04(%bp), %ax
	push %ax
	call update_inode
	add $0x06, %sp

	push $tmp_inode
	call set_dap_blk_lba
	add $0x02, %sp

	push $dap
	call read_disk
	add $0x02, %sp

	pop %dx
	mov $0x18, %cx # rm_rec_len++
	sub $0x18, %dx # file_size--

.clear__lp:
	mov DE_INUM_OFF(%bx), %ax
	test %ax, %ax
	or DE_INUM_OFF+0x02(%bx), %ax
	jz .clear__lp_step

	push %cx
	push %dx

	mov DE_INUM_OFF(%bx), %ax
	push %ax
	mov DE_INUM_OFF+0x02(%bx), %ax
	push %ax

	xor %ax, %ax
	mov %ax, DE_INUM_OFF(%bx)
	mov %ax, DE_INUM_OFF+0x02(%bx)

	push $dap
	call write_disk
	add $0x02, %sp

	call clear_inode
	add $0x04, %sp

	pop %dx
	pop %cx

.clear__lp_step:
	mov DE_REC_LEN_OFF(%bx), %ax
	add %ax, %cx # rm_rec_len++
	sub %ax, %dx # file_size--

	# (file_size <= 0)
	cmp $0x00, %dx
	jle .clear__end

	push %cx
	push %dx
	push $dap
	call read_disk
	add $0x02, %sp
	mov %ax, %bx
	pop %dx
	pop %cx

	add %cx, %bx # rm_rec_len
	jmp .clear__lp

.clear__end:

# {DONE}
.done:
	xor %ax, %ax
	jmp .epil

.exit:
	mov $0x01, %ax
	jmp .epil

.epil:
	pop %bx
	pop %di
	pop %si
	pop %bp
	ret
