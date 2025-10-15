# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# [Superblock] Set logical block address

.include "fs/sb.s"
.section .text
.code16
.global sb_set_lba

# sb_set_lba()
sb_set_lba:
	mov %es:SB_OFF_BBM_LBA(%bx), %ax
	push %ax
	mov %es:SB_OFF_BBM_LBA+0x02(%bx), %ax
	push %ax
	push $dap_bb
	call set_src_dap_lba
	add $0x06, %sp

	mov %es:SB_OFF_IBM_LBA(%bx), %ax
	push %ax
	mov %es:SB_OFF_IBM_LBA+0x02(%bx), %ax
	push %ax
	push $dap_ib
	call set_src_dap_lba
	add $0x06, %sp

	mov %es:SB_OFF_IT_LBA(%bx), %ax
	push %ax
	mov %es:SB_OFF_IT_LBA+0x02(%bx), %ax
	push %ax
	push $dap_it
	call set_src_dap_lba
	add $0x06, %sp
	ret
