# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2026 Facooya and Fanone Facooya

.include "drv/ps2.inc"
.section .text
.code16
.global ps2_init

# ps2_init()
ps2_init:
	call _ps2_xlate_off
	call _ps2_chk_sc_set
	ret

# _ps2_xlate_off()
_ps2_xlate_off:
	IBF
	mov $PS2_CMD_READ_CONF, %al
	out %al, $PS2_PORT_CMD

	OBF
	in $PS2_PORT_DATA, %al
	and $~PS2_CONF_XLATE, %al
	mov %al, %ah

	IBF
	mov $PS2_CMD_WRITE_CONF, %al
	out %al, $PS2_PORT_CMD

	IBF
	mov %ah, %al
	out %al, $PS2_PORT_DATA
	ret

# _ps2_chk_sc_set()
_ps2_chk_sc_set:
	xor %ax, %ax

	IBF
	mov $PS2_DATA_DISABLE_SCAN, %al
	out %al, $PS2_PORT_DATA
	OBF
	in $PS2_PORT_DATA, %al # ok 0xFA

	IBF
	mov $PS2_DATA_GET_SET_SCS, %al
	out %al, $PS2_PORT_DATA
	OBF
	in $PS2_PORT_DATA, %al # ok 0xFA

	IBF
	mov $PS2_DATA_GET_SCS, %al
	out %al, $PS2_PORT_DATA
	OBF
	in $PS2_PORT_DATA, %al # ok 0xFA
	OBF
	in $PS2_PORT_DATA, %al # sc_set
	# TODO: log

	IBF
	mov $PS2_DATA_ENABLE_SCAN, %al
	out %al, $PS2_PORT_DATA
	OBF
	in $PS2_PORT_DATA, %al # ok 0xFA
	ret
