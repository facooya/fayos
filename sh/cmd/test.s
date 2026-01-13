# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025-2026 Facooya and Fanone Facooya

.include "drv/vga.inc"
.section .text
.code16
.global cmd_test

# cmd_test()
cmd_test:
	push %es
	push %si

	mov $(VGA_MEM>>0x10), %ax
	mov %ax, %es
	mov $(VGA_MEM&0xFFFF), %si

	mov (_vga_last_row_off), %ax
	add %ax, %si
	add %ax, %si

	mov $0x41, %al
	mov $VGA_ATTR_COLOR, %ah
	mov %ax, %es:(%si)

	call _vga_save_bottom

	push $_path_bottom # (&path)
	call dbg_file
	add $0x02, %sp

	pop %si
	pop %es
	ret

.section .data
_test_data: .asciz "test data"
_path_bottom: .asciz "/.bottom"
