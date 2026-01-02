# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya

.include "fs/fs.inc"
.section .text
.code16
.global disk_write_fsp

# disk_write_fsp(fsp *src)
# <ret> dx:ax = seg:off
disk_write_fsp:
	push %bp
	mov %sp, %bp
	push %bx

	mov 0x04(%bp), %bx # (fsp &src)
	mov FSP_OFF_DISK_SECT_CNT(%bx), %ax
	push %ax
	mov FSP_OFF_DISK_LBA(%bx), %ax
	push %ax
	mov FSP_OFF_DISK_MEM(%bx), %ax
	push %ax
	mov FSP_OFF_DISK_MEM+0x02(%bx), %ax
	push %ax
	call ata_write_sect
	add $0x08, %sp

	pop %bx
	pop %bp
	ret
