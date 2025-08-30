# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Off configuration byte bit 6

# reference link
# https://wiki.osdev.org/I8042_PS/2_Controller#PS/2_Controller_Commands
# https://wiki.osdev.org/I8042_PS/2_Controller#PS/2_Controller_Configuration_Byte

.section .text
.code16
.global off_conf_byte_bit6

off_conf_byte_bit6:
	xor %ax, %ax

	# read conf_byte
	mov $0x20, %al
	out %al, $0x64

	# conf_byte
	call ._ibf
	in $0x60, %al

	# {{{ off bit 6 - off translation
	and $0xBF, %al

	# write conf_byte
	mov %al, %ah
	mov $0x60, %al
	out %al, $0x64
	mov %ah, %al
	out %al, $0x60
	# }}}
	ret

._ibf:
	in $0x64, %al
	test $0x02, %al
	jnz ._ibf
	ret
