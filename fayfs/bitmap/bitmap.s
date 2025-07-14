# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Temporary related bitmap

.include "fayfs/sb.s"
.section .text
.code16
.global alloc_block_bitmap
.global alloc_inum_bitmap
.global set_block_bitmap
.global set_inum_bitmap
.global clear_block_bitmap
.global clear_inum_bitmap

# alloc_block_bitmap()
# <ret> dx:ax = free_block_number
alloc_block_bitmap:
	push %bx

	push $dap_bb
	call read_disk
	add $0x02, %sp
	mov %ax, %bx

	# <ret> ax = bitnum
	push %bx
	call alloc_bit
	add $0x02, %sp

	pop %bx
	ret

# alloc_inum_bitmap()
# <ret> dx:ax = free_inode_number
alloc_inum_bitmap:
	ret

# set_block_bitmap(free_block_num)
set_block_bitmap:
	ret

# set_inum_bitmap(free_inum)
set_inum_bitmap:
	ret
