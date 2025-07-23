# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Debug inum

.section .text
.code16
.global dbg_inum

# dbg_inum()
dbg_inum:
	push %ax
	push %dx

	call dbg_line

	mov (inum+0x02), %dx
	add $0x30, %dh
	add $0x30, %dl
	mov %dh, %al
	call outc
	mov %dl, %al
	call outc

	mov (inum), %dx
	add $0x30, %dh
	add $0x30, %dl
	mov %dh, %al
	call outc
	mov %dl, %al
	call outc

	call dbg_line
	call outnl

	pop %dx
	pop %ax
	ret
