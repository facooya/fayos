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
.global _sys_scroll_up
.global _sys_tty_out
.global _sys_get_mode

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

# _sys_scroll_up()
# <req> dh = end_y
# <req> dl = end_x
_sys_scroll_up:
	mov $VID_SCROLL_UP, %ah
	xor %al, %al # VID_SCROLL_FULL
	mov $VID_SCROLL_COLOR_ATTR, %bh
	xor %cx, %cx # VID_SCROLL_START_Y, VID_SCROLL_START_X
	int $INT_VID
	ret

# _sys_tty_out()
# <req> al = chr
_sys_tty_out:
	mov $VID_TTY_OUT, %ah
	int $INT_VID
	ret

# _sys_get_mode()
# <ret> ah = end_x
_sys_get_mode:
	mov $VID_GET_MODE, %ah
	int $INT_VID
	ret

