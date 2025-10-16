# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# [Disk] Set disk input/output structure

.include "drv/disk.s"
.section .text
.code16
.global disk_set_dio

# disk_set_dio(
# ub16 dnum,
# ub16 sect_cnt,
# ub16 seg,
# ub16 off,
# ub16 lba_hi,
# ub16 lba_lo
# )
# <ret> dio
disk_set_dio:
	push %bp
	mov %sp, %bp
	push %di

	mov $dio, %di

	mov 0x04(%bp), %ax
	mov $DIO_SIZE, %cx
	mul %cx
	add %ax, %di

	mov 0x06(%bp), %ax
	mov %ax, DIO_OFF_SECT_CNT(%di)
	mov 0x08(%bp), %ax
	mov %ax, DIO_OFF_SEG(%di)
	mov 0x0A(%bp), %ax
	mov %ax, DIO_OFF_OFF(%di)
	mov 0x0C(%bp), %ax
	mov %ax, DIO_OFF_LBA_HI(%di)
	mov 0x0E(%bp), %ax
	mov %ax, DIO_OFF_LBA_LO(%di)

	pop %di
	pop %bp
	ret
