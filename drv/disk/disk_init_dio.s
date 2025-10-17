# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# [Disk] Initial disk input/output

.include "drv/disk.s"
.section .text
.code16
.global disk_init_dio

disk_init_dio:
	push %di
	mov $dio, %di

	# sb
	mov $DIO_SB_SECT_CNT, %ax
	mov %ax, DIO_OFF_SECT_CNT(%di)
	mov $DIO_SB_SEG, %ax
	mov %ax, DIO_OFF_SEG(%di)
	mov $DIO_SB_OFF, %ax
	mov %ax, DIO_OFF_OFF(%di)
	mov $DIO_SB_LBA_HI, %ax
	mov %ax, DIO_OFF_LBA_HI(%di)
	mov $DIO_SB_LBA_LO, %ax
	mov %ax, DIO_OFF_LBA_LO(%di)
	add $DIO_SIZE, %di

	pop %di
	ret
