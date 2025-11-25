# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# [Command] Print date

.section .text
.code16
.global cmd_date

# cmd_date()
cmd_date:
	call rtc_get
	# <mod: date_zbuf>

	xor %ax, %ax
	push $date_zbuf # (&off)
	push %ax # (&seg)
	call puts
	add $0x04, %sp

	call putnl
	xor %ax, %ax
	jmp .done

.done:
	ret
