# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Command test - temporary debug and test runtime

.section .text
.code16
.global cmd_test

# cmd_test()
cmd_test:
	call off_conf_byte_bit6
	call chk_scan_code_set

	call get_cursor2
	add $0xA5, %ax
	push %ax
	call set_cursor2
	add $0x02, %sp
	hlt

	call read_key
	ret
