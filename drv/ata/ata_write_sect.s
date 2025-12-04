# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya

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
# <mod> ata_stat
# <ret> dx:ax = seg:off
ata_write_sect:
	push %bp
	mov %sp, %bp
	push %bx

	mov $ata_stat, %bx
	mov 0x04(%bp), %ax # (*seg)
	mov %ax, ATA_STAT_SEG(%bx)
	mov 0x06(%bp), %ax # (*off)
	mov %ax, ATA_STAT_OFF(%bx)

	# set mode
	mov $ATA_DRV_REG, %dx
	mov $ATA_DRV_MA_LBA, %al
	out %al, %dx

	# delay 400ns
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
	mov %al, ATA_STAT_CNT(%bx)
	out %al, %dx

	# { lba
	mov $ATA_LBA_LO_REG, %dx
	mov 0x08(%bp), %ax # (lba)
	out %al, %dx # lba_lo

	mov $ATA_LBA_MID_REG, %dx
	mov %ah, %al
	out %al, %dx # lba_mid

	mov $ATA_LBA_HI_REG, %dx
	xor %ax, %ax
	out %al, %dx # lba_hi
	# }

	# write
	mov $ATA_CMD_REG, %dx
	mov $ATA_WRITE, %al
	mov %al, ATA_STAT_CMD(%bx)
	out %al, %dx

	# delay 400ns
	mov $ATA_STAT_REG, %dx
	in %dx, %al
	in %dx, %al
	in %dx, %al
	in %dx, %al

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
	mov ATA_STAT_OFF(%bx), %si
	mov ATA_STAT_SEG(%bx), %ax
	mov %ax, %ds
	mov $ATA_DATA_REG, %dx
	mov $ATA_SECT_SIZE_WORD, %cx
	rep outsw

	# delay 400ns, don't clear interrupt signal
	mov $ATA_ALT_STAT, %dx
	in %dx, %al
	in %dx, %al
	in %dx, %al
	in %dx, %al

	pop %ds # [s.1:seg]
	mov %si, ATA_STAT_OFF(%bx)
	pop %si # [s.0:off]
	sti

.wait_irq:
	hlt

	# (sect_cnt == 0) ? {done} : {lp}
	mov ATA_STAT_CNT(%bx), %al
	test %al, %al
	jz .done
	jmp .wait_irq

.done:
	mov 0x04(%bp), %dx
	mov 0x06(%bp), %ax

	pop %bx
	pop %bp
	ret
