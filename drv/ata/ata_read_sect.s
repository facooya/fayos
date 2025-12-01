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
	push %bx

	mov 0x04(%bp), %ax # (*seg)
	mov %ax, %es
	mov 0x06(%bp), %di # (*off)

	# set mode
	mov $ATA_DRV_REG, %dx
	mov $ATA_DRV_MA_LBA, %al # 0b11100000
	out %al, %dx

	BSY
	RDY

	# sector count
	mov $ATA_SECT_CNT_REG, %dx
	mov 0x0A(%bp), %ax # (sect_cnt)
	mov %ax, %bx # sect_cnt
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
	#mov $ATA_CMD_REG, %dx
	#mov $ATA_READ, %al
	#mov %al, (ata_stat)
	#out %al, %dx

.sect__lp:
	BSY
	RDY
	DRQ
	# TODO: err, df

	mov $ATA_CMD_REG, %dx
	mov $ATA_READ, %al
	mov %al, (ata_stat)
	out %al, %dx

	#mov $ATA_DATA_REG, %dx
	#mov $ATA_SECT_SIZE_WORD, %cx
	#rep insw

	# (sect_cnt == 0) ? {done} : {sec.lp}
	sub $0x01, %bx
	test %bx, %bx
	jz .done
	jmp .sect__lp

.done:
	BSY
	# TODO: err, df

	mov 0x04(%bp), %dx
	mov 0x06(%bp), %ax

	pop %bx
	pop %di
	pop %es
	pop %bp
	ret
