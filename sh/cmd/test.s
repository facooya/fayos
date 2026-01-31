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

	push $((ATTR_DIR<<0x08)|CHR_UC_A)
	call vga_outc
	add $0x02, %sp
	jmp 99f

	mov $fs_write_buf, %di
	movw $0x4241, (%di)
	movw $0x4443, 0x02(%di)

	push $_path_hist
	call path_parse
	add $0x02, %sp

	mov $0x10, %cx
	mov $0x0FFE, %bx

1:
	push %cx
	push $0x04
	push %bx
	push $fsp+FSP_OFF_BASE
	call fs_write
	add $0x06, %sp
	pop %cx

	add $0x1000, %bx
	cmp $0xF000, %bx
	ja 9f
	loop 1b

9:
	push $0x04
	push $0x0FFE
	push $fsp+FSP_OFF_BASE
	call fs_read
	add $0x06, %sp

	mov $fs_read_buf, %si
	push %si
	call vga_outs
	add $0x02, %sp

99:
	pop %bx
	pop %di
	pop %si
	pop %es
	ret

.section .data
_path_hist: .asciz "/.history"
_test_data: .asciz "test data"
