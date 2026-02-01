# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025-2026 Facooya and Fanone Facooya

.include "chr.inc"
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

	pop %bx
	pop %di
	pop %si
	pop %es
	ret

.section .data
_path_hist: .asciz "/.history"
_test_data: .asciz "test data"
_buf: .zero 0x20
