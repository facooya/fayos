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
	mov $(S_MAG&0xFFFF), %ax
	mov %ax, %es:S_MAG_OFF(%bx)
	mov $(S_MAG>>0x10), %ax
	mov %ax, %es:S_MAG_OFF+0x02(%bx)
	ret
