# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Read superblock

.include "fayfs/sb.s"
.section .text
.code16
.global read_super

# read_super()
read_super:
	push %bx

	push $dap_super
	call read_disk
	add $0x02, %sp
	mov %ax, %bx

	# root inum
	mov FST_INUM_OFF(%bx), %ax
	mov %ax, (inum)

	# next_i_num
	mov NEXT_I_NUM_LO_OFF(%bx), %ax
	mov %ax, (next_i_num)

	# next_i_blk
	mov NEXT_I_BLK_LO_OFF(%bx), %ax
	mov %ax, (next_i_blk)

	pop %bx
	ret
