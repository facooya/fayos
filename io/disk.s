# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# read/write disk

.include "io.s"

.code16
.section .text

.global read_disk
.global write_disk

read_disk:
  mov $DISK_READ_MODE, %ah
  jmp .rw_disk

write_disk:
  mov $DISK_WRITE_MODE, %ah
  jmp .rw_disk

.rw_disk:
  # pre: ah = mode
  # ret: cf
  # ret: ah = err_code

  push %si # !!! REMOVE
  # read/write disk
  clc
  mov $dap, %si
  mov $DISK_PRIMARY_DRV, %dl
  int $INT_DISK

  pop %si # !!! REMOVE
  ret
