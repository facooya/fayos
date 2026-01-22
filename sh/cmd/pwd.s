# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025-2026 Facooya and Fanone Facooya

.section .text
.code16
.global cmd_pwd

# cmd_pwd()
cmd_pwd:
	push %si

	mov $cwd, %si
	push %si # (off)
	push %ds # (seg)
	call puts
	add $0x04, %sp

.done:
	call putnl
	xor %ax, %ax
	jmp .epil

.epil:
	pop %si
	ret
