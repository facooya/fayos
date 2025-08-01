# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Disk Address Packet utilities

.section .text
.code16
.global set_dap_lba
.global set_src_dap_lba
.global set_dap_mem

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

# set_src_dap_lba(&dap, lba_hi, lba_lo)
set_src_dap_lba:
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

# set_dap_mem()
set_dap_mem:
	push %si

	call alloc_mem

	mov $dap, %si
	mov %ax, 0x04(%si)
	mov %dx, 0x06(%si)

	pop %si
	ret
