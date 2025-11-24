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
	call rtc_init
	call dbg_a
	mov (sec), %ax
	push %ax
	call dbg_reg
	add $0x02, %sp

	xor %ax, %ax
	mov $RTC_REG_NMI_A, %al
	out %al, $RTC_PORT_ADDR
	in $RTC_PORT_DATA, %al

	push %ax
	call dbg_reg
	add $0x02, %sp

	mov $RTC_REG_NMI_B, %al
	out %al, $RTC_PORT_ADDR
	in $RTC_PORT_DATA, %al

	push %ax
	call dbg_reg
	add $0x02, %sp
	ret

