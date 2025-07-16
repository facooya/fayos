# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Add inode in inode table

.include "fayfs/inode.s"
.section .text
.code16
.global add_inode

# add_inode()
# <ret> tmp_inum = allocated inum by add_inode()
add_inode:
	push %bx

	# {{{ alloc blknum
	push $dap_bb
	call read_disk
	add $0x02, %sp
	mov %ax, %bx

	push %bx
	call alloc_bit
	add $0x02, %sp
	push %ax
	# }}}

	# {{{ alloc inum
	push $dap_ib
	call read_disk
	add $0x02, %sp
	mov %ax, %bx

	push %bx
	call alloc_bit
	add $0x02, %sp
	push %ax
	# }}}

	# {{{ read/write inode table
	# read inode table
	push $dap_it
	call read_disk
	add $0x02, %sp
	mov %ax, %bx

	# calc inode # TODO: LO,HI
	xor %dx, %dx
	pop %ax # inum
	mov $I_SIZE, %cx
	mul %cx # ax *= cx
	add %ax, %bx # set mem

	# write blk # TODO: LO,HI
	pop %ax # blknum
	mov %ax, I_BLK_0_LO_OFF(%bx)

	# write inode table
	push $dap_it
	call write_disk
	add $0x02, %sp
	# }}}

	# {{{ set inum bit
	push $dap_ib
	call read_disk
	add $0x02, %sp
	mov %ax, %bx

	push %bx
	call alloc_bit
	add $0x02, %sp
	mov %ax, (tmp_inum)

	push %ax
	push %bx
	call set_bit
	add $0x04, %sp

	push $dap_ib
	call write_disk
	add $0x02, %sp
	# }}}

	# {{{ set blknum bit
	push $dap_bb
	call read_disk
	add $0x02, %sp
	mov %ax, %bx

	push %bx
	call alloc_bit
	add $0x02, %sp

	push %ax
	push %bx
	call set_bit
	add $0x04, %sp

	push $dap_bb
	call write_disk
	add $0x02, %sp
	# }}}

	pop %bx
	ret
