# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Directory entry

.include "fayfs/sb.s"
.section .text
.code16
.global set_blk_lba

# set_blk_lba() # FIXME: blk overflow
# pre: i_blk
set_blk_lba:
	# init
	mov (i_blk), %ax
	mov $0x08, %cx

	# calc
	mul %cx

	mov $FST_LBA_LO, %cx
	add %cx, %ax

	# set dap lba # HACK!!!: low high
	push %ax # low
	xor %ax, %ax
	push %ax # high
	call set_dap_lba
	add $0x04, %sp

	# ret
	ret
