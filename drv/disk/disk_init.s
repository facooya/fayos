# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# [Disk] Initial

.include "drv/disk.s"
.include "fs/fs.s"
.include "fs/sb.s"
.include "fs/ind.s"
.section .text
.code16
.global disk_init

# disk_init()
disk_init:
	push %es
	push %si
	push %bx

	# blk bm
	push $DISK_BLK_SECT_CNT # sect_cnt
	mov $dlba, %si
	add $DLBA_OFF_BBM, %si
	push (%si) # lba_lo
	push 0x02(%si) # lba_hi
	push $(DISK_BBM_MEM&0xFFFF) # off
	push $(DISK_BBM_MEM>>0x10) # seg
	call ata_read_sect
	add $0x0A, %sp

	# inum bm
	push $DISK_BLK_SECT_CNT # sect_cnt
	mov $dlba, %si
	add $DLBA_OFF_IBM, %si
	push (%si) # lba_lo
	push 0x02(%si) # lba_hi
	push $(DISK_IBM_MEM&0xFFFF) # off
	push $(DISK_IBM_MEM>>0x10) # seg
	call ata_read_sect
	add $0x0A, %sp

	# ind tbl
	push $DISK_BLK_SECT_CNT # sect_cnt
	mov $dlba, %si
	add $DLBA_OFF_IT, %si
	push (%si) # lba_lo
	push 0x02(%si) # lba_hi
	push $(DISK_IT_MEM&0xFFFF) # off
	push $(DISK_IT_MEM>>0x10) # seg
	call ata_read_sect
	add $0x0A, %sp

	# {{{ root
	push (root_inum) # inum_lo
	push (root_inum+0x02) # inum_hi
	call ind_read3
	add $0x04, %sp
	# <ret> dx:ax = ind_seg:ind_off
	mov %dx, %es
	mov %ax, %bx

	push %es:IND_OFF_BLK_0(%bx) # blk_lo
	push %es:IND_OFF_BLK_0+0x02(%bx) # blk_hi
	call fs_blk_to_lba
	add $0x04, %sp

	push $DISK_BLK_SECT_CNT # sect_cnt
	push %ax # lba_lo
	push %dx # lba_hi
	push $(DISK_ROOT_MEM&0xFFFF) # off
	push $(DISK_ROOT_MEM>>0x10) # seg
	call ata_read_sect
	add $0x0A, %sp
	# }}}

	pop %bx
	pop %si
	pop %es
	ret
