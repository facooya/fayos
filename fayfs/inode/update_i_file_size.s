# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Update file size in inode

.include "fayfs/sb.s"
.include "fayfs/i.s"
.section .text
.code16
.global update_i_file_size

# update_i_file_size(
# i_num_hi, i_num_lo,
# i_file_size
# )
update_i_file_size:
	push %bp
	mov %sp, %bp
	push %bx

	# read i tbl
	push $I_LBA_LO
	push $I_LBA_HI
	call set_dap_lba
	add $0x04, %sp

	call read_block
	mov $0x8000, %bx

	# calc inode # HACK!!!: only low
	xor %dx, %dx
	mov 0x06(%bp), %cx # i_num_lo
	mov $I_SIZE, %ax
	mul %cx
	# ax *= cx

	add %ax, %bx # mem
	mov 0x08(%bp), %ax # file_size
	mov %ax, I_FILE_SIZE_OFF(%bx)

	call write_block

	pop %bx
	pop %bp
	ret
