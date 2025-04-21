# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Teletype

# !!! .include "io.s"

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
  mov $0x0E, %ah
  int $0x10
  ret

# ENTRY
# read_key()
read_key:
  # ret: ah = scan code
  # ret: al = ascii code

  # read key
  mov $0x00, %ah
  int $0x16
  ret

# ENTRY
# get_mode()
get_mode:
  # ret: ah = number of column

  # prol
  push %bx

  # get mode
  mov $0x0F, %ah
  int $0x10

  # epil
  pop %bx
  ret

# ENTRY
# scroll_up()
scroll_up:
  # pre: dh = endY
  # pre: dl = endX

  # prol
  push %bx

  # scroll up
  mov $0x06, %ah
  xor %al, %al
  mov $0x07, %bh
  xor %cx, %cx
  int $0x10

  # epil
  pop %bx
  ret
