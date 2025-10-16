# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# [Debug] Disk input/output

.include "drv/disk.s"
.section .text
.code16
.global dbg_dio

# dbg_dio(ub16 dnum)
dbg_dio:
	push %bp
	mov %sp, %bp
	push %di
	push %ax
	push %cx

	mov $dio, %di
	mov 0x04(%bp), %ax
	mov $DIO_SIZE, %cx
	mul %cx
	add %ax, %di

	mov DIO_OFF_SECT_CNT(%di), %ax
	push %ax
	call dbg_reg
	add $0x02, %sp
	mov DIO_OFF_SEG(%di), %ax
	push %ax
	call dbg_reg
	add $0x02, %sp
	mov DIO_OFF_OFF(%di), %ax
	push %ax
	call dbg_reg
	add $0x02, %sp
	mov DIO_OFF_LBA_HI(%di), %ax
	push %ax
	call dbg_reg
	add $0x02, %sp
	mov DIO_OFF_LBA_LO(%di), %ax
	push %ax
	call dbg_reg
	add $0x02, %sp

	pop %cx
	pop %ax
	pop %di
	pop %bp
	ret
