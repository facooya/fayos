# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# get/set cursor

.include "io.s"

.code16
.section .text

.global get_cursor
.global set_cursor

get_cursor:
  # ret: dh = y
  # ret: dl = x

  # get cursor
  mov $VID_GET_CURSOR, %ah
  xor %bh, %bh # VID_CURSOR_PAGE_NUM
  int $INT_VID
  ret

set_cursor:
  # pre: dh = y
  # pre: dl = x

  # set cursor
  mov $VID_SET_CURSOR, %ah
  xor %bh, %bh # VID_CURSOR_PAGE_NUM
  int $INT_VID
  ret
