# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# [Index Node] Write index node

.include "drv/disk.s"
.include "fs/fs.s"
.include "fs/ind.s"
.section .text
.code16
.global fsp_write

# fsp_write(fsp *src)
# <mod> ind_tbl
fsp_write:
	push %bp
	mov %sp, %bp
	push %es
	push %si
	push %di

	mov 0x04(%bp), %si
	mov FSP_OFF_IND_PTR+0x02(%si), %ax
	mov %ax, %es
	mov FSP_OFF_IND_PTR(%si), %di

	mov FSP_OFF_IND_FILE_SIZE(%si), %ax
	mov %ax, %es:IND_OFF_FILE_SIZE(%di)

	mov FSP_OFF_IND_BLK_0(%si), %ax
	mov %ax, %es:IND_OFF_BLK_0(%di)
	mov FSP_OFF_IND_BLK_0+0x02(%si), %ax
	mov %ax, %es:IND_OFF_BLK_0+0x02(%di)

	push $dpi+DPI_OFF_IT
	call disk_write_dpi
	add $0x02, %sp

	pop %di
	pop %si
	pop %es
	pop %bp
	ret
