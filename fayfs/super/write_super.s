# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Write superblock

.include "fayfs/sb.s"
.section .text
.code16
.global write_super

# write_super()
write_super:
	push %bx

	# {{{ read superblock LBA
	push $0x8000
	push $0x00
	push $0x02
	call set_dap_target
	add $0x06, %sp

	push $SB_LBA_LO
	push $SB_LBA_HI
	call set_dap_lba
	add $0x04, %sp

	push $dap
	call read_disk
	add $0x02, %sp
	mov $0x8000, %bx
	# }}}

	# write inum
	mov (next_i_num), %ax
	mov %ax, NEXT_I_NUM_LO_OFF(%bx)
	mov (next_i_num+0x02), %ax
	mov %ax, NEXT_I_NUM_HI_OFF(%bx)

	# write i_blk
	mov (next_i_blk), %ax
	mov %ax, NEXT_I_BLK_LO_OFF(%bx)
	mov (next_i_blk+0x02), %ax
	mov %ax, NEXT_I_BLK_HI_OFF(%bx)

	# write
	push $dap
	call write_disk
	add $0x02, %sp
	call reset_dap_target

	pop %bx
	ret
