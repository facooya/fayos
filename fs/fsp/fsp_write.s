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
	push %bx

	mov FSP_OFF_IND_PTR+0x02(%si), %ax
	mov %ax, %es
	mov FSP_OFF_IND_PTR(%si), %di

	mov FSP_OFF_F_SIZE(%si), %ax
	mov %ax, %es:IND_OFF_F_SIZE(%di)

	mov FSP_OFF_BLK(%si), %ax
	mov %ax, %es:IND_OFF_BLK(%di)

	push $dpi+DPI_OFF_IT
	call disk_write_dpi
	add $0x02, %sp

	pop %bx
	pop %di
	pop %si
	pop %es
	pop %bp
	ret
