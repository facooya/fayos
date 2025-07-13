# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Disk Address Packet utilities

.section .text
.code16
.global set_dap_lba
.global src_set_dap_lba

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
