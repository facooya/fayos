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

	# {{{
	# read superblock LBA
	push $0x8000
	push $0x00
	push $0x02
	call set_dap_target
	add $0x06, %sp

	push $SB_LBA_LO
	push $SB_LBA_HI
	call set_dap_lba
	add $0x04, %sp

	call read_block
	call reset_dap_target
	mov $0x8000, %bx
	# }}}

	# root i_num
	mov ROOT_I_NUM_LO_OFF(%bx), %ax
	mov %ax, (i_num)
	mov ROOT_I_NUM_HI_OFF(%bx), %ax
	mov %ax, (i_num+0x02)

	# next_i_num
	mov NEXT_I_NUM_LO_OFF(%bx), %ax
	mov %ax, (next_i_num)
	mov NEXT_I_NUM_HI_OFF(%bx), %ax
	mov %ax, (next_i_num+0x02)

	# next_i_blk
	mov NEXT_I_BLK_LO_OFF(%bx), %ax
	mov %ax, (next_i_blk)
	mov NEXT_I_BLK_HI_OFF(%bx), %ax
	mov %ax, (next_i_blk+0x02)

	pop %bx
	ret
