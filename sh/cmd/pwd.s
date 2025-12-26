# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# [Command] Show path-working-directory

.section .text
.code16
.global cmd_pwd

# cmd_pwd()
cmd_pwd:
	push %si

	mov $cwd, %si
	xor %ax, %ax
	push %si # (&off)
	push %ax # (&seg)
	call puts
	add $0x04, %sp

# {DONE}
.done:
	call putnl
	xor %ax, %ax
	jmp .epil

.epil:
	pop %si
	ret
