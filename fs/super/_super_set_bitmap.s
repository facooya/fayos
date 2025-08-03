# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Set bitmap

.section .text
.code16
.global _super_set_bitmap

# _super_set_bitmap()
_super_set_bitmap:
	push %es

	# {{{
	push %bx

	push $dap_bb
	call read_disk
	add $0x02, %sp
	mov %ax, %bx
	mov %dx, %es

	push $bbnum
	push %bx
	push %es
	call set_bit
	add $0x06, %sp

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
	mov %dx, %es

	push $ibnum
	push %bx
	push %es
	call set_bit
	add $0x06, %sp

	push $dap_ib
	call write_disk
	add $0x02, %sp

	pop %bx
	# }}}

	pop %es
	ret
