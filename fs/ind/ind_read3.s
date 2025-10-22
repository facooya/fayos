# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# [Index Node] Read index node table and return index node memory

.include "drv/disk.s"
.include "fs/ind.s"
.section .text
.code16
.global ind_read3

# ind_read(ub16 inum_hi, ub16 inum_lo)
# <ret> dx:ax = ind_seg:ind_off
ind_read3:
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
	mov 0x06(%bp), %ax # inum_lo
	mov $IND_SIZE, %cx
	mul %cx
	add %ax, %bx

	# ret
	mov %es, %dx # <ret:seg>
	mov %bx, %ax # <ret:off>

	pop %bx
	pop %si
	pop %es
	pop %bp
	ret
