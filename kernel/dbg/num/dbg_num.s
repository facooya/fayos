# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Debug number - show number value

.section .text
.code16
.global dbg_num

# dbg_num(*num)
# <req> *num [4-byte]
dbg_num:
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
