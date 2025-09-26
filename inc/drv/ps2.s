# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Personal System 2

# reference link
# https://www.eecg.utoronto.ca/~jayar/ece241_08F/AudioVideoCores/ps2/ps2.html
# https://www-ug.eecg.toronto.edu/msl/nios_devices/datasheets/PS2%20Keyboard%20Protocol.htm

.equ PS2_DATA_REG, 0x60
.equ PS2_CMD_REG, 0x64
.equ PS2_STAT_REG, 0x64

# Commands
.equ PS2_READ_CONF_BYTE, 0x20
.equ PS2_WRITE_CONF_BYTE, 0x60

.equ PS2_SC_EXT, 0xE0
.equ PS2_SC_BRK, 0xF0

# Bits
.equ PS2_OBF, (0x01<<0x00)
.equ PS2_IBF, (0x01<<0x01)
.equ PS2_XLATE_BIT, (0x01<<0x06)

.equ PS2_ACK, 0xFA

.macro IBF
0:
	in $PS2_STAT_REG, %al
	test $PS2_IBF, %al
	jnz 0b
.endm

.macro OBF
0:
	in $PS2_STAT_REG, %al
	test $PS2_OBF, %al
	jz 0b
.endm
