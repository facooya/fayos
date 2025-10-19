# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# [Superblock] Set disk logical block address

.include "drv/disk.s"
.include "fs/sb.s"
.section .text
.code16
.global sb_set_dlba

# sb_set_dlba()
# <mod> dlba
sb_set_dlba:
	push %di

	mov $dlba, %di

	mov %es:SB_OFF_BBM_LBA(%bx), %ax
	mov %ax, DLBA_OFF_BBM(%di)
	mov %es:SB_OFF_BBM_LBA+0x02(%bx), %ax
	mov %ax, DLBA_OFF_BBM+0x02(%di)

	mov %es:SB_OFF_IBM_LBA(%bx), %ax
	mov %ax, DLBA_OFF_IBM(%di)
	mov %es:SB_OFF_IBM_LBA+0x02(%bx), %ax
	mov %ax, DLBA_OFF_IBM+0x02(%di)

	mov %es:SB_OFF_IT_LBA(%bx), %ax
	mov %ax, DLBA_OFF_IT(%di)
	mov %es:SB_OFF_IT_LBA+0x02(%bx), %ax
	mov %ax, DLBA_OFF_IT+0x02(%di)

	pop %di
	ret
