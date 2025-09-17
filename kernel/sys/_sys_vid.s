# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Video services

.include "sys.s"
.section .text
.code16
.global _sys_get_cursor
.global _sys_set_cursor
.global _sys_tty_out

# _sys_get_cursor()
# <ret> dh = y
# <ret> dl = x
_sys_get_cursor:
	mov $VID_GET_CURSOR, %ah
	xor %bh, %bh # VID_CURSOR_PAGE_NUM
	int $INT_VID
	ret

# _sys_set_cursor()
# <req> dh = y
# <req> dl = x
_sys_set_cursor:
	mov $VID_SET_CURSOR, %ah
	xor %bh, %bh # VID_CURSOR_PAGE_NUM
	int $INT_VID
	ret

# _sys_tty_out()
# <req> al = chr
_sys_tty_out:
	mov $VID_TTY_OUT, %ah
	int $INT_VID
	ret
