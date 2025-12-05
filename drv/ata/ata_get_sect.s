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
	mov $ATA_PORT_DCR, %dx
	in %dx, %al
	or $ATA_DCR_NIEN, %al
	out %al, %dx

	# delay 400ns
	mov $ATA_PORT_ALT_STAT, %dx
	in %dx, %al
	in %dx, %al
	in %dx, %al
	in %dx, %al

	# set drv
	mov $ATA_PORT_DRV, %dx
	mov $ATA_DRV_MA_LBA, %al
	out %al, %dx

	# delay 400ns
	mov $ATA_PORT_ALT_STAT, %dx
	in %dx, %al
	in %dx, %al
	in %dx, %al
	in %dx, %al

	BSY
	DRDY

	mov $ATA_PORT_CMD, %dx
	mov $ATA_CMD_ID_DEV, %al
	out %al, %dx

	DRQ

	mov $ATA_PORT_DATA, %dx
	xor %cx, %cx

.data__lp:
	# (cnt == 0) ? {end}
	cmp $ATA_SECT_SIZE_WORD, %cx
	je .data__end

	in %dx, %ax
	cmp $ATA_OFF_TOT_SECT, %cx
	je .get_total_sect

	inc %cx
	jmp .data__lp

.get_total_sect:
	push %ax # [s.d0:sect_lo]
	in %dx, %ax
	push %ax # [s.d1:sect_hi]

	add $0x02, %cx
	jmp .data__lp

.data__end:
	mov $ATA_PORT_ALT_STAT, %dx
	in %dx, %al
	test $ATA_STAT_DRQ, %al
	jnz .err
	# TODO: err chk

.epil:
	# nien enable
	mov $ATA_PORT_DCR, %dx
	in %dx, %al
	and $~ATA_DCR_NIEN, %al
	out %al, %dx

	# delay 400ns
	mov $ATA_PORT_ALT_STAT, %dx
	in %dx, %al
	in %dx, %al
	in %dx, %al
	in %dx, %al

	pop %dx # <ret:hi> [s.d1:sect_hi]
	pop %ax # <ret:lo> [s.d0:sect_lo]
	# TODO: is set hi? set max in lo

	ret

.err:
	call dbg_a # HACK
	jmp .epil
