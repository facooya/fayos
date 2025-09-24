# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Advanced Technology Attachment

# {{{ REG
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

# {{{ DRV
# bit 5,7: always 1
# bit 6: 1:lba, 0:chs
# bit 4: 1:slave, 0:master
.equ ATA_DRV_MA, 0xA0
.equ ATA_DRV_MA_LBA, 0xE0
# }}}

# {{{ CMD
.equ ATA_CMD_ID_DEV, 0xEC
.equ ATA_CMD_READ, 0x20
.equ ATA_CMD_WRITE, 0x30
# }}}

# {{{ STAT
.equ ATA_STAT_DRQ, 0x08
.equ ATA_STAT_BSY, 0x80
# }}}

.equ ATA_SECT_SIZE_WORD, 0x0100
# word cnt 0x3C-0x3D low first, 0xC4-0xC3 lo-hi
.equ ATA_REV_TOT_SECT_OFF, 0xC4 # [4-byte] i=0x100;i--
