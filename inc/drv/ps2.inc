# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya

# common
.equ PS2_ACK, 0xFA
.equ PS2_RESEND, 0xFE

# port
.equ PS2_PORT_DATA, 0x60
.equ PS2_PORT_STAT, 0x64
.equ PS2_PORT_CMD, 0x64

# { command
.equ PS2_CMD_READ_CONF, 0x20
.equ PS2_CMD_WRITE_CONF, 0x60

# scan code set
.equ PS2_DATA_DISABLE_SCAN, 0xF5
.equ PS2_DATA_ENABLE_SCAN, 0xF4
.equ PS2_DATA_GET_SET_SCS, 0xF0
.equ PS2_DATA_GET_SCS, 0x00
# }

# { scan code
.equ PS2_SC_EXT, 0xE0
.equ PS2_SC_BRK, 0xF0

# mod
.equ PS2_SC_LSHF, 0x0012
.equ PS2_SC_RSHF, 0x0059
.equ PS2_SC_LCTL, 0x0014
.equ PS2_SC_RCTL, 0xE014
.equ PS2_SC_LALT, 0x0011
.equ PS2_SC_RALT, 0xE011
.equ PS2_SC_CAP, 0x0058

# arrow
.equ PS2_SC_UP, 0xE075
.equ PS2_SC_DOWN, 0xE072
.equ PS2_SC_LEFT, 0xE06B
.equ PS2_SC_RIGHT, 0xE074

# numpad
.equ PS2_SC_NUM_SL, 0xE04A
.equ PS2_SC_NUM_ENT, 0xE05A

# nav
.equ PS2_SC_PAGE_UP, 0xE07D
.equ PS2_SC_PAGE_DOWN, 0xE07A
# }

# { bit
.equ PS2_OBF, (0x01<<0x00)
.equ PS2_IBF, (0x01<<0x01)
.equ PS2_CONF_XLATE, (0x01<<0x06)

.equ PS2_SCF_BRK, (0x01<<0x00)
.equ PS2_SCF_EXT, (0x01<<0x01)
# }

# { macro
.macro IBF
0:
	in $PS2_PORT_STAT, %al
	test $PS2_IBF, %al
	jnz 0b
.endm

.macro OBF
0:
	in $PS2_PORT_STAT, %al
	test $PS2_OBF, %al
	jz 0b
.endm
# }
