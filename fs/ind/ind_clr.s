# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# [Index Node] Clear index node

.include "drv/disk.s"
.include "fs/fs.s"
.include "fs/ind.s"
.section .text
.code16
.global ind_clr

# ind_clr(ub16 inum)
ind_clr:
	push %bp
	mov %sp, %bp
	push %es
	push %si
	push %bx

	# {{{ read/write inode table
	mov $(DISK_IT_MEM>>0x10), %ax
	mov %ax, %es
	mov $(DISK_IT_MEM&0xFFFF), %bx

	# calc inode
	xor %dx, %dx
	mov 0x04(%bp), %ax # (inum)
	mov $IND_SIZE, %cx
	mul %cx # ax *= cx
	add %ax, %bx # set mem

	# { clr blk
	# TODO: clear all block
	# clear_bit(mem, bitnum)
	mov %es:IND_OFF_BLK(%bx), %ax
	mov %ax, (bbnum)

	# clr blk
	xor %ax, %ax
	mov %ax, %es:IND_OFF_F_SIZE(%bx)
	mov %ax, %es:IND_OFF_BLK(%bx)
	# }

	mov $F_TYPE_RM, %ax
	mov %ax, %es:IND_OFF_F_TYPE(%bx)

	push $dpi+DPI_OFF_IT
	call disk_write_dpi
	add $0x02, %sp
	# } push bitnum

	# { clear block bit
	mov $(DISK_BBM_MEM>>0x10), %ax
	mov %ax, %es
	mov $(DISK_BBM_MEM&0xFFFF), %bx

	push $bbnum
	push %bx
	push %es
	call bm_clr
	add $0x06, %sp

	push $dpi+DPI_OFF_BBM
	call disk_write_dpi
	add $0x02, %sp
	# }}}

	# {{{ clear inum bit
	mov $(DISK_IBM_MEM>>0x10), %ax
	mov %ax, %es
	mov $(DISK_IBM_MEM&0xFFFF), %bx

	mov 0x04(%bp), %ax # (inum)
	mov %ax, (ibnum)
	push $ibnum
	push %bx
	push %es
	call bm_clr
	add $0x06, %sp

	push $dpi+DPI_OFF_IBM
	call disk_write_dpi
	add $0x02, %sp
	# }}}

	pop %bx
	pop %si
	pop %es
	pop %bp
	ret
