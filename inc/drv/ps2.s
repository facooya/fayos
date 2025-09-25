# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Personal System 2

.equ PS2_DATA_REG, 0x60
.equ PS2_CMD_REG, 0x64
.equ PS2_STAT_REG, 0x64

# Commands
.equ PS2_READ_CONF_BYTE, 0x20
.equ PS2_WRITE_CONF_BYTE, 0x60

# Bits
.equ PS2_OBF, (1<<0)
.equ PS2_IBF, (1<<1)

.equ PS2_ACK, 0xFA
