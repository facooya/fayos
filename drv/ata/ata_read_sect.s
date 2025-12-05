# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya

.include "int.s"
.include "drv/ata.s"
.section .text
.code16
.global ata_read_sect

# ata_read_sect(
# ub16 *seg,
# ub16 *off,
# ub16 lba,
# ub16 sect_cnt
# )
# <mod> ata_stat
# <ret> dx:ax = seg:off
ata_read_sect:
	push %bp
	mov %sp, %bp
	push %bx

	mov $ata_stat, %bx
	mov 0x04(%bp), %ax # (*seg)
	mov %ax, ATA_STAT_SEG(%bx)
	mov 0x06(%bp), %ax # (*off)
	mov %ax, ATA_STAT_OFF(%bx)

	# set mode
	mov $ATA_PORT_DRV, %dx
	mov $ATA_DRV_MA_LBA, %al # 0b11100000
	out %al, %dx

	# delay 400ns
	mov $ATA_PORT_STAT, %dx
	in %dx, %al
	in %dx, %al
	in %dx, %al
	in %dx, %al

	BSY
	DRDY

	# sector count
	mov $ATA_PORT_SECT_CNT, %dx
	mov 0x0A(%bp), %ax # (sect_cnt)
	mov %al, ATA_STAT_CNT(%bx)
	out %al, %dx

	# { lba
	mov $ATA_PORT_LBA_LO, %dx
	mov 0x08(%bp), %ax # (lba)
	out %al, %dx # lba_lo

	mov $ATA_PORT_LBA_MID, %dx
	mov %ah, %al
	out %al, %dx # lba_mid

	mov $ATA_PORT_LBA_HI, %dx
	xor %ax, %ax
	out %al, %dx # lba_hi
	# }

	# read
	cli
	mov $ATA_PORT_CMD, %dx
	mov $ATA_READ, %al
	mov %al, ATA_STAT_CMD(%bx)
	out %al, %dx

	# delay 400ns
	mov $ATA_PORT_STAT, %dx
	in %dx, %al
	in %dx, %al
	in %dx, %al
	in %dx, %al
	sti

.wait:
	# (sect_cnt == 0) ? {done} : {lp}
	mov ATA_STAT_CNT(%bx), %al
	test %al, %al
	jz .done
	hlt
	jmp .wait

.done:
	mov 0x04(%bp), %dx
	mov 0x06(%bp), %ax

	pop %bx
	pop %bp
	ret
