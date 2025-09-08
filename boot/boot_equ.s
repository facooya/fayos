# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Constant for boot

# BOOT
.equ STACK_PTR, 0x7C00
.equ FILL_REP, 0x01FE
.equ FILL_SIZE, 0x01
.equ FILL_VAL, 0x00
.equ BOOT_SIG, 0xAA55

# DISK
.equ KERN_SEG, 0x0000
.equ KERN_OFF, 0x1000

.equ KERN_SECT_CNT, 0x30
.equ KERN_LBA_LO, 0x10
.equ KERN_LBA_MID, 0x00
.equ KERN_LBA_HI, 0x00

.equ SECT_SIZE_WORD, 0x0100

# DISP
.equ CHR_NL, 0x0A
.equ CHR_SP, 0x20
.equ CONF_BG, 0x07

# VID
.equ VID_MEM_SEG, 0xB800
.equ VID_MEM_OFF, 0x0000
.equ DISP_MEM_ROW, 0x0484
.equ DISP_MEM_COL, 0x044A

# CURSOR
.equ CURS_POS_HI, 0x0E
.equ CURS_POS_LO, 0x0F
.equ CURS_CMD_REG, 0x03D4
.equ CURS_DATA_REG, 0x03D5

# ATA
.equ ATA_DATA_REG, 0x01F0 # only 16-bit
#.equ ATA_ERR_REG, 0x01F1
#.equ ATA_FEAT_REG, 0x01F1
.equ ATA_SECT_CNT_REG, 0x01F2
.equ ATA_LBA_LO_REG, 0x01F3 # LBA 0-7
.equ ATA_LBA_MID_REG, 0x01F4 # LBA 8-15
.equ ATA_LBA_HI_REG, 0x01F5 # LBA 16-23
.equ ATA_DRV_REG, 0x01F6
.equ ATA_STAT_REG, 0x01F7
.equ ATA_CMD_REG, 0x01F7

.equ ATA_CMD_READ, 0x20
.equ ATA_STAT_DRQ, 0x08 # bit 3

# 0b11100000
# bit 5,7: always 1
# bit 6: 1:lba, 0:chs
# bit 4: 1:slave, 0:master
.equ ATA_DRV_SET, 0xE0
