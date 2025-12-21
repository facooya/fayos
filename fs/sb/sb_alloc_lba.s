# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# [Superblock] Allocate LBA

.include "fs/fs.s"
.include "fs/sb.s"
.include "fs/ind.s"
.section .data
.flag: .word 0x00

.section .text
.code16
.global sb_alloc_lba

# sb_alloc_lba(ub16 *seg, ub16 *off)
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
	jz .size__calc

	mov $0xFFFF, %ax # max for calc
	mov $.flag, %si
	mov $(0x01<<0x00), %dx
	mov %dx, (%si)

.size__calc:
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
	jz .set_bbbc
	inc %ax
	jmp .set_bbbc

.set_bbbc:
	mov %ax, %es:SB_OFF_BBM_BC(%bx)
	# }

	# { ibbc
	mov %es:SB_OFF_IBM_SIZE(%bx), %ax
	xor %dx, %dx
	mov $FS_BLK_SIZE, %cx
	div %cx

	test %dx, %dx
	jz .set_ibbc
	inc %ax

.set_ibbc:
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
	jz .set_itbc
	inc %ax

.set_itbc:
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
