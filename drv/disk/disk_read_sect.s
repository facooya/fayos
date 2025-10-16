# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# [Disk] Read sectors

.include "drv/disk.s"
.section .text
.code16
.global disk_read_sect

# disk_read_sect(ub16 dnum)
# <req> dio
# <ret> dx:ax = seg:off
disk_read_sect:
	push %bp
	mov %sp, %bp
	push %si
	push %bx

	mov 0x04(%bp), %ax # dnum
	mov $DIO_SIZE, %cx
	mul %cx
	# ax = dio_off

	mov $dio, %si
	add %ax, %si # dio_off

	mov DIO_OFF_SECT_CNT(%si), %ax
	push %ax # sect_cnt
	mov DIO_OFF_LBA_LO(%si), %ax
	push %ax # lba_lo
	mov DIO_OFF_LBA_HI(%si), %ax
	push %ax # lba_hi
	mov DIO_OFF_OFF(%si), %ax
	push %ax # off
	mov DIO_OFF_SEG(%si), %ax
	push %ax # seg
	call ata_read_sect
	add $0x0A, %sp

.done:
	pop %bx
	pop %si
	pop %bp
	ret
