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
	call off_translate
	call kbd_scan_set
	ret
