# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# [Index Node] Clear index node

.include "drv/disk.s"
.include "fs/ind.s"
.section .text
.code16
.global ind_clr

# ind_clr(*inum)
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

	# calc inode # TODO: low, high
	xor %dx, %dx
	mov 0x04(%bp), %si # *inum
	mov (%si), %ax # inum_lo
	mov $IND_SIZE, %cx
	mul %cx # ax *= cx
	add %ax, %bx # set mem

	# clear_bit(mem, bitnum)
	mov %es:IND_OFF_BLK_0(%bx), %ax
	mov %ax, (bbnum)

	# clear block # TODO: clear all block
	xor %ax, %ax
	mov %ax, %es:IND_OFF_FILE_SIZE(%bx)
	mov %ax, %es:IND_OFF_BLK_0(%bx)
	mov %ax, %es:IND_OFF_BLK_0+0x02(%bx)

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
	push $dpi+DPI_OFF_IBM
	call disk_write_dpi
	add $0x02, %sp

	mov 0x04(%bp), %si
	mov (%si), %ax
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
