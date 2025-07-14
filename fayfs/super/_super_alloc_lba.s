# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Allocate LBA in superblock disk

.include "fayfs/sb.s"
.section .text
.code16
.global _super_alloc_lba

# _super_alloc_lba()
_super_alloc_lba:
	mov DP_LBA_LO_SIZE_OFF(%bx), %ax
	# TODO: mov DP_LBA_HI_SIZE_OFF(%bx), %ax

	# {{{
	# bbs
	xor %dx, %dx
	mov $0x40, %cx
	div %cx
	mov %ax, BBS_LO_OFF(%bx)

	# ibs
	mov BBS_LO_OFF(%bx), %ax
	xor %dx, %dx
	mov $0x04, %cx
	div %cx
	mov %ax, IBS_LO_OFF(%bx)

	# its
	mov BBS_LO_OFF(%bx), %ax
	xor %dx, %dx
	mov $0x40, %cx
	mul %cx
	mov %ax, ITS_LO_OFF(%bx)
	# }}}

	# {{{
	# bbbc
	mov BBS_LO_OFF(%bx), %ax
	xor %dx, %dx
	mov $0x1000, %cx
	div %cx

	test %dx, %dx
	jz .set_bbbc
	add $0x01, %ax

.set_bbbc:
	mov %ax, BBBC_OFF(%bx)

	# ibbc
	mov IBS_LO_OFF(%bx), %ax
	xor %dx, %dx
	mov $0x1000, %cx
	div %cx

	test %dx, %dx
	jz .set_ibbc
	add $0x01, %ax

.set_ibbc:
	mov %ax, IBBC_OFF(%bx)

	# itbc
	mov ITS_LO_OFF(%bx), %ax
	xor %dx, %dx
	mov $0x1000, %cx
	div %cx

	test %dx, %dx
	jz .set_itbc
	add $0x01, %ax

.set_itbc:
	mov %ax, ITBC_OFF(%bx)
	# }}}
	
	# {{{
	# bb
	mov $FST_LBA, %ax
	mov %ax, BB_LBA_LO_OFF(%bx)

	# ib
	mov BBBC_OFF(%bx), %ax
	xor %dx, %dx
	mov $0x08, %cx
	mul %cx
	mov BB_LBA_LO_OFF(%bx), %cx
	add %cx, %ax
	mov %ax, IB_LBA_LO_OFF(%bx)

	# it
	mov IBBC_OFF(%bx), %ax
	xor %dx, %dx
	mov $0x08, %cx
	mul %cx
	mov IB_LBA_LO_OFF(%bx), %cx
	add %cx, %ax
	mov %ax, IT_LBA_LO_OFF(%bx)

	# normal
	mov ITBC_OFF(%bx), %ax
	xor %dx, %dx
	mov $0x08, %cx
	mul %cx
	mov IT_LBA_LO_OFF(%bx), %cx
	add %cx, %ax
	mov %ax, NORM_LBA_LO_OFF(%bx)
	# }}}
	ret
