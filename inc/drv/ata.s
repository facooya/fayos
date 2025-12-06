# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya

# { port
.equ ATA_PORT_DATA, 0x01F0
#.equ ATA_PORT_ERR, 0x01F1
#.equ ATA_PORT_FEAT, 0x01F1
.equ ATA_PORT_SECT_CNT, 0x01F2
.equ ATA_PORT_LBA_LO, 0x01F3
.equ ATA_PORT_LBA_MID, 0x01F4
.equ ATA_PORT_LBA_HI, 0x01F5
.equ ATA_PORT_DRV, 0x01F6
.equ ATA_PORT_STAT, 0x01F7
.equ ATA_PORT_CMD, 0x01F7
.equ ATA_PORT_ALT_STAT, 0x03F6
.equ ATA_PORT_DCR, 0x03F6
# }

# { register
.equ ATA_DRV_MA_LBA, 0xE0

.equ ATA_STAT_DRQ, (0x01<<0x03)
.equ ATA_STAT_DRDY, (0x01<<0x06)
.equ ATA_STAT_BSY, (0x01<<0x07)

.equ ATA_CMD_ID_DEV, 0xEC
.equ ATA_CMD_READ, 0x20
.equ ATA_CMD_WRITE, 0x30

.equ ATA_DCR_NIEN, (0x01<<0x01)
# }

# { ata_buf offset
.equ ATA_BUF_CMD, 0x00
.equ ATA_BUF_CNT, 0x01
.equ ATA_BUF_SEG, 0x02
.equ ATA_BUF_OFF, 0x04
# }

.equ ATA_SECT_SIZE_WORD, 0x0100
.equ ATA_OFF_TOT_SECT, 0x3C
.equ ATA_MAX_TOT_SECT, 0x0007FFF8

.macro BSY
0:
	mov $ATA_PORT_ALT_STAT, %dx
	in %dx, %al
	test $ATA_STAT_BSY, %al
	jnz 0b
.endm

.macro DRDY
0:
	mov $ATA_PORT_ALT_STAT, %dx
	in %dx, %al
	test $ATA_STAT_DRDY, %al
	jz 0b
.endm

.macro DRQ
0:
	mov $ATA_PORT_ALT_STAT, %dx
	in %dx, %al
	test $ATA_STAT_DRQ, %al
	jz 0b
.endm
