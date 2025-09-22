# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Command test - temporary debug and test runtime

.section .data
.blknum: .long 0x01

.section .text
.code16
.global cmd_test

# cmd_test()
cmd_test:
	#call ata_get_sect
	ret
