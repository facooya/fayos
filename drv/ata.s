# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2026 Facooya and Fanone Facooya

.include "int.inc"
.include "drv/ata.inc"
.include "drv/disk.inc"
.section .text
.code16
.global ata_get_sect
.global ata_init
.global ata_read_sect
.global ata_write_sect

# ata_get_sect()
# <ret: [dx:ax] = [tot_sect_hi:tot_sect_lo]>
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

	# delay 400ns
	mov $ATA_PORT_ALT_STAT, %dx
	in %dx, %al
	in %dx, %al
	in %dx, %al
	in %dx, %al

	DRQ

	mov $ATA_PORT_DATA, %dx
	xor %cx, %cx

# data
10:
	# (cnt == 0) ? {end}
	cmp $ATA_SECT_SIZE_WORD, %cx
	je 19f

	in %dx, %ax
	cmp $ATA_OFF_TOT_SECT, %cx
	je 11f

	inc %cx
	jmp 10b

11: # save total sector
	push %ax # [s.d0:sect_lo]
	in %dx, %ax
	push %ax # [s.d1:sect_hi]

	add $0x02, %cx
	jmp 10b

19:
	mov $ATA_PORT_ALT_STAT, %dx
	in %dx, %al
	test $ATA_STAT_DRQ, %al
	jnz 8000f

	pop %dx # <ret:hi> [s.d1:sect_hi]
	pop %ax # <ret:lo> [s.d0:sect_lo]

# max
20:
	# TODO: log
	# { max
	# (sect_hi == 0) ? {end}
	test %dx, %dx
	jz 29f

	# set max
	mov $(ATA_MAX_TOT_SECT>>0x10), %dx
	mov $(ATA_MAX_TOT_SECT&0xFFFF), %ax

29:
	# }
	push %dx # [s.c0:sect_hi]
	push %ax # [s.c1:sect_lo]

	xor %dx, %dx
	mov $DISK_BLK_SECT_CNT, %cx
	div %cx

	# TODO: log
	test %dx, %dx
	jz 1f

	# turncate
	pop %ax # [s.c1:sect_lo]
	xor %dx, %dx
	mov $DISK_BLK_SECT_CNT, %cx
	mul %cx
	push %ax # [s.c2:sect_lo]

1:
	pop %ax # <ret:lo> [s.c2:sect_lo]
	pop %dx # <ret:hi> [s.c0:sect_hi]

80:
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

8000:
	pop %dx # <ret:hi> [s.d1:sect_hi]
	pop %ax # <ret:lo> [s.d0:sect_lo]
	# TODO: err chk
	call dbg_a # HACK
	jmp 80b

# ata_init()
ata_init:
	# int enable
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
	ret

# ata_read_sect(
# ub16 *seg,
# ub16 *off,
# ub16 lba,
# ub16 sect_cnt
# )
# <mod: ata_buf>
# <ret: [dx:ax] = [seg:off]>
ata_read_sect:
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
	mov $ATA_DRV_MA_LBA, %al # 0b11100000
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

	# read
	cli
	mov $ATA_PORT_CMD, %dx
	mov $ATA_CMD_READ, %al
	mov %al, ATA_BUF_CMD(%bx)
	out %al, %dx

	# delay 400ns
	mov $ATA_PORT_ALT_STAT, %dx
	in %dx, %al
	in %dx, %al
	in %dx, %al
	in %dx, %al
	sti

1:
	# (sect_cnt == 0) ? {done} : {lp}
	mov ATA_BUF_CNT(%bx), %al
	test %al, %al
	jz 90f
	hlt
	jmp 1b

90:
	mov 0x04(%bp), %dx
	mov 0x06(%bp), %ax

	pop %bx
	pop %bp
	ret

# ata_write_sect(
# ub16 *seg,
# ub16 *off,
# ub16 lba,
# ub16 sect_cnt
# )
# <mod: ata_buf>
# <ret: [dx:ax] = [seg:off]>
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

1: # data request
	mov $ATA_PORT_ALT_STAT, %dx
	in %dx, %al
	test $ATA_STAT_DRQ, %al
	jz 1b

	cli
	push %si # [s.0:off]
	push %ds # [s.1:seg]
	mov ATA_BUF_OFF(%bx), %si
	mov ATA_BUF_SEG(%bx), %ax
	mov %ax, %ds
	mov $ATA_PORT_DATA, %dx
	mov $ATA_SECT_SIZE_WORD, %cx
	rep outsw

	# delay 400ns
	mov $ATA_PORT_ALT_STAT, %dx
	in %dx, %al
	in %dx, %al
	in %dx, %al
	in %dx, %al

	pop %ds # [s.1:seg]
	mov %si, ATA_BUF_OFF(%bx)
	pop %si # [s.0:off]
	sti

1: # wait interrupt
	hlt

	# (sect_cnt == 0) ? {done} : {lp}
	mov ATA_BUF_CNT(%bx), %al
	test %al, %al
	jz 90f
	jmp 1b

90:
	mov 0x04(%bp), %dx
	mov 0x06(%bp), %ax

	pop %bx
	pop %bp
	ret

.section .data
.global ata_buf
ata_buf: .zero 0x06
