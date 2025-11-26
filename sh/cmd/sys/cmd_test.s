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
	#call rtc_init
	call dbg_a
	mov (sec), %ax
	push %ax
	call dbg_reg
	add $0x02, %sp
	ret

