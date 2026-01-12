# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025-2026 Facooya and Fanone Facooya

.include "fs/fs.inc"
.section .text
.code16
.global cmd_test

# cmd_test()
cmd_test:
	push %si

	push $_path_top # (&path)
	call path_parse
	add $0x02, %sp

	mov $fsp+FSP_OFF_BASE, %si
	mov FSP_OFF_F_SIZE(%si), %ax
	push %ax
	call dbg_reg
	add $0x02, %sp

	pop %si
	ret

.section .data
_path_top: .asciz "/.top"
