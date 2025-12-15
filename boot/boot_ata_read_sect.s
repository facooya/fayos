# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya

.include "boot.s"
.section .text
.code16
.global boot_ata_read_sect

# boot_ata_read_sect()
boot_ata_read_sect:
	# set mode
	mov $ATA_PORT_DRV, %dx
	mov $ATA_DRV_MA_LBA, %al
	out %al, %dx

	# delay 400ns
	mov $ATA_PORT_STAT, %dx
	in %dx, %al
	in %dx, %al
	in %dx, %al
	in %dx, %al

	# sector count
	mov $ATA_PORT_SECT_CNT, %dx
	mov $KERN_SECT_CNT, %al
	mov $KERN_SECT_CNT, %bx
	out %al, %dx

	# { lba
	mov $ATA_PORT_LBA_LO, %dx
	mov $KERN_LBA, %ax
	out %al, %dx

	mov $ATA_PORT_LBA_MID, %dx
	mov %ah, %al
	out %al, %dx

	mov $ATA_PORT_LBA_HI, %dx
	xor %ax, %ax
	out %al, %dx
	# }

	# read
	mov $ATA_PORT_CMD, %dx
	mov $ATA_CMD_READ, %al
	out %al, %dx

	# delay 400ns
	mov $ATA_PORT_STAT, %dx
	in %dx, %al
	in %dx, %al
	in %dx, %al
	in %dx, %al
	jmp .drq__lp

.sect__lp:
	mov $ATA_PORT_STAT, %dx

.drq__lp:
	in %dx, %al
	test $ATA_STAT_DRQ, %al
	jz .drq__lp

	# TODO: error

	mov $ATA_PORT_DATA, %dx
	mov $ATA_SECT_SIZE_WORD, %cx
	sub $0x01, %bx # sector count

.data__lp:
	# (count == 0) ? {end}
	test %cx, %cx
	jz .data__end

	# load
	in %dx, %ax
	mov %ax, %es:(%di)

	sub $0x01, %cx
	add $0x02, %di
	jmp .data__lp

.data__end:
	# (sector == 0) ? {done} : {sec.lp}
	test %bx, %bx
	jz .done
	jmp .sect__lp

.done:
	ret
