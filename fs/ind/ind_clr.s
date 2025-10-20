# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# [Index Node] Clear index node

.include "drv/disk.s"
.include "fs/ind.s"
.section .text
.code16
.global ind_clr

# ind_clr(*inum)
ind_clr:
	push %bp
	mov %sp, %bp
	push %es
	push %si
	push %bx

	# {{{ read/write inode table
	push $DISK_BLK_SECT_CNT # sect_cnt
	mov $dlba, %si
	add $DLBA_OFF_IT, %si
	push (%si) # lba_lo
	push 0x02(%si) # lba_hi
	push $(DISK_IT_MEM&0xFFFF) # off
	push $(DISK_IT_MEM>>0x10) # seg
	call ata_read_sect
	add $0x0A, %sp
	mov $(DISK_IT_MEM>>0x10), %ax
	mov %ax, %es
	mov $(DISK_IT_MEM&0xFFFF), %bx

	# calc inode # TODO: low, high
	xor %dx, %dx
	mov 0x04(%bp), %si # *inum
	mov (%si), %ax # inum_lo
	mov $IND_SIZE, %cx
	mul %cx # ax *= cx
	add %ax, %bx # set mem

	# clear_bit(mem, bitnum)
	mov %es:IND_OFF_BLK_0(%bx), %ax
	mov %ax, (bbnum)

	# clear block # TODO: clear all block
	xor %ax, %ax
	mov %ax, %es:IND_OFF_FILE_SIZE(%bx)
	mov %ax, %es:IND_OFF_BLK_0(%bx)
	mov %ax, %es:IND_OFF_BLK_0+0x02(%bx)

	push $DISK_BLK_SECT_CNT # sect_cnt
	mov $dlba, %si
	add $DLBA_OFF_IT, %si
	push (%si) # lba_lo
	push 0x02(%si) # lba_hi
	push $(DISK_IT_MEM&0xFFFF) # off
	push $(DISK_IT_MEM>>0x10) # seg
	call ata_write_sect
	add $0x0A, %sp
	# } push bitnum

	# { clear block bit
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
	call bm_clr
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

	# {{{ clear inum bit
	push $DISK_BLK_SECT_CNT # sect_cnt
	mov $dlba, %si
	add $DLBA_OFF_IBM, %si
	push (%si) # lba_lo
	push 0x02(%si) # lba_hi
	push $(DISK_IBM_MEM&0xFFFF) # off
	push $(DISK_IBM_MEM>>0x10) # seg
	call ata_write_sect
	add $0x0A, %sp
	mov $(DISK_IBM_MEM>>0x10), %ax
	mov %ax, %es
	mov $(DISK_IBM_MEM&0xFFFF), %bx

	mov 0x04(%bp), %si
	mov (%si), %ax
	mov %ax, (ibnum)
	push $ibnum
	push %bx
	push %es
	call bm_clr
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
	pop %bp
	ret
