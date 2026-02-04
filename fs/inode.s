# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025-2026 Facooya and Fanone Facooya

.include "drv/disk.inc"
.include "fs/sb.inc"
.include "fs/fs.inc"
.include "fs/ind.inc"
.section .text
.code16
.global ind_add
.global ind_clr

# ind_add(ub8 f_type)
# <ret: ax = inum>
ind_add:
	push %bp
	mov %sp, %bp
	sub $0x10, %sp
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
	mov %ax, -0x02(%bp) # (l.1: blk_num)
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
	mov %ax, -0x04(%bp) # (l.2: inum)
	# }

	# { read/write inode table
	# (blk_size / ind_size = ind_per_blk)
	mov $FS_BLK_SIZE, %ax
	mov $IND_SIZE, %cx
	xor %dx, %dx
	div %cx
	# <ax = ind_per_blk>
	mov %ax, -0x06(%bp) # (l.3: ind_per_blk)

	# get it_lba
	mov $(DISK_SB_MEM>>0x10), %ax
	mov %ax, %es
	mov $(DISK_SB_MEM&0xFFFF), %si
	add $SB_OFF_DPI_IT, %si
	add $DP_OFF_LBA, %si
	mov %es:(%si), %ax # it_lba
	mov %ax, -0x08(%bp) # (l.4: it_lba)

	# (inum / ind_per_blk = blk_cnt)
	mov -0x04(%bp), %ax # (l.2: inum)
	mov -0x06(%bp), %cx # (l.3: ind_per_blk)
	xor %dx, %dx
	div %cx
	# <ax = blk_cnt>
	# <dx = inum_off>
	mov %ax, -0x0A(%bp) # (l.5: blk_cnt)
	mov %dx, -0x0C(%bp) # (l.6: inum_mem)

	# (blk_cnt * blk_sect_cnt + it_lba = tgt_lba)
	mov $DISK_BLK_SECT_CNT, %cx
	xor %dx, %dx
	mul %cx
	mov -0x08(%bp), %dx # (l.4: it_lba)
	add %dx, %ax
	# <ax = tgt_lba>

	# upd lba
	mov $dpi+DPI_OFF_IT, %si
	mov %ax, DP_OFF_LBA(%si)

	push $dpi+DPI_OFF_IT # (dpi &src)
	call disk_read_dpi
	add $0x02, %sp

	mov $(DISK_IT_MEM>>0x10), %ax
	mov %ax, %es
	mov $(DISK_IT_MEM&0xFFFF), %bx

	# calc inode
	mov -0x0C(%bp), %ax # (l.6: inum_mem)
	xor %dx, %dx
	mov $IND_SIZE, %cx
	mul %cx # ax *= cx
	add %ax, %bx # set mem

	# write blk
	mov -0x02(%bp), %ax # (l.1: blk_num)
	mov %ax, %es:IND_OFF_BLK(%bx)

	# f_type
	mov 0x04(%bp), %ax # (f_type)
	mov %al, %es:IND_OFF_F_TYPE(%bx)

	# blk cnt
	mov $0x01, %al
	mov %al, %es:IND_OFF_BLK_CNT(%bx)

	# write inode table
	push $dpi+DPI_OFF_IT
	call disk_write_dpi
	add $0x02, %sp
	# }

	# { set inum bit
	mov $(DISK_IBM_MEM>>0x10), %ax
	mov %ax, %es
	mov $(DISK_IBM_MEM&0xFFFF), %bx

	mov -0x04(%bp), %ax # (l.2: inum)
	push %ax # (bm_num)
	push %bx # (off)
	push %es # (seg)
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

	mov -0x02(%bp), %ax # (l.1: blk_num)
	push %ax # (bm_num)
	push %bx # (off)
	push %es # (seg)
	call bm_set
	add $0x06, %sp

	push $dpi+DPI_OFF_BBM
	call disk_write_dpi
	add $0x02, %sp
	# }

	mov -0x04(%bp), %ax # <ret: inum> (l.2: inum)

	pop %bx
	pop %di
	pop %si
	pop %es
	mov %bp, %sp
	pop %bp
	ret

# ind_clr(ub16 inum)
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

	# { clr
	mov $F_TYPE_RM, %al
	mov %al, %es:IND_OFF_F_TYPE(%bx)

	# clr size
	xor %ax, %ax
	mov %ax, %es:IND_OFF_F_SIZE(%bx)

	push $dpi+DPI_OFF_IT
	call disk_write_dpi
	add $0x02, %sp
	# }} push bitnum

	# { clear block bit
	xor %cx, %cx
	mov %es:IND_OFF_BLK_CNT(%bx), %cl

1:
	# (blk_cnt == 0) ? {end}
	test %cx, %cx
	jz 9f

	push %es # [s.0: it_seg]
	push %bx # [s.1: it_off]

	mov %es:IND_OFF_BLK(%bx), %ax # blk_num

	mov $(DISK_BBM_MEM>>0x10), %dx
	mov %dx, %es
	mov $(DISK_BBM_MEM&0xFFFF), %bx

	push %cx # [s.f0: blk_cnt]
	push %ax # (blk_num)
	push %bx # (off)
	push %es # (seg)
	call bm_clr
	add $0x06, %sp
	pop %cx # [s.f0: blk_cnt]

	pop %bx # [s.1: it_off]
	pop %es # [s.0: it_seg]

	xor %ax, %ax
	mov %ax, %es:IND_OFF_BLK(%bx)

	add $0x02, %bx
	dec %cx
	jmp 1b

9:
	mov $(DISK_BBM_MEM>>0x10), %ax
	mov %ax, %es
	mov $(DISK_BBM_MEM&0xFFFF), %bx

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
