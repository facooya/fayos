# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Disk Address Packet utilities

.include "fayfs/super.s"
.section .text
.code16
.global set_dap_lba
.global src_set_dap_lba
.global set_dap_blk_lba

# set_dap_lba(lba_hi, lba_lo)
set_dap_lba:
	push %bp
	mov %sp, %bp
	push %si

	mov $dap, %si
	mov 0x04(%bp), %ax
	mov %ax, 0x0A(%si)
	mov 0x06(%bp), %ax
	mov %ax, 0x08(%si)
	
	pop %si
	pop %bp
	ret

# src_set_dap_lba(&dap, lba_hi, lba_lo)
src_set_dap_lba:
	push %bp
	mov %sp, %bp
	push %si

	mov 0x04(%bp), %si
	mov 0x06(%bp), %ax
	mov %ax, 0x0A(%si)
	mov 0x08(%bp), %ax
	mov %ax, 0x08(%si)
	
	pop %si
	pop %bp
	ret

# set_dap_blk_lba(blknum_hi, blknum_lo)
set_dap_blk_lba:
	push %bp
	mov %sp, %bp
	push %bx

	# calc
	mov 0x06(%bp), %ax
	xor %dx, %dx
	mov $0x08, %cx
	mul %cx
	mov $S_OFF_MEM, %bx
	mov NORM_LBA_LO_OFF(%bx), %cx
	add %cx, %ax

	push %ax # lo
	xor %ax, %ax
	push %ax # hi
	call set_dap_lba
	add $0x04, %sp

	pop %bx
	pop %bp
	ret
