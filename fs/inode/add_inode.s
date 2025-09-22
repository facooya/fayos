# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Add inode in inode table

.include "fayfs/inode.s"
.section .text
.code16
.global add_inode

# add_inode()
# <ret> tmp_inum = allocated inum by add_inode()
add_inode:
	push %es
	push %bx

	# {{{ alloc blknum
	mov $dap_bb, %bx
	push $0x08 # sect_cnt
	mov 0x08(%bx), %ax
	push %ax # lba_lo
	mov 0x0A(%bx), %ax
	push %ax # lba_hi
	mov 0x04(%bx), %ax
	push %ax # off
	mov 0x06(%bx), %ax
	push %ax # seg
	call ata_read_sect
	add $0x0A, %sp
	mov %ax, %bx
	mov %dx, %es

	push $bbnum
	push %bx
	push %es
	call alloc_bit
	add $0x06, %sp
	# }}}

	# {{{ alloc inum
	mov $dap_ib, %bx
	push $0x08 # sect_cnt
	mov 0x08(%bx), %ax
	push %ax # lba_lo
	mov 0x0A(%bx), %ax
	push %ax # lba_hi
	mov 0x04(%bx), %ax
	push %ax # off
	mov 0x06(%bx), %ax
	push %ax # seg
	call ata_read_sect
	add $0x0A, %sp
	mov %ax, %bx
	mov %dx, %es

	push $ibnum
	push %bx
	push %es
	call alloc_bit
	add $0x06, %sp
	mov (ibnum), %ax
	mov %ax, (tmp_inum)
	# }}}

	# {{{ read/write inode table
	# read inode table
	mov $dap_it, %bx
	push $0x08 # sect_cnt
	mov 0x08(%bx), %ax
	push %ax # lba_lo
	mov 0x0A(%bx), %ax
	push %ax # lba_hi
	mov 0x04(%bx), %ax
	push %ax # off
	mov 0x06(%bx), %ax
	push %ax # seg
	call ata_read_sect
	add $0x0A, %sp
	mov %ax, %bx
	mov %dx, %es

	# calc inode # TODO: LO,HI
	xor %dx, %dx
	mov (ibnum), %ax
	mov $I_SIZE, %cx
	mul %cx # ax *= cx
	add %ax, %bx # set mem

	# write blk # TODO: LO,HI
	mov (bbnum), %ax
	mov %ax, %es:I_BLK_0_OFF(%bx)

	# write inode table
	mov $dap_it, %bx
	push $0x08 # sect_cnt
	mov 0x08(%bx), %ax
	push %ax # lba_lo
	mov 0x0A(%bx), %ax
	push %ax # lba_hi
	mov 0x04(%bx), %ax
	push %ax # off
	mov 0x06(%bx), %ax
	push %ax # seg
	call ata_write_sect
	add $0x0A, %sp
	# }}}

	# {{{ set inum bit
	mov $dap_ib, %bx
	push $0x08 # sect_cnt
	mov 0x08(%bx), %ax
	push %ax # lba_lo
	mov 0x0A(%bx), %ax
	push %ax # lba_hi
	mov 0x04(%bx), %ax
	push %ax # off
	mov 0x06(%bx), %ax
	push %ax # seg
	call ata_read_sect
	add $0x0A, %sp
	mov %ax, %bx
	mov %dx, %es

	push $ibnum
	push %bx
	push %es
	call set_bit
	add $0x06, %sp

	mov $dap_ib, %bx
	push $0x08 # sect_cnt
	mov 0x08(%bx), %ax
	push %ax # lba_lo
	mov 0x0A(%bx), %ax
	push %ax # lba_hi
	mov 0x04(%bx), %ax
	push %ax # off
	mov 0x06(%bx), %ax
	push %ax # seg
	call ata_write_sect
	add $0x0A, %sp
	# }}}

	# {{{ set blknum bit
	mov $dap_bb, %bx
	push $0x08 # sect_cnt
	mov 0x08(%bx), %ax
	push %ax # lba_lo
	mov 0x0A(%bx), %ax
	push %ax # lba_hi
	mov 0x04(%bx), %ax
	push %ax # off
	mov 0x06(%bx), %ax
	push %ax # seg
	call ata_read_sect
	add $0x0A, %sp
	mov %ax, %bx
	mov %dx, %es

	push $bbnum
	push %bx
	push %es
	call set_bit
	add $0x06, %sp

	mov $dap_bb, %bx
	push $0x08 # sect_cnt
	mov 0x08(%bx), %ax
	push %ax # lba_lo
	mov 0x0A(%bx), %ax
	push %ax # lba_hi
	mov 0x04(%bx), %ax
	push %ax # off
	mov 0x06(%bx), %ax
	push %ax # seg
	call ata_write_sect
	add $0x0A, %sp
	# }}}

	pop %bx
	pop %es
	ret
