# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# [Index Node] Return inode pointer

.include "drv/disk.s"
.include "fs/ind.s"
.section .text
.code16
.global ind_get_ptr

# ind_get_ptr(ub32 *inum)
# <ret> dx:ax = seg:off
ind_get_ptr:
	push %bp
	mov %sp, %bp
	push %es
	push %si
	push %bx

	# ind tbl
	mov $(DISK_IT_MEM>>0x10), %ax
	mov %ax, %es
	mov $(DISK_IT_MEM&0xFFFF), %bx

	# calc inum
	xor %dx, %dx
	mov 0x04(%bp), %si # *inum
	mov (%si), %ax # inum_lo
	mov $IND_SIZE, %cx
	mul %cx
	add %ax, %bx

	# ret
	mov %es, %dx
	mov %bx, %ax

	pop %bx
	pop %si
	pop %es
	pop %bp
	ret
