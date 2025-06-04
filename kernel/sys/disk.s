# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Disk services

.include "sys.s"

.section .text
.code16
.global sys_read_disk
.global sys_write_disk

# ENTRY
# sys_read_disk()
# ret: cf
sys_read_disk:
	clc
	mov $dap, %si
	mov $DISK_READ_MODE, %ah
	mov $DISK_PRIMARY_DRV, %dl
	int $INT_DISK
	ret

# ENTRY
# sys_write_disk()
# ret: cf
sys_write_disk:
	clc
	mov $dap, %si
	mov $DISK_WRITE_MODE, %ah
	mov $DISK_PRIMARY_DRV, %dl
	int $INT_DISK
	ret
