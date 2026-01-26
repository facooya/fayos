# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025-2026 Facooya and Fanone Facooya

.include "drv/vga.inc"
.include "drv/disk.inc"
.section .text
.code16
.global cmd_test

# cmd_test()
cmd_test:
	push %es
	push %si
	push %di
	push %bx

	mov $file_write_buf, %di
	movw $0x4142, (%di)

	push $0x02
	push $0x1000
	push $_path_hist
	call fs_write
	add $0x06, %sp

	mov $file_write_buf, %di
	movw $0x4344, (%di)

	push $0x02
	push $0x2000
	push $_path_hist
	call fs_write
	add $0x06, %sp

	pop %bx
	pop %di
	pop %si
	pop %es
	ret

.section .data
_path_hist: .asciz "/.history"
_test_data: .asciz "test data"
