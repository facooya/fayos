# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Teletype

.code16
.section .text

.global out_chr
.global read_key

out_chr:
  # pre: al = chr

  # out chr
  mov $0x0E, %ah
  ret

read_key:
  # ret: ah = scan code
  # ret: al = ascii code
  
  # read key
  mov $0x00, %ah
  int $0x16
  ret
