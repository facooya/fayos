# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya

.include "fs/fs.s"
.include "fs/sb.s"
.include "fs/ind.s"
.include "drv/disk.s"
.section .text
.code16
.global sb_run

# [public] sb_run()
sb_run:
	push %es
	push %si
	push %bx

	push $DISK_SB_SECT_CNT # (sect_cnt)
	push $DISK_SB_LBA # (lba)
	push $(DISK_SB_MEM&0xFFFF) # (&off)
	push $(DISK_SB_MEM>>0x10) # (&seg)
	call ata_read_sect
	add $0x08, %sp
	mov $(DISK_SB_MEM>>0x10), %ax
	mov %ax, %es
	mov $(DISK_SB_MEM&0xFFFF), %bx

	# {{{ (sb_mag != mag) ? {make} : {init}
	mov %es:SB_OFF_MAG(%bx), %ax
	cmp $(SB_MAG&0xFFFF), %ax
	jne 1f
	mov %es:SB_OFF_MAG+0x02(%bx), %ax
	cmp $(SB_MAG>>0x10), %ax
	jne 1f

	push $.kmsg_found
	call vga_puts
	add $0x02, %sp
	jmp 2f
	# }}}

1:
	push $.kmsg_try
	call vga_puts
	add $0x02, %sp

	# {{{ write superblock
	mov %bx, %si
	add $SB_OFF_TOT_SECT, %si
	call ata_get_sect
	# <dx:ax = tot_sect_hi:tot_sect_lo>
	mov %ax, (%si)
	mov %dx, 0x02(%si)

	push %bx
	push %es
	call sb_alloc_lba
	add $0x04, %sp

	# write magic
	mov $(SB_MAG&0xFFFF), %ax
	mov %ax, %es:SB_OFF_MAG(%bx)
	mov $(SB_MAG>>0x10), %ax
	mov %ax, %es:SB_OFF_MAG+0x02(%bx)

	call sb_write_dpi

	push $DISK_SB_SECT_CNT # (sect_cnt)
	push $DISK_SB_LBA # (lba)
	push $(DISK_SB_MEM&0xFFFF) # (&off)
	push $(DISK_SB_MEM>>0x10) # (&seg)
	call ata_write_sect
	add $0x08, %sp
	# }}}

	call disk_set_dpi
	call disk_load_dpi
	call sb_set_bm

	# { make root dir
	push $F_TYPE_DIR # (f_type)
	call ind_add
	add $0x02, %sp
	# <ax = inum>

	call fsp_init
	push $fsp+FSP_OFF_CUR # (fsp &src)
	push $fsp+FSP_OFF_TMP # (fsp &dst)
	call de_add_dots
	add $0x04, %sp
	call fsp_init
	# }
	jmp 90f

2:
	call disk_set_dpi
	call disk_load_dpi
	call fsp_init
	jmp 90f

90:
	push $.kmsg_ok
	call vga_puts
	add $0x02, %sp

	pop %bx
	pop %si
	pop %es
	ret

# [private] sb_alloc_lba(ub16 *seg, ub16 *off)
sb_alloc_lba:
	push %bp
	mov %sp, %bp
	push %es
	push %si
	push %bx

	mov 0x04(%bp), %ax # (*seg)
	mov %ax, %es
	mov 0x06(%bp), %bx # (*off)

	mov %es:SB_OFF_TOT_SECT(%bx), %ax
	mov %es:SB_OFF_TOT_SECT+0x02(%bx), %dx
	test %dx, %dx
	jz 1f

	mov $0xFFFF, %ax # max for calc
	mov $.flag, %si
	mov $(0x01<<0x00), %dx
	mov %dx, (%si)

1:
	# { bbm size
	# <ax = tot_sect>
	xor %dx, %dx
	mov $RATIO_SC_BLK, %cx
	div %cx
	# <ax = blk_cnt>
	test %dx, %dx
	jz 1f
	mov (%si), %dx
	test $(0x01<<0x00), %dx
	jz 1f
	inc %ax
1:
	mov %ax, %es:SB_TOT_BLK_CNT(%bx)

	xor %dx, %dx
	mov $RATIO_BIT_BYTE, %cx
	div %cx
	# <ax = blk_bitmap_size>
	test %dx, %dx
	jz 1f
	inc %ax
1:
	mov %ax, %es:SB_OFF_BBM_SIZE(%bx)
	# }

	# { ibm size
	mov %es:SB_TOT_BLK_CNT(%bx), %ax
	xor %dx, %dx
	mov $RATIO_BC_INUM, %cx
	div %cx
	# <ax = inum_size>
	test %dx, %dx
	jz 1f
	inc %ax
1:
	mov %ax, %es:SB_TOT_INUM_CNT(%bx)

	xor %dx, %dx
	mov $RATIO_BIT_BYTE, %cx
	div %cx
	# <ax = inum_bitmap_size>
	test %dx, %dx
	jz 1f
	inc %ax
1:
	mov %ax, %es:SB_OFF_IBM_SIZE(%bx)
	# }

	# its size
	mov %es:SB_TOT_INUM_CNT(%bx), %ax
	xor %dx, %dx
	mov $IND_SIZE, %cx
	mul %cx
	# <dx:ax = ind_tbl_size>
	mov %dx, %es:SB_OFF_IT_SIZE+0x02(%bx)
	mov %ax, %es:SB_OFF_IT_SIZE(%bx)

	# { bbbc
	mov %es:SB_OFF_BBM_SIZE(%bx), %ax
	xor %dx, %dx
	mov $FS_BLK_SIZE, %cx
	div %cx

	test %dx, %dx
	jz 1f
	inc %ax
	jmp 1f

1:
	mov %ax, %es:SB_OFF_BBM_BC(%bx)
	# }

	# { ibbc
	mov %es:SB_OFF_IBM_SIZE(%bx), %ax
	xor %dx, %dx
	mov $FS_BLK_SIZE, %cx
	div %cx

	test %dx, %dx
	jz 1f
	inc %ax

1:
	mov %ax, %es:SB_OFF_IBM_BC(%bx)
	# }

	# { itbc
	# high
	mov %es:SB_OFF_IT_SIZE(%bx), %dx
	test %dx, %dx
	jz 1f

	mov %dx, %ax
	xor %dx, %dx
	mov $FS_BLK_SIZE, %cx
	div %cx

	test %dx, %dx
	jz 1f
	inc %ax
1:
	mov %ax, %es:SB_OFF_IT_BC(%bx) # only hi bc

	# low
	mov %es:SB_OFF_IT_SIZE(%bx), %ax
	xor %dx, %dx
	mov $FS_BLK_SIZE, %cx
	div %cx

	test %dx, %dx
	jz 1f
	inc %ax

1:
	mov %es:SB_OFF_IT_BC(%bx), %dx
	add %dx, %ax # hi+lo
	mov %ax, %es:SB_OFF_IT_BC(%bx)
	# }

	# {{{
	# bb
	mov $FS_START_LBA, %ax
	mov %ax, %es:SB_OFF_BBM_LBA(%bx)

	# ib
	mov %es:SB_OFF_BBM_BC(%bx), %ax
	xor %dx, %dx
	mov $RATIO_SC_BLK, %cx
	mul %cx
	mov %es:SB_OFF_BBM_LBA(%bx), %cx
	add %cx, %ax
	mov %ax, %es:SB_OFF_IBM_LBA(%bx)

	# it
	mov %es:SB_OFF_IBM_BC(%bx), %ax
	xor %dx, %dx
	mov $RATIO_SC_BLK, %cx
	mul %cx
	mov %es:SB_OFF_IBM_LBA(%bx), %cx
	add %cx, %ax
	mov %ax, %es:SB_OFF_IT_LBA(%bx)

	# normal
	mov %es:SB_OFF_IT_BC(%bx), %ax
	xor %dx, %dx
	mov $RATIO_SC_BLK, %cx
	mul %cx
	mov %es:SB_OFF_IT_LBA(%bx), %cx
	add %cx, %ax
	mov %ax, %es:SB_OFF_NORM_LBA(%bx)
	# }}}

	pop %bx
	pop %si
	pop %es
	pop %bp
	ret

# [private] sb_write_dpi()
sb_write_dpi:
	push %es
	push %si
	push %di

	mov $(DISK_SB_MEM>>0x10), %ax
	mov %ax, %es
	mov $(DISK_SB_MEM&0xFFFF), %si

	# { super
	mov %si, %di
	add $SB_OFF_DPI_SB, %di

	mov $DISK_SB_SECT_CNT, %ax
	mov %ax, %es:DP_OFF_SECT_CNT(%di)

	mov $(DISK_SB_MEM>>0x10), %ax
	mov %ax, %es:DP_OFF_MEM+0x02(%di)
	mov $(DISK_SB_MEM&0xFFFF), %ax
	mov %ax, %es:DP_OFF_MEM(%di)

	mov $DISK_SB_LBA, %ax
	mov %ax, %es:DP_OFF_LBA(%di)
	# }

	# { blk bitmap
	mov %si, %di
	add $SB_OFF_DPI_BBM, %di

	mov $DISK_BLK_SECT_CNT, %ax
	mov %ax, %es:DP_OFF_SECT_CNT(%di)

	mov $(DISK_BBM_MEM>>0x10), %ax
	mov %ax, %es:DP_OFF_MEM+0x02(%di)
	mov $(DISK_BBM_MEM&0xFFFF), %ax
	mov %ax, %es:DP_OFF_MEM(%di)

	mov %es:SB_OFF_BBM_LBA(%si), %ax
	mov %ax, %es:DP_OFF_LBA(%di)
	# }

	# { inum bitmap
	mov %si, %di
	add $SB_OFF_DPI_IBM, %di

	mov $DISK_BLK_SECT_CNT, %ax
	mov %ax, %es:DP_OFF_SECT_CNT(%di)

	mov $(DISK_IBM_MEM>>0x10), %ax
	mov %ax, %es:DP_OFF_MEM+0x02(%di)
	mov $(DISK_IBM_MEM&0xFFFF), %ax
	mov %ax, %es:DP_OFF_MEM(%di)

	mov %es:SB_OFF_IBM_LBA(%si), %ax
	mov %ax, %es:DP_OFF_LBA(%di)
	# }

	# { ind table
	mov %si, %di
	add $SB_OFF_DPI_IT, %di

	mov $DISK_BLK_SECT_CNT, %ax
	mov %ax, %es:DP_OFF_SECT_CNT(%di)

	mov $(DISK_IT_MEM>>0x10), %ax
	mov %ax, %es:DP_OFF_MEM+0x02(%di)
	mov $(DISK_IT_MEM&0xFFFF), %ax
	mov %ax, %es:DP_OFF_MEM(%di)

	mov %es:SB_OFF_IT_LBA(%si), %ax
	mov %ax, %es:DP_OFF_LBA(%di)
	# }

	pop %di
	pop %si
	pop %es
	ret

# [private] sb_set_bm()
sb_set_bm:
	push %es
	push %si
	push %bx

	# { bbm
	mov $(DISK_BBM_MEM>>0x10), %ax
	mov %ax, %es
	mov $(DISK_BBM_MEM&0xFFFF), %bx

	xor %ax, %ax
	push %ax
	push %bx
	push %es
	call bm_set
	add $0x06, %sp

	push $dpi+DPI_OFF_BBM
	call disk_write_dpi
	add $0x02, %sp
	# }

	# { ibm
	mov $(DISK_IBM_MEM>>0x10), %ax
	mov %ax, %es
	mov $(DISK_IBM_MEM&0xFFFF), %bx

	xor %ax, %ax
	push %ax
	push %bx
	push %es
	call bm_set
	add $0x06, %sp

	push $dpi+DPI_OFF_IBM
	call disk_write_dpi
	add $0x02, %sp
	# }

	pop %bx
	pop %si
	pop %es
	ret

# [data]
.section .data
.kmsg_try: .asciz "\r\nSuperblock not found. Try creating ...\r\n"
.kmsg_found: .asciz "\r\nSuperblock found.\r\n"
.kmsg_ok: .asciz "Superblock ok\r\n"
.flag: .word 0x00
