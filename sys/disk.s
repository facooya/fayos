# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# read/write disk

.include "io.s"

# _RW_DISK
.macro _RW_DISK
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
.endm

.code16
.section .text

.global read_disk
.global write_disk

read_disk:
  mov $DISK_READ_MODE, %ah
  _RW_DISK
  ret

write_disk:
  mov $DISK_WRITE_MODE, %ah
  _RW_DISK
  ret
