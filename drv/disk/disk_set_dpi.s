# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya

.include "drv/disk.inc"
.include "fs/sb.s"
.section .text
.code16
.global disk_set_dpi

# disk_set_dpi()
# <mod> dpi
disk_set_dpi:
	push %es
	push %si
	push %di

	mov $(DISK_SB_MEM>>0x10), %ax
	mov %ax, %es
	mov $(DISK_SB_MEM&0xFFFF), %si
	add $SB_OFF_DPI_SB, %si
	mov $dpi, %di
	mov $0x04, %cx # dpi_cnt
	# [sb, bbm, ibm, it]

.lp:
	test %cx, %cx
	jz .done

	mov %es:DP_OFF_SECT_CNT(%si), %ax
	mov %ax, %es:DP_OFF_SECT_CNT(%di)

	mov %es:DP_OFF_MEM+0x02(%si), %ax
	mov %ax, %es:DP_OFF_MEM(%di)
	mov %es:DP_OFF_MEM(%si), %ax
	mov %ax, %es:DP_OFF_MEM(%di)

	mov %es:DP_OFF_LBA(%si), %ax
	mov %ax, %es:DP_OFF_LBA(%di)

	add $DP_SIZE, %si
	add $DP_SIZE, %di
	dec %cx
	jmp .lp

.done:
	pop %di
	pop %si
	pop %es
	ret
