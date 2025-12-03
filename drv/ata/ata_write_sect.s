# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Write sectors

# reference link
# https://wiki.osdev.org/ATA_read/write_sectors#ATA_write_sectors

.include "int.s"
.include "drv/ata.s"
.section .text
.code16
.global ata_write_sect

# ata_write_sect(
# ub16 *seg,
# ub16 *off,
# ub16 lba,
# ub16 sect_cnt
# )
# <ret> dx:ax = seg:off
ata_write_sect:
	push %bp
	mov %sp, %bp
	push %ds
	push %si

	mov 0x04(%bp), %ax # (*seg)
	mov %ax, (ata_seg)
	mov 0x06(%bp), %ax # (*off)
	mov %ax, (ata_off)

	# set mode
	mov $ATA_DRV_REG, %dx
	mov $ATA_DRV_MA_LBA, %al
	out %al, %dx

	# delay 400ns
	out %al, $IO_WAIT
	out %al, $IO_WAIT
	out %al, $IO_WAIT
	out %al, $IO_WAIT

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

	# write
	mov $ATA_CMD_REG, %dx
	mov $ATA_WRITE, %al
	mov %al, (ata_stat)
	out %al, %dx

.wait:
	mov $ATA_STAT_REG, %dx
	in %dx, %al
	test $ATA_BSY, %al
	jnz .wait
	test $ATA_DRQ, %al
	jz .wait

	cli
	push %si # [s.0:off]
	push %ds # [s.1:seg]
	mov (ata_off), %si
	mov (ata_seg), %ax
	mov %ax, %ds
	mov $ATA_DATA_REG, %dx
	mov $ATA_SECT_SIZE_WORD, %cx
	rep outsw

	# delay 400ns
	out %al, $IO_WAIT
	out %al, $IO_WAIT
	out %al, $IO_WAIT
	out %al, $IO_WAIT

	pop %ds # [s.1:seg]
	mov %si, (ata_off)
	pop %si # [s.0:off]
	sti

.wait_irq:
	hlt

	mov (ata_cnt), %ax
	test %ax, %ax
	jz .done

	jmp .wait_irq

.done:
	mov 0x04(%bp), %dx
	mov 0x06(%bp), %ax

	pop %si
	pop %ds
	pop %bp
	ret
