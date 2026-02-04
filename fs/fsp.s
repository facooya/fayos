# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025-2026 Facooya and Fanone Facooya

.include "drv/disk.inc"
.include "fs/fs.inc"
.include "fs/sb.inc"
.include "fs/ind.inc"
.section .text
.code16
.global fsp_init
.global fsp_read
.global fsp_write

# fsp_init()
fsp_init:
	push %di

	mov $fsp+FSP_OFF_CUR, %di
	push $FS_ROOT_INUM
	push %di # (fsp &dst)
	call fsp_read
	add $0x04, %sp

	movb $DISK_BLK_SECT_CNT, FSP_OFF_DISK_SECT_CNT(%di)
	movw $(DISK_CUR_MEM>>0x10), FSP_OFF_DISK_MEM+0x02(%di)
	movw $(DISK_CUR_MEM&0xFFFF), FSP_OFF_DISK_MEM(%di)

	push FSP_OFF_BLK(%di)
	call fs_blk_to_lba
	add $0x02, %sp
	# <ax = lba>
	mov %ax, FSP_OFF_DISK_LBA(%di)

	push $FSP_SIZE
	push %di
	push %ds
	push $fsp+FSP_OFF_PAR
	push %ds
	call mem_cpy
	add $0x0A, %sp
	movw $(DISK_PAR_MEM>>0x10), FSP_OFF_DISK_MEM+0x02(%di)
	movw $(DISK_PAR_MEM&0xFFFF), FSP_OFF_DISK_MEM(%di)
	add $FSP_SIZE, %di

	push $FSP_SIZE
	push %di
	push %ds
	push $fsp+FSP_OFF_TMP
	push %ds
	call mem_cpy
	add $0x0A, %sp
	movw $(DISK_TMP_MEM>>0x10), FSP_OFF_DISK_MEM+0x02(%di)
	movw $(DISK_TMP_MEM&0xFFFF), FSP_OFF_DISK_MEM(%di)
	add $FSP_SIZE, %di

	push $FSP_SIZE
	push %di
	push %ds
	push $fsp+FSP_OFF_DIR
	push %ds
	call mem_cpy
	add $0x0A, %sp
	movw $(DISK_DIR_MEM>>0x10), FSP_OFF_DISK_MEM+0x02(%di)
	movw $(DISK_DIR_MEM&0xFFFF), FSP_OFF_DISK_MEM(%di)
	add $FSP_SIZE, %di

	push $FSP_SIZE
	push %di
	push %ds
	push $fsp+FSP_OFF_BASE
	push %ds
	call mem_cpy
	add $0x0A, %sp
	movw $(DISK_BASE_MEM>>0x10), FSP_OFF_DISK_MEM+0x02(%di)
	movw $(DISK_BASE_MEM&0xFFFF), FSP_OFF_DISK_MEM(%di)
	add $FSP_SIZE, %di

	push $FSP_SIZE
	push %di
	push %ds
	push $fsp+FSP_OFF_ROOT
	push %ds
	call mem_cpy
	add $0x0A, %sp
	movw $(DISK_ROOT_MEM>>0x10), FSP_OFF_DISK_MEM+0x02(%di)
	movw $(DISK_ROOT_MEM&0xFFFF), FSP_OFF_DISK_MEM(%di)
	add $FSP_SIZE, %di

	push $FSP_SIZE
	push %di
	push %ds
	push $fsp+FSP_OFF_HIST
	push %ds
	call mem_cpy
	add $0x0A, %sp
	movw $(DISK_HIST_MEM>>0x10), FSP_OFF_DISK_MEM+0x02(%di)
	movw $(DISK_HIST_MEM&0xFFFF), FSP_OFF_DISK_MEM(%di)
	add $FSP_SIZE, %di

	pop %di
	ret

# fsp_read(fsp *dst, ub16 inum)
fsp_read:
	push %bp
	mov %sp, %bp
	sub $0x10, %sp
	push %es
	push %si
	push %di
	push %bx

	# save inum
	mov 0x04(%bp), %di # (fsp *dsp)
	mov 0x06(%bp), %ax # (inum)
	mov %ax, FSP_OFF_INUM(%di)

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
	mov 0x06(%bp), %ax # (inum)
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

	# { save ptr
	mov $(DISK_IT_MEM>>0x10), %ax
	mov %ax, %es
	mov $(DISK_IT_MEM&0xFFFF), %bx

	xor %dx, %dx
	mov -0x0C(%bp), %ax # (l.6: inum_mem)
	mov $IND_SIZE, %cx
	mul %cx
	add %ax, %bx

	mov %es, %ax
	mov %ax, FSP_OFF_IND_PTR+0x02(%di)
	mov %bx, FSP_OFF_IND_PTR(%di)
	# }

	mov $IND_SIZE, %cx

1:
	test %cx, %cx
	jz 1f

	# cpy inode
	mov %es:(%bx), %ax
	mov %ax, (%di)

	add $0x02, %bx
	add $0x02, %di
	sub $0x02, %cx
	jmp 1b

1:
	mov 0x04(%bp), %di # (fsp *dst)

	# set lba
	push FSP_OFF_BLK(%di)
	call fs_blk_to_lba
	add $0x02, %sp
	# <ax = lba>
	mov %ax, FSP_OFF_DISK_LBA(%di)

	pop %bx
	pop %di
	pop %si
	pop %es
	mov %bp, %sp
	pop %bp
	ret

# fsp_write(fsp *src)
fsp_write:
	push %bp
	mov %sp, %bp
	sub $0x10, %sp
	push %es
	push %si
	push %di
	push %bx

	mov 0x04(%bp), %si

	mov FSP_OFF_INUM(%si), %ax
	mov %ax, -0x04(%bp) # (l.2: inum)

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

	mov 0x04(%bp), %si
	mov FSP_OFF_IND_PTR+0x02(%si), %ax
	mov %ax, %es
	mov FSP_OFF_IND_PTR(%si), %di

	push $IND_SIZE
	push %si # (s_off)
	push %ds # (s_seg)
	push %di # (d_off)
	push %es # (d_seg)
	call mem_cpy
	add $0x0A, %sp

	push $dpi+DPI_OFF_IT
	call disk_write_dpi
	add $0x02, %sp

	pop %bx
	pop %di
	pop %si
	pop %es
	mov %bp, %sp
	pop %bp
	ret

.section .data
.global fsp
# fsp: ind, ind_ptr, inum, d_sect_cnt, d_mem, d_lba
fsp: .zero 0x200
