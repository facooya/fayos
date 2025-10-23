# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# [Disk] Write disk packet

.include "drv/disk.s"
.section .text
.code16
.global disk_write_dp

# disk_write_dp(dp *dp)
# <ret> dx:ax = seg:off
disk_write_dp:
	push %bp
	mov %sp, %bp
	push %bx

	mov 0x04(%bp), %bx
	mov DP_OFF_SECT_CNT(%bx), %ax
	push %ax
	mov DP_OFF_LBA(%bx), %ax
	push %ax
	mov DP_OFF_LBA+0x02(%bx), %ax
	push %ax
	mov DP_OFF_MEM(%bx), %ax
	push %ax
	mov DP_OFF_MEM+0x02(%bx), %ax
	push %ax
	call ata_write_sect
	add $0x0A, %sp

	pop %bx
	pop %bp
	ret
