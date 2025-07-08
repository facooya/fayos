# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Add inode in inode table

.include "fayfs/sb.s"
.include "fayfs/i.s"
.section .text
.code16
.global add_inode

# add_inode(
# inum_hi, inum_lo,
# blk_num_hi, blk_num_lo,
# info (file_type:blk_len),
# )
add_inode:
	push %bp
	mov %sp, %bp
	push %bx

	push $dap_inode
	call read_disk
	add $0x02, %sp
	mov %ax, %bx

	# calc inode # FIXME!!! hi,lo
	xor %dx, %dx
	mov 0x06(%bp), %cx
	mov $I_SIZE, %ax
	mul %cx
	# ax *= cx

	# set mem
	add %ax, %bx

	# write i_blk
	mov 0x08(%bp), %ax
	mov %ax, I_BLK_HI_OFF(%bx)
	mov 0x0A(%bp), %ax
	mov %ax, I_BLK_LO_OFF(%bx)

	# write info
	mov 0x0C(%bp), %ax
	mov %ah, I_FILE_TYPE_OFF(%bx)
	mov %al, I_BLK_LEN_OFF(%bx)

	# write
	push $dap_inode
	call write_disk
	add $0x02, %sp

	pop %bx
	pop %bp
	ret
