# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya

.include "drv/ps2.inc"
.section .text
.code16
.global ps2_chk_sc_set

# ps2_chk_sc_set()
ps2_chk_sc_set:
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
