# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# read/write disk

.include "io.s"

.code16
.section .text

.global sys_read_disk
.global sys_write_disk

# ENTRY
# sys_read_disk()
sys_read_disk:
  # read disk
  clc
  mov $dap, %si
  mov $DISK_READ_MODE, %ah
  mov $DISK_PRIMARY_DRV, %dl
  int $INT_DISK
  ret

# ENTRY
# sys_write_disk()
sys_write_disk:
  # write disk
  clc
  mov $dap, %si
  mov $DISK_WRITE_MODE, %ah
  mov $DISK_PRIMARY_DRV, %dl
  int $INT_DISK
  ret
