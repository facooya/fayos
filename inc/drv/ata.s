# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Advanced Technology Attachment

# {{{ Registers
.equ ATA_DATA_REG, 0x01F0 # [2-byte]
#.equ ATA_ERR_REG, 0x01F1
#.equ ATA_FEAT_REG, 0x01F1
.equ ATA_SECT_CNT_REG, 0x01F2
.equ ATA_LBA_LO_REG, 0x01F3 # [1-byte]
.equ ATA_LBA_MID_REG, 0x01F4 # [1-byte]
.equ ATA_LBA_HI_REG, 0x01F5 # [1-byte]
.equ ATA_DRV_REG, 0x01F6
.equ ATA_CMD_REG, 0x01F7
.equ ATA_STAT_REG, 0x01F7
# }}}

# {{{ Driver
# bit 5,7: always 1
# bit 6: 1:lba, 0:chs
# bit 4: 1:slave, 0:master
.equ ATA_DRV_MA, 0xA0
.equ ATA_DRV_MA_LBA, 0xE0
# }}}

# Commands
.equ ATA_ID_DEV, 0xEC
.equ ATA_READ, 0x20
.equ ATA_WRITE, 0x30

# Bit
.equ ATA_DRQ, (0x01<<0x03)
.equ ATA_RDY, (0x01<<0x06)
.equ ATA_BSY, (0x01<<0x07)

.equ ATA_SECT_SIZE_WORD, 0x0100
# word cnt 0x3C-0x3D low first, 0xC4-0xC3 lo-hi
.equ ATA_REV_TOT_SECT_OFF, 0xC4 # [4-byte] i=0x100;i--

.macro BSY
0:
	mov $ATA_STAT_REG, %dx
	in %dx, %al
	test $ATA_BSY, %al
	jnz 0b
.endm

.macro RDY
0:
	mov $ATA_STAT_REG, %dx
	in %dx, %al
	test $ATA_RDY, %al
	jz 0b
.endm

.macro DRQ
0:
	mov $ATA_STAT_REG, %dx
	in %dx, %al
	test $ATA_DRQ, %al
	jz 0b
.endm
