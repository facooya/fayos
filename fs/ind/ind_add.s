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
# <ret> dx:ax = inum_hi:inum_lo
ind_add:
	push %es
	push %si
	push %bx

	# {{{ alloc blknum
	mov $(DISK_BBM_MEM>>0x10), %ax
	mov %ax, %es
	mov $(DISK_BBM_MEM&0xFFFF), %bx

	push $bbnum
	push %bx
	push %es
	call bm_alloc
	add $0x06, %sp
	# }}}

	# {{{ alloc inum
	mov $(DISK_IBM_MEM>>0x10), %ax
	mov %ax, %es
	mov $(DISK_IBM_MEM&0xFFFF), %bx

	push $ibnum
	push %bx
	push %es
	call bm_alloc
	add $0x06, %sp
	push %ax # [s.ret0:inum_lo]
	# }}}

	# {{{ read/write inode table
	mov $(DISK_IT_MEM>>0x10), %ax
	mov %ax, %es
	mov $(DISK_IT_MEM&0xFFFF), %bx

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
	mov $dpi, %si
	add $DPI_OFF_IT, %si
	push %si
	call disk_write_dp
	add $0x02, %sp
	# }}}

	# {{{ set inum bit
	mov $(DISK_IBM_MEM>>0x10), %ax
	mov %ax, %es
	mov $(DISK_IBM_MEM&0xFFFF), %bx

	push $ibnum
	push %bx
	push %es
	call bm_set
	add $0x06, %sp

	mov $dpi, %si
	add $DPI_OFF_IBM, %si
	push %si
	call disk_write_dp
	add $0x02, %sp
	# }}}

	# {{{ set blknum bit
	mov $(DISK_BBM_MEM>>0x10), %ax
	mov %ax, %es
	mov $(DISK_BBM_MEM&0xFFFF), %bx

	push $bbnum
	push %bx
	push %es
	call bm_set
	add $0x06, %sp

	mov $dpi, %si
	add $DPI_OFF_BBM, %si
	push %si
	call disk_write_dp
	add $0x02, %sp
	# }}}

	xor %dx, %dx # <ret:inum_hi>
	pop %ax # [s.ret0:inum_lo]

	pop %bx
	pop %si
	pop %es
	ret
