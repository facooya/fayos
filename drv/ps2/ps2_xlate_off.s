# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Translate bit off - off bit 6 in configuration byte

# reference link
# https://wiki.osdev.org/I8042_PS/2_Controller#PS/2_Controller_Commands
# https://wiki.osdev.org/I8042_PS/2_Controller#PS/2_Controller_Configuration_Byte

.include "drv/ps2.s"
.section .text
.code16
.global ps2_xlate_off

ps2_xlate_off:
	IBF
	mov $PS2_READ_CONF_BYTE, %al
	out %al, $PS2_CMD_REG

	OBF
	in $PS2_DATA_REG, %al # conf_byte
	and $~PS2_XLATE_BIT, %al
	mov %al, %ah

	IBF
	mov $PS2_WRITE_CONF_BYTE, %al
	out %al, $PS2_CMD_REG

	IBF
	mov %ah, %al
	out %al, $PS2_DATA_REG
	ret
