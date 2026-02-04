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
	push %es
	push %si
	push %di
	push %bx

	# save inum
	mov 0x04(%bp), %di # (fsp *dsp)
	mov 0x06(%bp), %ax # (inum)
	mov %ax, FSP_OFF_INUM(%di)

	push %ax # (inum)
	call ind_calc_lba
	add $0x02, %sp
	# <ax = lba, dx = ind_off>
	push %dx # [s.0: ind_off]

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
	pop %dx # [s.0: ind_off]
	add %dx, %bx

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
	pop %bp
	ret

# fsp_write(fsp *src)
fsp_write:
	push %bp
	mov %sp, %bp
	push %es
	push %si
	push %di
	push %bx

	mov 0x04(%bp), %si
	mov FSP_OFF_INUM(%si), %ax

	push %ax # (inum)
	call ind_calc_lba
	add $0x02, %sp
	# <ax = lba, dx = ind_off>

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
	pop %bp
	ret

.section .data
.global fsp
# fsp: ind, ind_ptr, inum, d_sect_cnt, d_mem, d_lba
fsp: .zero 0x200
