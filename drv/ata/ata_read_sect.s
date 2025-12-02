# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Read sectors

# reference link
# https://wiki.osdev.org/ATA_read/write_sectors#Read_in_LBA_mode

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
# <ret> dx:ax = seg:off
ata_read_sect:
	push %bp
	mov %sp, %bp
	push %es
	push %di

	# nien enable
	#mov $ATA_DCR, %dx
	#xor %al, %al
	#out %al, %dx

	mov 0x04(%bp), %ax # (*seg)
	mov %ax, (ata_seg)
	mov 0x06(%bp), %ax # (*off)
	mov %ax, (ata_off)

	# set mode
	mov $ATA_DRV_REG, %dx
	mov $ATA_DRV_MA_LBA, %al # 0b11100000
	out %al, %dx

	mov $ATA_STAT_REG, %dx
	in %dx, %al
	in %dx, %al
	in %dx, %al
	in %dx, %al

	BSY
	RDY

	# sector count
	mov $ATA_SECT_CNT_REG, %dx
	mov 0x0A(%bp), %ax # (sect_cnt)
	mov %ax, (ata_cnt)
	out %al, %dx

	# {{{ LBA
	mov $ATA_LBA_LO_REG, %dx
	mov 0x08(%bp), %ax # (lba)
	out %al, %dx # lba_lo

	mov $ATA_LBA_MID_REG, %dx
	mov %ah, %al
	out %al, %dx # lba_mid

	mov $ATA_LBA_HI_REG, %dx
	xor %ax, %ax
	out %al, %dx # lba_hi
	# }}}

	# read
	mov $ATA_CMD_REG, %dx
	mov $ATA_READ, %al
	mov %al, (ata_stat)
	out %al, %dx

.wait:
	mov (ata_cnt), %ax
	test %ax, %ax
	jz .done

	hlt
	jmp .wait

.done:
	BSY
	# TODO: err, df

	mov 0x04(%bp), %dx
	mov 0x06(%bp), %ax

	pop %di
	pop %es
	pop %bp
	ret
