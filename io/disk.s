# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# read/write disk

.code16
.section .text

.global read_disk
.global write_disk

read_disk:
  mov $0x42, %ah
  jmp .rw_disk

write_disk:
  mov $0x43, %ah
  jmp .rw_disk

.rw_disk:
  # pre: ah = mode
  # ret: cf
  # ret: ah = err_code

  # prol
  push %si

  # read/write disk
  clc
  mov $dap, %si
  mov $0x80, %dl
  int $0x13

  # epil
  pop %si
  ret
