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

	push $dap_bb
	call read_disk
	add $0x02, %sp
	mov %ax, %bx

	xor %ax, %ax
	push %ax
	push %bx
	call set_bit
	add $0x04, %sp

	push $dap_bb
	call write_disk
	add $0x02, %sp

	pop %bx
	# }}}

	# {{{
	push %bx

	push $dap_ib
	call read_disk
	add $0x02, %sp
	mov %ax, %bx

	xor %ax, %ax
	push %ax
	push %bx
	call set_bit
	add $0x04, %sp

	push $dap_ib
	call write_disk
	add $0x02, %sp

	pop %bx
	# }}}
	ret
