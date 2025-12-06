# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya

.include "int.s"
.include "drv/ata.s"
.include "drv/disk.s"
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

	pop %dx # <ret:hi> [s.d1:sect_hi]
	pop %ax # <ret:lo> [s.d0:sect_lo]

	# TODO: log
	# { max
	# (sect_hi == 0) ? {end}
	test %dx, %dx
	jz .max__end

	# (sect_hi >= max_hi) ? {set} : {end}
	cmp $(ATA_MAX_TOT_SECT>>0x10), %dx
	jae .max__set
	jmp .max__end

.max__set:
	mov $(ATA_MAX_TOT_SECT>>0x10), %dx

	# (sect_lo <= max_lo) ? {end}
	cmp $(ATA_MAX_TOT_SECT&0xFFFF), %ax
	jbe .max__end

	mov $(ATA_MAX_TOT_SECT&0xFFFF), %ax
	jmp .max__end

.max__end:
	# }
	push %dx # [s.c0:sect_hi]
	push %ax # [s.c1:sect_lo]

	xor %dx, %dx
	mov $DISK_BLK_SECT_CNT, %cx
	div %cx

	# TODO: log
	test %dx, %dx
	jz .turncate__skip

	pop %ax # [s.c1:sect_lo]
	xor %dx, %dx
	mov $DISK_BLK_SECT_CNT, %cx
	mul %cx
	push %ax # [s.c2:sect_lo]

.turncate__skip:
	pop %ax # <ret:lo> [s.c2:sect_lo]
	pop %dx # <ret:hi> [s.c0:sect_hi]

.epil:
	push %dx # [s.0:sect_hi]
	push %ax # [s.1:sect_lo]

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

	pop %ax # [s.1:sect_lo]
	pop %dx # [s.1:sect_hi]
	ret

.err:
	pop %dx # <ret:hi> [s.d1:sect_hi]
	pop %ax # <ret:lo> [s.d0:sect_lo]
	# TODO: err chk
	call dbg_a # HACK
	jmp .epil
