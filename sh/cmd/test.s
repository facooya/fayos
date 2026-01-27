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
	movw $0x4241, (%di)
	movw $0x4443, 0x02(%di)

	push $0x04
	push $0x0FFD
	push $_path_hist
	call fs_write
	add $0x06, %sp

	push $0x02
	push $0x0FFF
	push $_path_hist
	#call fs_read
	add $0x06, %sp

	push $file_read_buf
	#call vga_outs
	add $0x02, %sp

	pop %bx
	pop %di
	pop %si
	pop %es
	ret

.section .data
_path_hist: .asciz "/.history"
_test_data: .asciz "test data"
