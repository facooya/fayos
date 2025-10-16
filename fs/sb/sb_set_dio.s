# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# [Superblock] Set disk input/output structure

.include "fs/sb.s"
.section .text
.code16
.global sb_set_dio

# sb_set_dio()
# <ret> dio
sb_set_dio:
	push %di

	mov $dio, %di

	mov %es:SB_OFF_BBM_LBA(%bx), %ax
	push %ax # lba_lo
	mov %es:SB_OFF_BBM_LBA+0x02(%bx), %ax
	push %ax # lba_hi
	mov $0x00, %ax
	push %ax # off
	mov $0x1000, %ax
	push %ax # seg
	mov $0x08, %ax
	push %ax # sect_cnt
	mov $0x01, %ax
	push %ax # dnum
	call disk_set_dio
	add $0x0C, %sp

	mov %es:SB_OFF_IBM_LBA(%bx), %ax
	push %ax # lba_lo
	mov %es:SB_OFF_IBM_LBA+0x02(%bx), %ax
	push %ax # lba_hi
	mov $0x1000, %ax
	push %ax # off
	mov $0x1000, %ax
	push %ax # seg
	mov $0x08, %ax
	push %ax # sect_cnt
	mov $0x02, %ax
	push %ax # dnum
	call disk_set_dio
	add $0x0C, %sp

	mov %es:SB_OFF_IT_LBA(%bx), %ax
	push %ax # lba_lo
	mov %es:SB_OFF_IT_LBA+0x02(%bx), %ax
	push %ax # lba_hi
	mov $0x2000, %ax
	push %ax # off
	mov $0x1000, %ax
	push %ax # seg
	mov $0x08, %ax
	push %ax # sect_cnt
	mov $0x03, %ax
	push %ax # dnum
	call disk_set_dio
	add $0x0C, %sp

	pop %di
	ret
