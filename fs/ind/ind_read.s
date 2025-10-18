# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# [Index Node] Read index node

.include "drv/disk.s"
.include "fs/ind.s"
.section .text
.code16
.global ind_read

# ind_read(
# *inum
# *inode
# )
# <ret> inode
# <ret> fd
ind_read:
	push %bp
	mov %sp, %bp
	push %es
	push %si
	push %bx

	# call mem_alloc
	# push fd
	push $DNUM_IT
	call disk_read_sect
	add $0x02, %sp
	mov %ax, %bx
	mov %dx, %es

	# calc inum
	xor %dx, %dx
	mov 0x04(%bp), %si # *inum
	mov (%si), %ax # inum_lo
	mov $IND_SIZE, %cx
	mul %cx
	add %ax, %bx

	mov 0x06(%bp), %si # *inode

	# set i_file_size
	mov %es:IND_OFF_FILE_SIZE(%bx), %ax
	mov %ax, IND_OFF_FILE_SIZE(%si)

	# set i_blk
	mov %es:IND_OFF_BLK_0(%bx), %ax
	mov %ax, IND_OFF_BLK_0(%si)
	mov %es:IND_OFF_BLK_0+0x02(%bx), %ax
	mov %ax, IND_OFF_BLK_0+0x02(%si)

	# call mem_free

	pop %bx
	pop %si
	pop %es
	pop %bp
	ret
