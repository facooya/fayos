# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# [Index Node] Add index node

.include "drv/disk.s"
.include "fs/ind.s"
.section .text
.code16
.global ind_add

# ind_add()
# <ret> tmp_inum = allocated inum by add_inode()
ind_add:
	push %es
	push %bx

	# {{{ alloc blknum
	push $DNUM_BBM
	call disk_read_sect
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
	push $DNUM_IBM
	call disk_read_sect
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
	push $DNUM_IT
	call disk_read_sect
	add $0x02, %sp
	mov %ax, %bx
	mov %dx, %es

	# calc inode # TODO: LO,HI
	xor %dx, %dx
	mov (ibnum), %ax
	mov $IND_SIZE, %cx
	mul %cx # ax *= cx
	add %ax, %bx # set mem

	# write blk # TODO: LO,HI
	mov (bbnum), %ax
	mov %ax, %es:IND_OFF_BLK_0(%bx)

	# write inode table
	push $DNUM_IT
	call disk_write_sect
	add $0x02, %sp
	# }}}

	# {{{ set inum bit
	push $DNUM_IBM
	call disk_read_sect
	add $0x02, %sp
	mov %ax, %bx
	mov %dx, %es

	push $ibnum
	push %bx
	push %es
	call set_bit
	add $0x06, %sp

	push $DNUM_IBM
	call disk_write_sect
	add $0x02, %sp
	# }}}

	# {{{ set blknum bit
	push $DNUM_BBM
	call disk_read_sect
	add $0x02, %sp
	mov %ax, %bx
	mov %dx, %es

	push $bbnum
	push %bx
	push %es
	call set_bit
	add $0x06, %sp

	push $DNUM_BBM
	call disk_write_sect
	add $0x02, %sp
	# }}}

	pop %bx
	pop %es
	ret
