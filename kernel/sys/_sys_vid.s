# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Video services

.include "sys.s"
.section .text
.code16
.global _sys_tty_out

# _sys_tty_out()
# <req> al = chr
_sys_tty_out:
	mov $VID_TTY_OUT, %ah
	int $INT_VID
	ret
