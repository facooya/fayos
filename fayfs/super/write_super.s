# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Write superblock

.include "fayfs/sb.s"
.section .text
.code16
.global write_super

# write_super()
write_super:
	push %bx

	push $dap_super
	call read_disk
	add $0x02, %sp
	mov %ax, %bx

	# write inum
	mov (next_i_num), %ax
	mov %ax, NEXT_I_NUM_LO_OFF(%bx)

	# write iblk
	mov (next_i_blk), %ax
	mov %ax, NEXT_I_BLK_LO_OFF(%bx)

	# write
	push $dap_super
	call write_disk
	add $0x02, %sp

	pop %bx
	ret
