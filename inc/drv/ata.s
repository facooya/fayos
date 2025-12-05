# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya

# { ports
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

# {{{ Driver
.equ ATA_DRV_MA, 0xA0
.equ ATA_DRV_MA_LBA, 0xE0
# }}}

# Commands
.equ ATA_ID_DEV, 0xEC
.equ ATA_READ, 0x20
.equ ATA_WRITE, 0x30

# Bit
.equ ATA_DRQ, (0x01<<0x03)
.equ ATA_DRDY, (0x01<<0x06)
.equ ATA_BSY, (0x01<<0x07)

# NIEN: Nagative Interrupt ENable
.equ ATA_DCR_NIEN, (0x01<<0x01) # 0:enable, 1:disable

.equ ATA_SECT_SIZE_WORD, 0x0100
# word cnt 0x3C-0x3D low first, 0xC4-0xC3 lo-hi
.equ ATA_REV_TOT_SECT_OFF, 0xC4 # [4-byte] i=0x100;i--

# Offset
.equ ATA_STAT_CMD, 0x00
.equ ATA_STAT_CNT, 0x01
.equ ATA_STAT_SEG, 0x02
.equ ATA_STAT_OFF, 0x04

.macro BSY
0:
	mov $ATA_PORT_STAT, %dx
	in %dx, %al
	test $ATA_BSY, %al
	jnz 0b
.endm

.macro DRDY
0:
	mov $ATA_PORT_STAT, %dx
	in %dx, %al
	test $ATA_DRDY, %al
	jz 0b
.endm

.macro DRQ
0:
	mov $ATA_PORT_STAT, %dx
	in %dx, %al
	test $ATA_DRQ, %al
	jz 0b
.endm
