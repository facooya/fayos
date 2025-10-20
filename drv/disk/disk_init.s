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
	mov (%si), %ax
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
	mov (%si), %ax
	push 0x02(%si) # lba_hi
	push $(DISK_IT_MEM&0xFFFF) # off
	push $(DISK_IT_MEM>>0x10) # seg
	call ata_read_sect
	add $0x0A, %sp

	# {{{ root
	push $root_inum
	call ind_get_ptr
	add $0x02, %sp
	mov %dx, %es
	mov %ax, %bx

	# TODO: blk hi
	mov IND_OFF_BLK_0(%bx), %ax
	xor %dx, %dx
	mov $0x08, %cx
	mul %cx
	mov %ax, %cx

	# TODO: lba overflow
	# get norm lba
	mov $(DISK_SB_MEM>>0x10), %ax
	mov %ax, %es
	mov $(DISK_SB_MEM&0xFFFF), %bx
	mov %es:SB_OFF_NORM_LBA(%bx), %ax
	add %ax, %cx

	push $DISK_BLK_SECT_CNT # sect_cnt
	push %cx # lba_lo
	xor %ax, %ax
	push %ax # lba_hi
	push $(DISK_ROOT_MEM&0xFFFF) # off
	push $(DISK_ROOT_MEM>>0x10) # seg
	call ata_read_sect
	add $0x0A, %sp
	# }}}

	pop %bx
	pop %si
	pop %es
	ret
