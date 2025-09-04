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
	#call off_conf_byte_bit6
	#call chk_scan_code_set

	#call read_key
	#call read_disk2
	#call write_disk2
	#call read_disk3
	ret
