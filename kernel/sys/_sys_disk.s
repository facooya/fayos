# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Disk services

.include "sys.s"
.section .text
.code16
.global _sys_read_disk
.global _sys_write_disk
.global _sys_read_disk_param

# _sys_read_disk()
# <req> si = &dap
# <ret> cf
_sys_read_disk:
	clc
	mov $DISK_READ_MODE, %ah
	mov $DISK_PRIMARY_DRV, %dl
	int $INT_DISK
	ret

# _sys_write_disk()
# <req> si = &dap
# <ret> cf
_sys_write_disk:
	clc
	mov $DISK_WRITE_MODE, %ah
	mov $DISK_PRIMARY_DRV, %dl
	int $INT_DISK
	ret

# _sys_read_disk_param()
# <ret> cf
_sys_read_disk_param:
	clc
	xor %ax, %ax
	mov %ax, %ds
	mov $DISK_READ_PARAM_BUF_SIZE, %ax
	mov %ax, (%si)
	mov $DISK_READ_PARAM, %ah
	mov $DISK_PRIMARY_DRV, %dl
	int $INT_DISK
	ret
