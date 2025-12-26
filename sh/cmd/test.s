# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# [Command] Test runtime

.include "drv/rtc.s"
.section .text
.code16
.global cmd_test
.global cmd_test2

# cmd_test()
cmd_test:
	xor %ax, %ax
	mov $0xFF, %al
	push %ax
	call ub8_h_to_d
	add $0x02, %sp

	push %ax
	call dbg_reg
	add $0x02, %sp
	ret
