# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Debug inum - show inum value

.section .text
.code16
.global dbg_inum

# dbg_inum(*inum)
dbg_inum:
	push %bp
	mov %sp, %bp
	push %si
	push %ax
	push %dx

	call dbg_line

	mov 0x04(%bp), %si
	mov 0x02(%si), %dx
	add $0x30, %dh
	add $0x30, %dl
	mov %dh, %al
	call outc
	mov %dl, %al
	call outc

	mov (%si), %dx
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
	pop %si
	pop %bp
	ret
