# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Disk Address Packet

.include "fayfs/sb.s"
.section .data
.global dap
.global dap_super
.global dap_inode

dap:
	.byte 0x10
	.byte 0x00
	.word 0x08
	.word 0x8000
	.word 0x00
	.word 0x80
	.word 0x00
	.word 0x00
	.word 0x00

dap_super:
	.byte 0x10
	.byte 0x00
	.word 0x01
	.word 0x0600
	.word 0x00
	.word SB_LBA
	.word 0x00
	.word 0x00
	.word 0x00

dap_inode:
	.byte 0x10
	.byte 0x00
	.word 0x08
	.word 0x8000
	.word 0x00
	.word 0x50 # TODO: real inode
	.word 0x00
	.word 0x00
	.word 0x00

.section .text
.code16
.global set_dap_lba

# set_dap_lba(lba_hi, lba_lo)
set_dap_lba:
	push %bp
	mov %sp, %bp
	push %si
	push %ax

	# set lba
	mov $dap, %si
	mov 0x04(%bp), %ax # high
	mov %ax, 0x0A(%si)
	mov 0x06(%bp), %ax # low
	mov %ax, 0x08(%si)
	
	pop %ax
	pop %si
	pop %bp
	ret
