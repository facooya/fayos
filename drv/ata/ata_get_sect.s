# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya

.include "int.s"
.include "drv/ata.s"
.section .text
.code16
.global ata_get_sect

# ata_get_sect()
# <ret> dx:ax = tot_sect_hi:tot_sect_lo
ata_get_sect:
	# nien disable
	mov $ATA_DCR, %dx
	in %dx, %al
	or $ATA_DCR_NIEN, %al
	out %al, %dx

	# delay 400ns
	mov $ATA_STAT_REG, %dx
	in %dx, %al
	in %dx, %al
	in %dx, %al
	in %dx, %al

	# set drv
	mov $ATA_DRV_REG, %dx
	mov $ATA_DRV_MA, %al
	out %al, %dx

	# delay 400ns
	mov $ATA_STAT_REG, %dx
	in %dx, %al
	in %dx, %al
	in %dx, %al
	in %dx, %al

	BSY
	RDY

	mov $ATA_CMD_REG, %dx
	mov $ATA_ID_DEV, %al
	mov %al, (ata_stat)
	out %al, %dx

	DRQ

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
	mov $ATA_STAT_REG, %dx
	in %dx, %al
	test $ATA_DRQ, %al
	jnz .err
	# TODO: err chk

.epil:
	# nien enable
	mov $ATA_DCR, %dx
	in %dx, %al
	and $~ATA_DCR_NIEN, %al
	out %al, %dx

	# delay 400ns
	mov $ATA_STAT_REG, %dx
	in %dx, %al
	in %dx, %al
	in %dx, %al
	in %dx, %al

	pop %dx # <ret:hi> [s.d1:sect_hi]
	pop %ax # <ret:lo> [s.d0:sect_lo]
	ret

.err:
	call dbg_a # HACK
	jmp .epil
