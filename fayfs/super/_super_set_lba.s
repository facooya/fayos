# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Set lba by superblock disk

.include "fayfs/sb.s"
.section .text
.code16
.global _super_set_lba

_super_set_lba:
	mov BB_LBA_LO_OFF(%bx), %ax
	push %ax
	mov BB_LBA_HI_OFF(%bx), %ax
	push %ax
	push $dap_bb
	call src_set_dap_lba
	add $0x06, %sp

	mov IB_LBA_LO_OFF(%bx), %ax
	push %ax
	mov IB_LBA_HI_OFF(%bx), %ax
	push %ax
	push $dap_ib
	call src_set_dap_lba
	add $0x06, %sp

	mov IT_LBA_LO_OFF(%bx), %ax
	push %ax
	mov IT_LBA_HI_OFF(%bx), %ax
	push %ax
	push $dap_it
	call src_set_dap_lba
	add $0x06, %sp
	ret
