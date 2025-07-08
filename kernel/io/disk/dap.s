# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Disk Address Packet

.include "fayfs/sb.s"
.section .data
.global dap
.global dap_super

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
	.word SB_LBA_LO
	.word 0x00
	.word 0x00
	.word 0x00

.section .text
.code16
.global set_dap_lba
.global set_dap_target
.global reset_dap_target

# ENTRY
# set_dap_lba(lba_high, lba_low) [n_set_dap]
set_dap_lba:
	# prol
	push %bp
	mov %sp, %bp
	push %si
	push %ax

	# set lba
	mov $dap, %si
	mov 4(%bp), %ax # high
	mov %ax, 10(%si)
	mov 6(%bp), %ax # low
	mov %ax, 8(%si)
	
	# epli
	pop %ax
	pop %si
	pop %bp
	ret

# ENTRY
# set_dap_target(count, segment, offset) [n_set_dap]
set_dap_target:
	# prol
	push %bp
	mov %sp, %bp
	push %si
	push %ax

	# set dap target
	mov $dap, %si
	mov 4(%bp), %ax
	mov %ax, 2(%si) # count
	mov 6(%bp), %ax
	mov %ax, 6(%si) # segment
	mov 8(%bp), %ax
	mov %ax, 4(%si) # offset

	# epli
	pop %ax
	pop %si
	pop %bp
	ret

# ENTRY
# reset_dap_target()
reset_dap_target:
	push $0x8000
	push $0x00
	push $0x08
	call set_dap_target
	add $0x06, %sp
	ret
