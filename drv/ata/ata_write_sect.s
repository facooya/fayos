# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya

.include "int.inc"
.include "drv/ata.inc"
.section .text
.code16
.global ata_write_sect

# ata_write_sect(
# ub16 *seg,
# ub16 *off,
# ub16 lba,
# ub16 sect_cnt
# )
# <mod> ata_buf
# <ret> dx:ax = seg:off
ata_write_sect:
	push %bp
	mov %sp, %bp
	push %bx

	mov $ata_buf, %bx
	mov 0x04(%bp), %ax # (*seg)
	mov %ax, ATA_BUF_SEG(%bx)
	mov 0x06(%bp), %ax # (*off)
	mov %ax, ATA_BUF_OFF(%bx)

	# set mode
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

	# sector count
	mov $ATA_PORT_SECT_CNT, %dx
	mov 0x0A(%bp), %ax # (sect_cnt)
	mov %al, ATA_BUF_CNT(%bx)
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

	# write
	mov $ATA_PORT_CMD, %dx
	mov $ATA_CMD_WRITE, %al
	mov %al, ATA_BUF_CMD(%bx)
	out %al, %dx

	# delay 400ns
	mov $ATA_PORT_ALT_STAT, %dx
	in %dx, %al
	in %dx, %al
	in %dx, %al
	in %dx, %al

.wait:
	mov $ATA_PORT_ALT_STAT, %dx
	in %dx, %al
	test $ATA_STAT_DRQ, %al
	jz .wait

	cli
	push %si # [s.0:off]
	push %ds # [s.1:seg]
	mov ATA_BUF_OFF(%bx), %si
	mov ATA_BUF_SEG(%bx), %ax
	mov %ax, %ds
	mov $ATA_PORT_DATA, %dx
	mov $ATA_SECT_SIZE_WORD, %cx
	rep outsw

	# delay 400ns, don't clear interrupt signal
	mov $ATA_PORT_ALT_STAT, %dx
	in %dx, %al
	in %dx, %al
	in %dx, %al
	in %dx, %al

	pop %ds # [s.1:seg]
	mov %si, ATA_BUF_OFF(%bx)
	pop %si # [s.0:off]
	sti

.wait_irq:
	hlt

	# (sect_cnt == 0) ? {done} : {lp}
	mov ATA_BUF_CNT(%bx), %al
	test %al, %al
	jz .done
	jmp .wait_irq

.done:
	mov 0x04(%bp), %dx
	mov 0x06(%bp), %ax

	pop %bx
	pop %bp
	ret
