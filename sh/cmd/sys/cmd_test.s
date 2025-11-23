# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# [Command] Test runtime

.section .text
.code16
.global cmd_test

# cmd_test()
cmd_test:
	call rtc_init
	int $0x28
	ret

