# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Teletype

.include "io.s"

.code16
.section .text

.global sys_out_chr
.global sys_read_key
.global sys_get_mode
.global sys_scroll_up

# ENTRY
# sys_out_chr()
sys_out_chr:
  # pre: al = chr

  # out chr
  mov $VID_TTY_OUT, %ah
  int $INT_VID
  ret

# ENTRY
# sys_read_key()
sys_read_key:
  # ret: ah = scan code
  # ret: al = ascii code

  # read key
  xor %ah, %ah # KBD_READ_KEY
  int $INT_KBD
  ret

# ENTRY
# sys_get_mode()
sys_get_mode:
  # ret: ah = number of column

  # get mode
  mov $VID_GET_MODE, %ah
  int $INT_VID
  ret

# ENTRY
# sys_scroll_up()
sys_scroll_up:
  # pre: dh = end_y
  # pre: dl = end_x

  # scroll up
  mov $VID_SCROLL_UP, %ah
  xor %al, %al # VID_SCROLL_FULL
  mov $VID_SCROLL_COLOR_ATTR, %bh
  xor %cx, %cx # VID_SCROLL_START_Y, VID_SCROLL_START_X
  int $INT_VID
  ret
