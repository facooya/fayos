# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Clear inode in inode table

.include "drv/disk.s"
.include "fs/inode.s"
.section .text
.code16
.global clear_inode

# clear_inode(*inum)
clear_inode:
	push %bp
	mov %sp, %bp
	push %es
	push %si
	push %bx

	# {{{ read/write inode table
	push $DNUM_IT
	call disk_read_sect
	add $0x02, %sp
	mov %ax, %bx
	mov %dx, %es

	# calc inode # TODO: low, high
	xor %dx, %dx
	mov 0x04(%bp), %si # *inum
	mov (%si), %ax # inum_lo
	mov $I_SIZE, %cx
	mul %cx # ax *= cx
	add %ax, %bx # set mem

	# clear_bit(mem, bitnum)
	mov %es:I_BLK_0_OFF(%bx), %ax
	mov %ax, (bbnum)

	# clear block # TODO: clear all block
	xor %ax, %ax
	mov %ax, %es:I_FILE_SIZE_OFF(%bx)
	mov %ax, %es:I_BLK_0_OFF(%bx)
	mov %ax, %es:I_BLK_0_OFF+0x02(%bx)

	push $DNUM_IT
	call disk_write_sect
	add $0x02, %sp
	# } push bitnum

	# { clear block bit
	push $DNUM_BBM
	call disk_read_sect
	add $0x02, %sp
	mov %ax, %bx
	mov %dx, %es

	push $bbnum
	push %bx
	push %es
	call clear_bit
	add $0x06, %sp

	push $DNUM_BBM
	call disk_write_sect
	add $0x02, %sp
	# }}}

	# {{{ clear inum bit
	push $DNUM_IBM
	call disk_read_sect
	add $0x02, %sp
	mov %ax, %bx
	mov %dx, %es

	mov 0x04(%bp), %si
	mov (%si), %ax
	mov %ax, (ibnum)
	push $ibnum
	push %bx
	push %es
	call clear_bit
	add $0x06, %sp

	push $DNUM_IBM
	call disk_write_sect
	add $0x02, %sp
	# }}}

	pop %bx
	pop %si
	pop %es
	pop %bp
	ret
