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

	#mov (_vga_last_row_off), %ax
	add %ax, %si
	add %ax, %si

	mov $0x41, %al
	mov $VGA_ATTR_COLOR, %ah
	mov %ax, %es:(%si)

	mov (VGA_ADDR_COL), %ax
	sub %ax, %si
	sub %ax, %si
	mov $0x42, %al
	mov $VGA_ATTR_COLOR, %ah
	mov %ax, %es:(%si)

	pop %si
	pop %es
	ret

.section .data
_test_data: .asciz "test data"
