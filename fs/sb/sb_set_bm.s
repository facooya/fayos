# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# [Superblock] Set bitmap

.include "drv/disk.s"
.section .text
.code16
.global sb_set_bm

# sb_set_bm()
sb_set_bm:
	push %es
	push %si
	push %bx

	# {{{ bbm
	push $DISK_BLK_SECT_CNT # sect_cnt
	mov $dlba, %si
	add $DLBA_OFF_BBM, %si
	push (%si) # lba_lo
	push 0x02(%si) # lba_hi
	push $(DISK_BBM_MEM&0xFFFF) # off
	push $(DISK_BBM_MEM>>0x10) # seg
	call ata_read_sect
	add $0x0A, %sp
	mov $(DISK_BBM_MEM>>0x10), %ax
	mov %ax, %es
	mov $(DISK_BBM_MEM&0xFFFF), %bx

	push $bbnum
	push %bx
	push %es
	call bm_set
	add $0x06, %sp

	push $DISK_BLK_SECT_CNT # sect_cnt
	mov $dlba, %si
	add $DLBA_OFF_BBM, %si
	push (%si) # lba_lo
	push 0x02(%si) # lba_hi
	push $(DISK_BBM_MEM&0xFFFF) # off
	push $(DISK_BBM_MEM>>0x10) # seg
	call ata_write_sect
	add $0x0A, %sp
	# }}}

	# {{{ ibm
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
	mov $(DISK_IBM_MEM>>0x10), %ax
	mov %ax, %es
	mov $(DISK_IBM_MEM&0xFFFF), %bx

	push $ibnum
	push %bx
	push %es
	call bm_set
	add $0x06, %sp

	push $DISK_BLK_SECT_CNT # sect_cnt
	mov $dlba, %si
	add $DLBA_OFF_IBM, %si
	push (%si) # lba_lo
	push 0x02(%si) # lba_hi
	push $(DISK_IBM_MEM&0xFFFF) # off
	push $(DISK_IBM_MEM>>0x10) # seg
	call ata_write_sect
	add $0x0A, %sp
	# }}}

	pop %bx
	pop %si
	pop %es
	ret
