# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya

.include "drv/ps2.s"
.section .text
.code16
.global ps2_chk_sc_set

# ps2_chk_sc_set()
ps2_chk_sc_set:
	xor %ax, %ax

	IBF
	mov $PS2_DIS_SCAN, %al
	out %al, $PS2_DATA_REG
	OBF
	in $PS2_DATA_REG, %al # ok 0xFA

	IBF
	mov $PS2_CUR_SC_SET, %al
	out %al, $PS2_DATA_REG
	OBF
	in $PS2_DATA_REG, %al # ok 0xFA

	IBF
	mov $PS2_GET_SC_SET, %al
	out %al, $PS2_DATA_REG
	OBF
	in $PS2_DATA_REG, %al # ok 0xFA
	OBF
	in $PS2_DATA_REG, %al # sc_set
	# TODO: log

	IBF
	mov $PS2_EN_SCAN, %al
	out %al, $PS2_DATA_REG
	OBF
	in $PS2_DATA_REG, %al # ok 0xFA
	ret
