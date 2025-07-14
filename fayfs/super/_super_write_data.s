# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Write data in superblock disk

.include "fayfs/sb.s"
.section .text
.code16
.global _super_write_data

# {TASK}
# _super_write_data()
_super_write_data:
	# magic
	mov $SB_MAG_LO, %ax
	mov %ax, SB_MAG_LO_OFF(%bx)
	mov $SB_MAG_HI, %ax
	mov %ax, SB_MAG_HI_OFF(%bx)

	# sb lba
	mov $SB_LBA, %ax
	mov %ax, SB_LBA_OFF(%bx)

	# fst lba
	mov $FST_LBA, %ax
	mov %ax, FST_LBA_OFF(%bx)

	# fst blk
	mov $FST_BLK, %ax
	mov %ax, FST_BLK_OFF(%bx)

	# fst inum
	mov $FST_INUM, %ax
	mov %ax, FST_INUM_OFF(%bx)

	# i size
	mov $I_SIZE, %ax
	mov %ax, I_SIZE_OFF(%bx)
	ret
