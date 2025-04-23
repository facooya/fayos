# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Teletype

.include "io.s"

.code16
.section .text

.global out_chr
.global read_key
.global get_mode
.global scroll_up

# ENTRY
# out_chr
out_chr:
  # pre: al = chr

  # out chr
  mov $VID_TTY_OUT, %ah
  int $INT_VID
  ret

# ENTRY
# read_key()
read_key:
  # ret: ah = scan code
  # ret: al = ascii code

  # read key
  xor %ah, %ah # KBD_READ_KEY
  int $INT_KBD
  ret

# ENTRY
# get_mode()
get_mode:
  # ret: ah = number of column

  # get mode
  mov $VID_GET_MODE, %ah
  int $INT_VID
  ret

# ENTRY
# scroll_up()
scroll_up:
  # pre: dh = end_y
  # pre: dl = end_x

  # scroll up
  mov $VID_SCROLL_UP, %ah
  xor %al, %al # VID_SCROLL_FULL
  mov $VID_SCROLL_COLOR_ATTR, %bh
  xor %cx, %cx # VID_SCROLL_START_Y, VID_SCROLL_START_X
  int $INT_VID
  ret
