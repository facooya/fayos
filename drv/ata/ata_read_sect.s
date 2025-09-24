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
# seg, off,
# lba_hi, lba_lo,
# sect_cnt
# )
# <ret> dx:ax = seg:off
ata_read_sect:
	push %bp
	mov %sp, %bp
	push %es
	push %di
	push %bx

	mov 0x04(%bp), %ax
	mov %ax, %es
	mov 0x06(%bp), %di

	# set mode
	mov $ATA_DRV_REG, %dx
	mov $ATA_DRV_MA_LBA, %al # 0b11100000
	out %al, %dx

	# sector count
	mov $ATA_SECT_CNT_REG, %dx
	mov 0x0C(%bp), %ax # sect_cnt
	mov %ax, %bx # sect_cnt
	out %al, %dx

	# {{{ LBA
	mov $ATA_LBA_LO_REG, %dx
	mov 0x0A(%bp), %ax # lba_lo
	out %al, %dx

	mov $ATA_LBA_MID_REG, %dx
	mov %ah, %al # lba_mid
	out %al, %dx

	mov $ATA_LBA_HI_REG, %dx
	mov 0x08(%bp), %ax # lba_hi
	out %al, %dx
	# }}}

	# read
	mov $ATA_CMD_REG, %dx
	mov $ATA_CMD_READ, %al
	out %al, %dx
	jmp .drq__lp

.sect__lp:
	mov $ATA_STAT_REG, %dx

.drq__lp:
	in %dx, %al
	test $ATA_STAT_DRQ, %al
	jz .drq__lp

	# TODO: err

	mov $ATA_DATA_REG, %dx
	mov $ATA_SECT_SIZE_WORD, %cx
	sub $0x01, %bx # sect_cnt

.data__lp:
	# (count == 0) ? {end}
	test %cx, %cx
	jz .data__end

	# load
	in %dx, %ax
	mov %ax, %es:(%di)

	# {lp}
	sub $0x01, %cx
	add $0x02, %di
	jmp .data__lp

.data__end:
.bsy__lp:
	mov $ATA_STAT_REG, %dx
	in %dx, %al
	test $ATA_STAT_BSY, %al
	jnz .bsy__lp

	# (sect_cnt == 0) ? {done} : {sec.lp}
	test %bx, %bx
	jz .done
	jmp .sect__lp

.done:
	mov 0x04(%bp), %dx
	mov 0x06(%bp), %ax

	pop %bx
	pop %di
	pop %es
	pop %bp
	ret
