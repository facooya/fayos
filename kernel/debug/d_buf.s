# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Debug buffer

.include "chr.s"

.section .text
.code16
.global d_buf

# d_buf(buf)
d_buf:
	push %bp
	mov %sp, %bp
	push %si
	push %di
	push %bx

	call outnl

	mov 0x04(%bp), %si
	mov (%si), %cx
	add $0x02, %si

.main:
	test %cx, %cx
	jz .done

	mov (%si), %al

	cmp $CHR_SP, %al
	je .sp

	test %al, %al
	jz .nul

	call sys_tty_out
	jmp .step

.sp:
	mov $CHR_PERIOD, %al
	call sys_tty_out
	jmp .step

.nul:
	mov $CHR_ZERO, %al
	call sys_tty_out
	jmp .step

.step:
	add $0x01, %si
	sub $0x01, %cx
	jmp .main

.done:
	pop %bx
	pop %di
	pop %si
	pop %bp
	ret
