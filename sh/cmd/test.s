# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025-2026 Facooya and Fanone Facooya

.include "fs/fs.inc"
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

	mov $fs_write_buf, %di
	movw $0x4241, (%di)
	movw $0x4443, 0x02(%di)

	push $_path_hist
	call path_parse
	add $0x02, %sp

	push $0x04
	push $0x0FFA
	push $fsp+FSP_OFF_BASE
	call fs_write
	add $0x06, %sp

	push $0x04
	push $0x0FFA
	push $fsp+FSP_OFF_BASE
	call fs_read
	add $0x06, %sp

	mov $fs_read_buf, %si
	push %si
	call vga_outs
	add $0x02, %sp

	pop %bx
	pop %di
	pop %si
	pop %es
	ret

.section .data
_path_hist: .asciz "/.history"
_test_data: .asciz "test data"
