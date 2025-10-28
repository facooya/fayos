# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# [File System Packet] Read inode and calculation LBA

.include "drv/disk.s"
.include "fs/fs.s"
.include "fs/ind.s"
.section .text
.code16
.global fsp_read

# fsp_read(fsp *dst, ub16 inum_hi, ub16 inum_lo)
fsp_read:
	push %bp
	mov %sp, %bp
	push %es
	push %si
	push %di
	push %bx

	# save inum
	mov 0x04(%bp), %di # (fsp *dsp)
	mov 0x06(%bp), %ax
	mov %ax, FSP_OFF_INUM+0x02(%di)
	mov 0x08(%bp), %ax
	mov %ax, FSP_OFF_INUM(%di)

	push FSP_OFF_IND_BLK_0(%di)
	push FSP_OFF_IND_BLK_0+0x02(%di)
	call fs_blk_to_lba
	add $0x04, %sp
	# <dx:ax = lba_hi:lba_lo>
	mov %dx, FSP_OFF_DISK_LBA+0x02(%di)
	mov %ax, FSP_OFF_DISK_LBA(%di)

	# { save ptr
	mov $(DISK_IT_MEM>>0x10), %ax
	mov %ax, %es
	mov $(DISK_IT_MEM&0xFFFF), %bx

	xor %dx, %dx
	mov 0x08(%bp), %ax # inum_lo
	mov $IND_SIZE, %cx
	mul %cx
	add %ax, %bx

	mov %es, FSP_OFF_IND_PTR+0x02(%di)
	mov %bx, FSP_OFF_IND_PTR(%di)
	# }

	mov $IND_SIZE, %cx

.lp:
	test %cx, %cx
	jz .done

	# cpy inode
	mov %es:(%bx), %ax
	mov %ax, (%di)

	add $0x02, %bx
	add $0x02, %di
	sub $0x02, %cx
	jmp .lp

.done:
	pop %bx
	pop %di
	pop %si
	pop %es
	pop %bp
	ret
