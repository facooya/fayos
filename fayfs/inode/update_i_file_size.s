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
# inum_hi, inum_lo,
# i_file_size
# )
update_i_file_size:
	push %bp
	mov %sp, %bp
	push %bx

	push $dap_it
	call read_disk
	add $0x02, %sp
	mov %ax, %bx

	# calc inode # HACK!!!: only low
	xor %dx, %dx
	mov 0x06(%bp), %cx # inum_lo
	mov $I_SIZE, %ax
	mul %cx
	# ax *= cx

	add %ax, %bx # mem
	mov 0x08(%bp), %ax # file_size
	mov %ax, I_FILE_SIZE_OFF(%bx)

	push $dap_it
	call write_disk
	add $0x02, %sp

	pop %bx
	pop %bp
	ret
