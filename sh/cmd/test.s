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

	push $F_TYPE_FILE
	push $_path_a
	call fs_add
	add $0x04, %sp

	push $_path_a
	call path_parse
	add $0x02, %sp

	mov $fs_write_buf, %si
	mov $0x4241, (%si)
	mov $0x4443, 0x02(%si)
	mov $0x4645, 0x04(%si)

	push $0x06
	push $0x0000
	push $fsp+FSP_OFF_BASE
	call fs_write
	add $0x06, %sp

	push $0x06
	push $0x1000
	push $fsp+FSP_OFF_BASE
	call fs_write
	add $0x06, %sp

	push $0x06
	push $0x2000
	push $fsp+FSP_OFF_BASE
	call fs_write
	add $0x06, %sp

	push $0x02
	push $0x0FF0
	push $fsp+FSP_OFF_BASE
	call fs_del
	add $0x06, %sp

	mov $fs_buf, %si
	add $0x0000, %si
	push %si
	push $0x04
	#call vga_outns
	add $0x04, %sp

	push $fs_tmp_buf
	#call vga_outs
	add $0x02, %sp

	pop %bx
	pop %di
	pop %si
	pop %es
	ret

.section .data
_path_a: .asciz "/abc"
_path_hist: .asciz "/.history"
_test_data: .asciz "test data"
_buf: .zero 0x20
