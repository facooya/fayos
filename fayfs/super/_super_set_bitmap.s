# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Set bitmap

.include "fayfs/sb.s"
.section .text
.code16
.global _super_set_bitmap

# _super_set_bitmap()
_super_set_bitmap:
	# {{{
	push %bx

	mov BB_LBA_LO_OFF(%bx), %ax
	push %ax # lo
	xor %ax, %ax
	push %ax # hi
	call set_dap_lba
	add $0x04, %sp

	push $dap
	call read_disk
	add $0x02, %sp
	mov %ax, %bx

	xor %ax, %ax
	bts $0x00, %ax # reserved block 0
	mov %ax, (%bx)

	push $dap
	call write_disk
	add $0x02, %sp

	pop %bx
	# }}}

	# {{{
	push %bx

	mov IB_LBA_LO_OFF(%bx), %ax
	push %ax # lo
	xor %ax, %ax
	push %ax # hi
	call set_dap_lba
	add $0x04, %sp

	push $dap
	call read_disk
	add $0x02, %sp
	mov %ax, %bx

	xor %ax, %ax
	bts $0x00, %ax # reserved inum 0
	mov %ax, (%bx)

	push $dap
	call write_disk
	add $0x02, %sp

	pop %bx
	# }}}
	ret
