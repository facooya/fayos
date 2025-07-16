# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Write data in superblock disk

.include "fayfs/super.s"
.section .text
.code16
.global _super_write_data

# _super_write_data()
_super_write_data:
	# magic
	mov $S_MAG_LO, %ax
	mov %ax, S_MAG_LO_OFF(%bx)
	mov $S_MAG_HI, %ax
	mov %ax, S_MAG_HI_OFF(%bx)
	ret
