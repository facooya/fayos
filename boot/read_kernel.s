# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Read kernel disk for boot

# read_kernel()
read_kernel:
	# set mode
	mov $ATA_DRV_REG, %dx
	mov $ATA_DRV_SET, %al # 0b11100000
	out %al, %dx

	# sector count
	mov $ATA_SECT_CNT_REG, %dx
	mov $KERN_SECT_CNT, %al
	mov $KERN_SECT_CNT, %bx
	out %al, %dx

	# {{{ LBA
	mov $ATA_LBA_LO_REG, %dx
	mov $KERN_LBA_LO, %al
	out %al, %dx

	mov $ATA_LBA_MID_REG, %dx
	mov $KERN_LBA_MID, %al
	out %al, %dx

	mov $ATA_LBA_HI_REG, %dx
	mov $KERN_LBA_HI, %al
	out %al, %dx
	# }}}

	# read
	mov $ATA_CMD_REG, %dx
	mov $ATA_CMD_READ, %al
	out %al, %dx
	jmp .read_kernel__drq__lp

.read_kernel__sect__lp:
	mov $ATA_STAT_REG, %dx

.read_kernel__drq__lp:
	in %dx, %al
	test $ATA_STAT_DRQ, %al
	jz .read_kernel__drq__lp

	# TODO: error

	mov $ATA_DATA_REG, %dx
	mov $SECT_SIZE_WORD, %cx
	sub $0x01, %bx # sector count

.read_kernel__data__lp:
	# (count == 0) ? {end}
	test %cx, %cx
	jz .read_kernel__data__end

	# load
	in %dx, %ax
	mov %ax, %es:(%di)

	# {lp}
	sub $0x01, %cx
	add $0x02, %di
	jmp .read_kernel__data__lp

.read_kernel__data__end:
	# (sector == 0) ? {done} : {sec.lp}
	test %bx, %bx
	jz .read_kernel__disk__done
	jmp .read_kernel__sect__lp

.read_kernel__disk__done:
	ret
