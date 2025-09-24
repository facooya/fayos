# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Get total sectors

.include "drv/ata.s"
.section .text
.code16
.global ata_get_sect

# ata_get_sect()
# <ret> dx:ax = sect
ata_get_sect:
	# set drv
	mov $ATA_DRV_REG, %dx
	mov $ATA_DRV_MA, %al
	out %al, %dx

	mov $ATA_CMD_REG, %dx

.bsy__lp:
	in %dx, %al
	test $ATA_STAT_BSY, %al
	jnz .bsy__lp

	mov $ATA_CMD_ID_DEV, %al
	out %al, %dx

.drq__lp:
	in %dx, %al
	test $ATA_STAT_DRQ, %al
	jz .drq__lp

	mov $ATA_DATA_REG, %dx
	mov $ATA_SECT_SIZE_WORD, %cx

.data__lp:
	# (cnt == 0) ? {end}
	test %cx, %cx
	jz .data__end

	in %dx, %ax
	cmp $ATA_REV_TOT_SECT_OFF, %cx
	je .get_total_sect

	sub $0x01, %cx
	jmp .data__lp

.get_total_sect:
	push %ax # [s.d0:sect_lo]
	in %dx, %ax
	push %ax # [s.d1:sect_hi]

	sub $0x02, %cx
	jmp .data__lp

.data__end:
	pop %dx # [s.d1:sect_hi]
	pop %ax # [s.d0:sect_lo]
	ret
