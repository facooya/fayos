# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Personal System 2

# reference link
# https://www.eecg.utoronto.ca/~jayar/ece241_08F/AudioVideoCores/ps2/ps2.html
# https://www-ug.eecg.toronto.edu/msl/nios_devices/datasheets/PS2%20Keyboard%20Protocol.htm

# Common
.equ PS2_DATA_REG, 0x60
.equ PS2_CMD_REG, 0x64
.equ PS2_STAT_REG, 0x64

.equ PS2_ACK, 0xFA
.equ PS2_RE, 0xFE

# {{{ Command
.equ PS2_READ_CONF_BYTE, 0x20
.equ PS2_WRITE_CONF_BYTE, 0x60

# Scan code set
.equ PS2_DIS_SCAN, 0xF5
.equ PS2_EN_SCAN, 0xF4
.equ PS2_CUR_SC_SET, 0xF0
.equ PS2_GET_SC_SET, 0x00
# }}}

# {{{ Scan code
.equ PS2_SC_EXT, 0xE0
.equ PS2_SC_BRK, 0xF0

# Mod
.equ PS2_SC_LSHF, 0x0012
.equ PS2_SC_RSHF, 0x0059
.equ PS2_SC_LCTL, 0x0014
.equ PS2_SC_LALT, 0x0011
.equ PS2_SC_RCTL, 0xE014
.equ PS2_SC_RALT, 0xE011
.equ PS2_SC_CAP, 0x0058

# Arrow
.equ PS2_SC_UP, 0xE075
.equ PS2_SC_DOWN, 0xE072
.equ PS2_SC_LEFT, 0xE06B
.equ PS2_SC_RIGHT, 0xE074

# Numpad
.equ PS2_SC_NUM_SL, 0xE04A
.equ PS2_SC_NUM_ENT, 0xE05A
# }}}

# Bits
.equ PS2_OBF, (0x01<<0x00)
.equ PS2_IBF, (0x01<<0x01)
.equ PS2_XLATE_BIT, (0x01<<0x06)

.equ PS2_SC_BIT_BRK, (0x01<<0x00)
.equ PS2_SC_BIT_EXT, (0x01<<0x01)

# Macro
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
