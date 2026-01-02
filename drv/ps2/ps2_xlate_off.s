# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya

.include "drv/ps2.inc"
.section .text
.code16
.global ps2_xlate_off

# ps2_xlate_off()
ps2_xlate_off:
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
