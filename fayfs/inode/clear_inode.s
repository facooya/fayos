# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Clear inode in inode table

.include "fayfs/inode.s"
.section .text
.code16
.global clear_inode

# clear_inode(inum_hi, inum_lo)
clear_inode:
	push %bp
	mov %sp, %bp
	push %bx

	# {{{ read/write inode table
	push $dap_it
	call read_disk
	add $0x02, %sp
	mov %ax, %bx
	mov %dx, %ds

	# calc inode # TODO: low, high
	xor %dx, %dx
	mov 0x06(%bp), %ax # inum
	mov $I_SIZE, %cx
	mul %cx # ax *= cx
	add %ax, %bx # set mem

	# clear_bit(mem, bitnum)
	mov I_BLK_0_LO_OFF(%bx), %ax
	mov %ax, (bbnum)

	# clear block # TODO: clear all block
	xor %ax, %ax
	mov %ax, I_FILE_SIZE_OFF(%bx)
	mov %ax, I_BLK_0_LO_OFF(%bx)
	mov %ax, I_BLK_0_HI_OFF(%bx)

	push $dap_it
	call write_disk
	add $0x02, %sp
	xor %ax, %ax
	mov %ax, %ds
	# } push bitnum

	# { clear block bit
	push $dap_bb
	call read_disk
	add $0x02, %sp
	mov %ax, %bx

	push $bbnum
	push %bx
	call clear_bit
	add $0x04, %sp

	push $dap_bb
	call write_disk
	add $0x02, %sp
	# }}}

	# {{{ clear inum bit
	push $dap_ib
	call read_disk
	add $0x02, %sp
	mov %ax, %bx

	mov 0x06(%bp), %ax
	mov %ax, (ibnum)
	push $ibnum
	push %bx
	call clear_bit
	add $0x04, %sp

	push $dap_ib
	call write_disk
	add $0x02, %sp
	# }}}

	pop %bx
	pop %bp
	ret
