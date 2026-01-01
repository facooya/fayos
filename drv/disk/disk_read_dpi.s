# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya

.include "drv/disk.inc"
.section .text
.code16
.global disk_read_dpi

# disk_read_dpi(dpi *src)
# <ret> dx:ax = seg:off
disk_read_dpi:
	push %bp
	mov %sp, %bp
	push %bx

	mov 0x04(%bp), %bx
	mov DP_OFF_SECT_CNT(%bx), %ax
	push %ax
	mov DP_OFF_LBA(%bx), %ax
	push %ax
	mov DP_OFF_MEM(%bx), %ax
	push %ax
	mov DP_OFF_MEM+0x02(%bx), %ax
	push %ax
	call ata_read_sect
	add $0x08, %sp

	pop %bx
	pop %bp
	ret
