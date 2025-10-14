# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# [Disk] Constants

.equ DNUM_SB, 0x00
.equ DNUM_BBM, 0x01
.equ DNUM_IBM, 0x02
.equ DNUM_IT, 0x03

.equ DIO_SIZE, 0x0A
.equ DIO_OFF_SECT_CNT, 0x00
.equ DIO_OFF_SEG, 0x02
.equ DIO_OFF_OFF, 0x04
.equ DIO_OFF_LBA_HI, 0x06
.equ DIO_OFF_LBA_LO, 0x08

.equ DIO_SB_SECT_CNT, 0x02
.equ DIO_SB_SEG, 0x00
.equ DIO_SB_OFF, 0x0600
.equ DIO_SB_LBA_HI, 0x00
.equ DIO_SB_LBA_LO, 0x01
