# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# [Command] Test runtime

.include "drv/rtc.s"
.section .text
.code16
.global cmd_test

# cmd_test()
cmd_test:
	call rtc_get
	push $date_zbuf
	call vga_puts
	add $0x02, %sp
	ret

