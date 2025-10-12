# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Clear inode in inode table

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
	# } push bitnum

	# { clear block bit
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
	call clear_bit
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

	# {{{ clear inum bit
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

	mov 0x04(%bp), %si
	mov (%si), %ax
	mov %ax, (ibnum)
	push $ibnum
	push %bx
	push %es
	call clear_bit
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

	pop %bx
	pop %si
	pop %es
	pop %bp
	ret
