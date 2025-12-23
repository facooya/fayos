# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya

.include "drv/disk.s"
.include "fs/fs.s"
.include "fs/ind.s"
.section .text
.code16
.global ind_add
.global ind_clr

# [public] ind_add(ub8 f_type)
# <ret> ax = inum
ind_add:
	push %bp
	mov %sp, %bp
	push %es
	push %si
	push %di
	push %bx

	# { alloc blk_num
	mov $(DISK_BBM_MEM>>0x10), %ax
	mov %ax, %es
	mov $(DISK_BBM_MEM&0xFFFF), %bx

	push %bx
	push %es
	call bm_alloc
	add $0x04, %sp
	# <ax = bm_num>
	push %ax # [s.0:blk_num]
	# }

	# { alloc inum
	mov $(DISK_IBM_MEM>>0x10), %ax
	mov %ax, %es
	mov $(DISK_IBM_MEM&0xFFFF), %bx

	push %bx
	push %es
	call bm_alloc
	add $0x04, %sp
	# <ax = bm_num>
	mov %ax, %di # inum
	push %ax # [s.1:inum]
	# }

	# { read/write inode table
	mov $(DISK_IT_MEM>>0x10), %ax
	mov %ax, %es
	mov $(DISK_IT_MEM&0xFFFF), %bx

	# calc inode
	pop %ax # [s.1:inum]
	push %ax # [s.1:inum]
	xor %dx, %dx
	mov $IND_SIZE, %cx
	mul %cx # ax *= cx
	add %ax, %bx # set mem
	pop %ax # [s.1:inum]
	mov %ax, %cx

	# write blk
	pop %ax # [s.0:blk_num]
	mov %ax, %es:IND_OFF_BLK(%bx)
	push %ax # [s.1:blk_num]
	push %cx # [s.0:inum]

	# f_type
	mov 0x04(%bp), %ax # (f_type)
	mov %al, %es:IND_OFF_F_TYPE(%bx)

	# write inode table
	push $dpi+DPI_OFF_IT
	call disk_write_dpi
	add $0x02, %sp
	# }

	# { set inum bit
	mov $(DISK_IBM_MEM>>0x10), %ax
	mov %ax, %es
	mov $(DISK_IBM_MEM&0xFFFF), %bx

	pop %ax # [s.0:inum]
	push %ax # (bm_num)
	push %bx # (&off)
	push %es # (&seg)
	call bm_set
	add $0x06, %sp

	push $dpi+DPI_OFF_IBM
	call disk_write_dpi
	add $0x02, %sp
	# }

	# { set blknum bit
	mov $(DISK_BBM_MEM>>0x10), %ax
	mov %ax, %es
	mov $(DISK_BBM_MEM&0xFFFF), %bx

	pop %ax # [s.1:blk_num]
	push %ax # (bm_num)
	push %bx # (&off)
	push %es # (&seg)
	call bm_set
	add $0x06, %sp

	push $dpi+DPI_OFF_BBM
	call disk_write_dpi
	add $0x02, %sp
	# }

	mov %di, %ax # <ret:inum>

	pop %bx
	pop %di
	pop %si
	pop %es
	pop %bp
	ret

# [public] ind_clr(ub16 inum)
ind_clr:
	push %bp
	mov %sp, %bp
	push %es
	push %si
	push %bx

	# {{ read/write inode table
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
	push %ax # [s.0:blk_num]

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
	# }} push bitnum

	# { clear block bit
	mov $(DISK_BBM_MEM>>0x10), %ax
	mov %ax, %es
	mov $(DISK_BBM_MEM&0xFFFF), %bx

	pop %ax # [s.0:blk_num]
	push %ax
	push %bx
	push %es
	call bm_clr
	add $0x06, %sp

	push $dpi+DPI_OFF_BBM
	call disk_write_dpi
	add $0x02, %sp
	# }

	# { clear inum bit
	mov $(DISK_IBM_MEM>>0x10), %ax
	mov %ax, %es
	mov $(DISK_IBM_MEM&0xFFFF), %bx

	mov 0x04(%bp), %ax # (inum)
	push %ax
	push %bx
	push %es
	call bm_clr
	add $0x06, %sp

	push $dpi+DPI_OFF_IBM
	call disk_write_dpi
	add $0x02, %sp
	# }

	pop %bx
	pop %si
	pop %es
	pop %bp
	ret
