# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Off command byte bit 6

.section .text
.code16
.global off_cmd_byte_bit6

off_cmd_byte_bit6:
	xor %ax, %ax

	# get cmd_byte
	mov $0x20, %al
	out %al, $0x64

.ibf:
	in $0x64, %al
	test $0x02, %al
	jnz .ibf

	# get cmd_byte
	in $0x60, %al

	# {{{ off bit 6
	and $0xBF, %al
	mov %al, %ah

	# write cmd_byte
	mov $0x60, %al
	out %al, $0x64

	# store cmd_byte
	mov %ah, %al
	out %al, $0x60
	# }}}
	ret
