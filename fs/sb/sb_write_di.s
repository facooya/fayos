# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# [Superblock] Write disk immutable cache

.include "drv/disk.s"
.include "fs/sb.s"
.section .text
.code16
.global sb_write_di

# sb_write_di()
# <mod:mem_sb>
sb_write_di:
	push %es
	push %si
	push %di

	mov $(DISK_SB_MEM>>0x10), %ax
	mov %ax, %es
	mov $(DISK_SB_MEM&0xFFFF), %si

	# {{{ super
	mov %si, %di
	add $SB_OFF_DI_SB, %di

	mov $DISK_SB_SECT_CNT, %ax
	mov %ax, %es:SB_OFF_DI_SECT_CNT(%di)

	mov $(DISK_SB_MEM>>0x10), %ax
	mov %ax, %es:SB_OFF_DI_MEM+0x02(%di)
	mov $(DISK_SB_MEM&0xFFFF), %ax
	mov %ax, %es:SB_OFF_DI_MEM(%di)

	mov $(DISK_SB_LBA>>0x10), %ax
	mov %ax, %es:SB_OFF_DI_LBA+0x02(%di)
	mov $(DISK_SB_LBA&0xFFFF), %ax
	mov %ax, %es:SB_OFF_DI_LBA(%di)
	# }}}

	# {{{ blk bitmap
	mov %si, %di
	add $SB_OFF_DI_BBM, %di

	mov $DISK_BLK_SECT_CNT, %ax
	mov %ax, %es:SB_OFF_DI_SECT_CNT(%di)

	mov $(DISK_BBM_MEM>>0x10), %ax
	mov %ax, %es:SB_OFF_DI_MEM+0x02(%di)
	mov $(DISK_BBM_MEM&0xFFFF), %ax
	mov %ax, %es:SB_OFF_DI_MEM(%di)

	mov %es:SB_OFF_BBM_LBA+0x02(%si), %ax
	mov %ax, %es:SB_OFF_DI_LBA+0x02(%di)
	mov %es:SB_OFF_BBM_LBA(%si), %ax
	mov %ax, %es:SB_OFF_DI_LBA(%di)
	# }}}

	# {{{ inum bitmap
	mov %si, %di
	add $SB_OFF_DI_IBM, %di

	mov $DISK_BLK_SECT_CNT, %ax
	mov %ax, %es:SB_OFF_DI_SECT_CNT(%di)

	mov $(DISK_IBM_MEM>>0x10), %ax
	mov %ax, %es:SB_OFF_DI_MEM+0x02(%di)
	mov $(DISK_IBM_MEM&0xFFFF), %ax
	mov %ax, %es:SB_OFF_DI_MEM(%di)

	mov %es:SB_OFF_IBM_LBA+0x02(%si), %ax
	mov %ax, %es:SB_OFF_DI_LBA+0x02(%di)
	mov %es:SB_OFF_IBM_LBA(%si), %ax
	mov %ax, %es:SB_OFF_DI_LBA(%di)
	# }}}

	# {{{ ind table
	mov %si, %di
	add $SB_OFF_DI_IT, %di

	mov $DISK_BLK_SECT_CNT, %ax
	mov %ax, %es:SB_OFF_DI_SECT_CNT(%di)

	mov $(DISK_IT_MEM>>0x10), %ax
	mov %ax, %es:SB_OFF_DI_MEM+0x02(%di)
	mov $(DISK_IT_MEM&0xFFFF), %ax
	mov %ax, %es:SB_OFF_DI_MEM(%di)

	mov %es:SB_OFF_IT_LBA+0x02(%si), %ax
	mov %ax, %es:SB_OFF_DI_LBA+0x02(%di)
	mov %es:SB_OFF_IT_LBA(%si), %ax
	mov %ax, %es:SB_OFF_DI_LBA(%di)
	# }}}

	pop %di
	pop %si
	pop %es
	ret
