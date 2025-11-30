# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# [Conversion] Hexadecimal to decimal

.section .text
.code16
.global ub8_h_to_d

# ub8_h_to_d(ub8 hex)
# <ret> ah:al = dec_hi:dec_lo
ub8_h_to_d:
	push %bp
	mov %sp, %bp
	push %bx

	mov 0x04(%bp), %ax # (ub8 hex)
	xor %bx, %bx # buf
	xor %cx, %cx # shl

.lp:
	# (quotient == 0) ? {end}
	test %ax, %ax
	jz .end

	# ax /= 10
	push %cx # [s.c0:shl]
	mov $0x0A, %cx
	xor %dx, %dx
	div %cx
	and $0x0F, %dl # remainder
	pop %cx # [s.c0:shl]
	shl %cl, %dx
	or %dx, %bx # store

	add $0x04, %cl # shl
	jmp .lp

.end:
	mov %bx, %ax # <ret>

.done:
	pop %bx
	pop %bp
	ret
