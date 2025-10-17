# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# [Index Node] Update index node

.include "drv/disk.s"
.include "fs/ind.s"
.section .text
.code16
.global ind_upd

# ind_upd(
# *inum
# *inode
# )
ind_upd:
	push %bp
	mov %sp, %bp
	push %es
	push %si
	push %bx

	push $DNUM_IT
	call disk_read_sect
	add $0x02, %sp
	mov %ax, %bx
	mov %dx, %es

	xor %dx, %dx
	mov 0x04(%bp), %si # *inum
	mov (%si), %ax # inum_lo
	mov $IND_SIZE, %cx
	mul %cx # ax *= cx
	add %ax, %bx # set mem

	mov 0x06(%bp), %si # *inode
	mov IND_OFF_FILE_SIZE(%si), %ax
	mov %ax, %es:IND_OFF_FILE_SIZE(%bx)

	mov IND_OFF_BLK_0(%si), %ax
	mov %ax, %es:IND_OFF_BLK_0(%bx)
	mov IND_OFF_BLK_0+0x02(%si), %ax
	mov %ax, %es:IND_OFF_BLK_0+0x02(%bx)

	push $DNUM_IT
	call disk_write_sect
	add $0x02, %sp

	pop %bx
	pop %si
	pop %es
	pop %bp
	ret
