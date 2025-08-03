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
	push %es
	push %bx

	# {{{ alloc blknum
	push $dap_bb
	call read_disk
	add $0x02, %sp
	mov %ax, %bx
	mov %dx, %es

	push $bbnum
	push %bx
	push %es
	call alloc_bit
	add $0x06, %sp
	# }}}

	# {{{ alloc inum
	push $dap_ib
	call read_disk
	add $0x02, %sp
	mov %ax, %bx
	mov %dx, %es

	push $ibnum
	push %bx
	push %es
	call alloc_bit
	add $0x06, %sp
	mov (ibnum), %ax
	mov %ax, (tmp_inum)
	# }}}

	# {{{ read/write inode table
	# read inode table
	push $dap_it
	call read_disk
	add $0x02, %sp
	mov %ax, %bx
	mov %dx, %es

	# calc inode # TODO: LO,HI
	xor %dx, %dx
	mov (ibnum), %ax
	mov $I_SIZE, %cx
	mul %cx # ax *= cx
	add %ax, %bx # set mem

	# write blk # TODO: LO,HI
	mov (bbnum), %ax
	mov %ax, %es:I_BLK_0_OFF(%bx)

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
	mov %dx, %es

	push $ibnum
	push %bx
	push %es
	call set_bit
	add $0x06, %sp

	push $dap_ib
	call write_disk
	add $0x02, %sp
	# }}}

	# {{{ set blknum bit
	push $dap_bb
	call read_disk
	add $0x02, %sp
	mov %ax, %bx
	mov %dx, %es

	push $bbnum
	push %bx
	push %es
	call set_bit
	add $0x06, %sp

	push $dap_bb
	call write_disk
	add $0x02, %sp
	# }}}

	pop %bx
	pop %es
	ret
