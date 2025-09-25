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
	xor %ax, %ax

	# read conf_byte
	mov $PS2_CMD_REG, %dx
	mov $PS2_READ_CONF_BYTE, %al
	out %al, %dx

	# conf_byte
	call ._ibf
	mov $PS2_DATA_REG, %dx
	in %dx, %al

	# {{{ off bit 6 - off translate
	and $~(1<<6), %al

	# write conf_byte
	mov %al, %ah
	mov $PS2_WRITE_CONF_BYTE, %al
	mov $PS2_CMD_REG, %dx
	out %al, %dx
	mov %ah, %al
	mov $PS2_DATA_REG, %dx
	out %al, %dx
	# }}}
	ret

._ibf:
	mov $PS2_STAT_REG, %dx
	in %dx, %al
	test $PS2_IBF, %al
	jnz ._ibf
	ret
