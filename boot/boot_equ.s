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
.equ KERNEL_SEG, 0x0000
.equ KERNEL_OFF, 0x1000

.equ KERNEL_SECTOR_CNT, 0x30
.equ KERNEL_LBA_LOW, 0x10
.equ KERNEL_LBA_MID, 0x00
.equ KERNEL_LBA_HIGH, 0x00

.equ SECTOR_SIZE_WORD, 0x0100

# DISP
.equ NEWLINE, 0x0A
.equ CONF_BG, 0x07
.equ SPACE, 0x20
