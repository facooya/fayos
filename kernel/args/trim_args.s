# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Trim arguments

.include "chr.s"

.section .text
.code16
.global trim_args

# trim_args()
trim_args:
	push %si
	push %di

	mov $raw_buf, %si
	mov (%si), %cx
	add $0x02, %si

.left:
	mov (%si), %al

	cmp $CHR_SP, %al
	jne .left_end

	add $0x01, %si
	sub $0x01, %cx
	jmp .left

.left_end:
	mov %si, %di
	add %cx, %di
	sub $0x01, %di

.right:
	mov (%di), %al

	cmp $CHR_SP, %al
	jne .right_end

	sub $0x01, %di
	sub $0x01, %cx
	jmp .right

.right_end:
	mov $raw_buf, %di
	mov %cx, (%di)
	add $0x02, %di

.rewrite:
	test %cx, %cx
	jz .done

	mov (%si), %al
	mov %al, (%di)

	add $0x01, %si
	add $0x01, %di
	sub $0x01, %cx
	jmp .rewrite

.done:
	pop %di
	pop %si
	ret
