# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# get/set cursor

.code16
.section .text

.global get_cursor
.global set_cursor

get_cursor:
  # ret: dh = y
  # ret: dl = x

  # prol
  push %bx

  # get cursor
  mov $0x03, %ah
  mov $0x00, %bh
  int $0x10

  # epil
  pop %bx
  ret

set_cursor:
  # pre: dh = y
  # pre: dl = x

  # prol
  push %bx

  # set cursor
  mov $0x02, %ah
  mov $0x00, %bh
  int $0x10

  # epil
  pop %bx
  ret
